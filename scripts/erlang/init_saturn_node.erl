-module(init_saturn_node).
-export([init/1,
         test1/1]).

init([NodeString, TypeString, IdString, NLeafsString | ListOfNodes]) ->
    NLeafs = list_to_integer(NLeafsString),
    NodeNames = generate_node_names(NLeafs, ListOfNodes),
    Node = list_to_atom(NodeString),
    Type = list_to_atom(TypeString),
    Id = list_to_integer(IdString),
    Port = 4042,
    case Type of
	    internals ->
	        {ok, _} = rpc:call(Node, saturn_internal_sup, start_internal, [Port, Id]);
	    leafs ->
	        {ok, _} = rpc:call(Node, saturn_leaf_sup, start_leaf, [Port, Id]),
	        ok = rpc:call(Node, saturn_leaf_producer, check_ready, [Id])
    end,
    % This should eventually be done through a fiile.
    %Tree0 = dict:store(0, [-1, 300, 50], dict:new()).
    %Tree1 = dict:store(1, [300, -1, 70], Tree0). 
    %Tree2 = dict:store(2, [50, 70, -1], Tree1).
    %Groups0 = dict:store(1, [0, 1], dict:new()).
    %rpc:call(Node, groups_manager_serv, set_treedict, [Tree2, NLeafs]),
    %rpc:call(Node, groups_manager_serv, set_groupsdict,[Groups0]),
    ping_all(Node, NodeNames).

test1([_Node, _Type, _Id, NLeafs | Nodes]) ->
    NodeNames = generate_node_names(list_to_integer(NLeafs), Nodes),
    io:format("nodelist ~p~n", [NodeNames]).

ping_all(_Node, []) ->
    ok;
	
ping_all(Node, [H|Rest]) ->
    pong = rpc:call(Node, net_adm, ping, [H]),
    ping_all(Node, Rest).

generate_node_names(NLeafs, Nodes) ->
    {_ , FinalList} = lists:foldl(fun(Node, {Counter, Acc}) ->
                                    case (Counter > NLeafs) of
                                        true ->
                                            Id = integer_to_list(Counter - NLeafs),
                                            {Counter + 1, Acc ++ [list_to_atom("internals"++Id++"@"++Node)]};
                                        false ->
                                            Id = integer_to_list(Counter),
                                            {Counter + 1, Acc ++ [list_to_atom("leafs"++Id++"@"++Node)]}
                                    end
                                  end, {1, []}, Nodes),
    FinalList.
                                    