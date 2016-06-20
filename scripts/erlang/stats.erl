-module(stats).
-export([dump_stats/1,
         cdf/1,
         cdf_eventual/1,
         dump_stats_eventual/1]).

dump_stats(ListOfNodes) ->
    lists:foldl(fun(Node, Counter) ->
                    Id = integer_to_list(Counter),
                    NodeName=list_to_atom("leafs"++Id++"@"++Node),
                    io:format("rpc:call(~p, saturn_leaf, collect_stats, [~p]\n)", [NodeName, Counter-1]),
                    {ok, Data} = rpc:call(NodeName, saturn_leaf, collect_stats, [Counter-1]),
                    %{ok, Data} = rpc:call(NodeName, saturn_leaf_converger, dump_stats, [Counter-1, NLeaves]),
                    lists:foreach(fun(Sender) ->
                                    io:format("From ~p to ~p: ~p\n", [Sender, Counter-1, dict:fetch(Sender, Data)])
                                  end, dict:fetch_keys(Data)),
                    Counter+1
                 end, 1, ListOfNodes).

cdf([LeafString, FromString, TypeString | Leafs]) ->
    Leaf = list_to_integer(LeafString),
    From = list_to_integer(FromString),
    Node = lists:nth(Leaf+1, Leafs),
    NodeName=list_to_atom("leafs"++integer_to_list(Leaf+1)++"@"++Node),
    {ok, Data} = rpc:call(NodeName, saturn_leaf, collect_stats, [Leaf, From, list_to_atom(TypeString)]),
    io:format("From ~p to ~p (~p): ~p\n", [From, Leaf, TypeString, Data]).

cdf_eventual([LeafString, FromString, TypeString | Leafs]) ->
    Leaf = list_to_integer(LeafString),
    From = list_to_integer(FromString),
    Node = lists:nth(Leaf+1, Leafs),
    NodeName=list_to_atom("leafs"++integer_to_list(Leaf+1)++"@"++Node),
    {ok, Data} = rpc:call(NodeName, saturn_leaf, collect_stats, [From, list_to_atom(TypeString)]),
    io:format("From ~p to ~p (~p): ~p\n", [From, Leaf, TypeString, Data]).
    

dump_stats_eventual(ListOfNodes) ->
    lists:foldl(fun(Node, Counter) ->
                    Id = integer_to_list(Counter),
                    NodeName=list_to_atom("leafs"++Id++"@"++Node),
                    io:format("rpc:call(~p, saturn_leaf, collect_stats, []\n)", [NodeName]),
                    {ok, Data} = rpc:call(NodeName, saturn_leaf, collect_stats, []),
                    %{ok, Data} = rpc:call(NodeName, saturn_leaf_converger, dump_stats, [Counter-1, NLeaves]),
                    lists:foreach(fun(Sender) ->
                                    io:format("From ~p to ~p: ~p\n", [Sender, Counter-1, dict:fetch(Sender, Data)])
                                  end, dict:fetch_keys(Data)),
                    Counter+1
                 end, 1, ListOfNodes).
