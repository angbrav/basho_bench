-module(saturn_complex_rpc).

-export([new/1,
         run/4]).

-include("basho_bench.hrl").

-record(state, { nodes,
                 clocks,
                 mydc,
                 number_keys,
                 masters,
                 concurrent,
                 friends,
                 total_buckets,
                 id  
               }).


%% ====================================================================
%% API
%% ====================================================================

new(Id) ->
    Nodes = basho_bench_config:get(saturn_dc_nodes),
    NumberKeys = basho_bench_config:get(saturn_number_internalkeys),
    MyNode = basho_bench_config:get(saturn_mynode),
    MyDc = basho_bench_config:get(saturn_dc_id),
    TotalBuckets = basho_bench_config:get(saturn_total_buckets),
    Concurrent = basho_bench_config:get(concurrent),
    MastersFileName = basho_bench_config:get(saturn_masters_file),
    GraphFileName = basho_bench_config:get(saturn_graph_file),

    ClocksName = list_to_atom(integer_to_list(Id) ++ atom_to_list(clocks)),
    Clocks = ets:new(ClocksName, [set, named_table]),

    {ok, MastersFile} = file:open(MastersFileName, [read]),
    Name1 = list_to_atom(integer_to_list(Id) ++ atom_to_list(masters)),
    Masters = ets:new(Name1, [set, named_table]),
    {ok, Members} = get_masters_from_file(MastersFile, Masters, Clocks, MyDc, Concurrent, Id),
    file:close(MastersFile),

    {ok, GraphFile} = file:open(GraphFileName, [read]),
    Name2 = list_to_atom(integer_to_list(Id) ++ atom_to_list(friends)),
    Friends = ets:new(Name2, [set, named_table]),
    ok = get_friends_from_file(GraphFile, Friends, Members),
    file:close(GraphFile),

    case net_kernel:start(MyNode) of
        {ok, _} ->
            ?INFO("Net kernel started as ~p\n", [node()]);
        {error, {already_started, _}} ->
            ?INFO("Net kernel already started as ~p\n", [node()]),
            ok;
        {error, Reason} ->
            ?FAIL_MSG("Failed to start net_kernel for ~p: ~p\n", [?MODULE, Reason])
    end,

    Cookie = basho_bench_config:get(saturn_cookie),
    true = erlang:set_cookie(node(), Cookie),
    {ok, #state{nodes=Nodes,
                clocks=Clocks,
                mydc=MyDc,
                number_keys=NumberKeys,
                masters=Masters,
                concurrent=Concurrent,
                friends=Friends,
                total_buckets=TotalBuckets,
                id=Id}}.

get_masters_from_file(Device, Table, Clocks, MyDc, Concurrent, Id) ->
    case file:read_line(Device) of
        eof ->
            {error, not_found};
        {error, Reason} ->
            lager:error("Problem reading ~p file, reason: ~p", [masters_file, Reason]),
            {error, Reason};
        {ok, Line} ->
            [H|T] = string:tokens(hd(string:tokens(Line,"\n")), ","),
            {Key, []} = string:to_integer(H),
            case Key of
                MyDc ->
                    Total = length(T),
                    Slot = trunc(Total/Concurrent),
                    Init = ((Id-1)*Slot) + 1,
                    case MyDc of
                        Concurrent ->
                            Sublist = lists:sublist(T, Init, Total - Init);
                        _ ->
                            Sublist = lists:sublist(T, Init, Slot)
                    end,
                    {List, Length} = lists:foldl(fun(Elem, Acc) ->
                                                    {List0, Counter} = Acc,
                                                    {Int, []} = string:to_integer(Elem),
                                                    true = ets:insert(Table, {Counter, Int}),
                                                    true = ets:insert(Clocks, {Int, 0}),
                                                    {[Int|List0], Counter + 1}
                                    end, {[], 1}, Sublist),
                    true = ets:insert(Table, {length, Length-1}),
                    {ok, List};
                _ ->
                    get_masters_from_file(Device, Table, Clocks, MyDc, Concurrent, Id)
            end
    end.

get_friends_from_file(_Device, _Table, []) ->
    ok;

get_friends_from_file(Device, Table, Locals0) ->
    case file:read_line(Device) of
        eof ->
            {error, not_completed};
        {error, Reason} ->
            lager:error("Problem reading ~p file, reason: ~p", [friends_file, Reason]),
            {error, Reason};
        {ok, Line} ->
            [H|T] = string:tokens(hd(string:tokens(Line,"\n")), ","),
            {Key, []} = string:to_integer(H),
            case lists:member(Key, Locals0) of
                true ->
                    Locals1 = lists:delete(Key, Locals0),
                    List = lists:foldl(fun(Elem, List0) ->
                                        {Int, []} = string:to_integer(Elem),
                                        [Int|List0]
                                       end, [], T),
                    true = ets:insert(Table, {Key, {List, length(List)}}),
                    get_friends_from_file(Device, Table, Locals1);
                _ ->
                    get_friends_from_file(Device, Table, Locals0)
            end
    end.

run(read, _KeyGen, _ValueGen, #state{nodes=Nodes, clocks=Clocks, masters=Masters, friends=Graph, total_buckets=TotalBuckets, number_keys=NumberKeys}=S0) ->
    {ok, Id} = get_id(Masters),
    Op = random:uniform(9821),
    case Op > 1756 of
        false ->
            Bucket = Id;
        true when Op > 6805 ->
            {ok, Bucket} = pick_friend_including_me(Graph, Id);
        true when Op > 9544 ->
            {ok, Bucket} = pick_friend(Graph, Id);
        true ->
            Bucket = random:uniform(TotalBuckets)
    end,
    Key = random:uniform(NumberKeys),
    BKey = {Bucket, Key},
    Node = lists:nth(random:uniform(length(Nodes)), Nodes), 
    [{Id, Clock0}] = ets:lookup(Clocks, Id),
    Result = rpc:call(Node, saturn_leaf, read, [BKey, Clock0]),
    case Result of
        {ok, {_Value, TimeStamp}} ->
            Clock1 = max(TimeStamp, Clock0),
            true = ets:insert(Clocks, {Id, Clock1}),
            {ok, S0};
        Else ->
            {error, Else}
    end;

run(update, _KeyGen, _ValueGen, #state{nodes=Nodes, clocks=Clocks, masters=Masters, friends=Graph, number_keys=NumberKeys}=S0) ->
    {ok, Id} = get_id(Masters),
    Op = random:uniform(179),
    case Op > 14 of
        false ->
            Bucket = Id;
        true ->
            {ok, Bucket} = pick_friend(Graph, Id)
    end,
    Key = random:uniform(NumberKeys),
    BKey = {Bucket, Key},
    Node = lists:nth(random:uniform(length(Nodes)), Nodes), 
    [{Id, Clock0}] = ets:lookup(Clocks, Id),
    Result = rpc:call(Node, saturn_leaf, update, [BKey, value, Clock0]),
    case Result of
        {ok, Clock1} ->
            true = ets:insert(Clocks, {Id, Clock1}), 
            {ok, S0};
        Else ->
            {error, Else}
    end.

get_id(Masters) ->
    case ets:lookup(Masters, length) of
        [] ->
            {error, not_length_store};
        [{length, Length}] ->
            Pos = random:uniform(Length),
            [{Pos, Id}] = ets:lookup(Masters, Pos),
            {ok, Id}
    end.

pick_friend_including_me(Graph, MyId) ->
    case ets:lookup(Graph, MyId) of
        [] ->
            {error, not_in_graph};
        [{MyId, {List, Length}}] ->
            Pos = random:uniform(Length+1),
            case Pos == Length+1 of
                true ->
                    {ok, MyId};
                false ->
                    {ok, lists:nth(Pos, List)}
            end
    end.

pick_friend(Graph, MyId) ->
    case ets:lookup(Graph, MyId) of
        [] ->
            {error, not_in_graph};
        [{MyId, {List, Length}}] ->
            Pos = random:uniform(Length),
            {ok, lists:nth(Pos, List)}
    end.