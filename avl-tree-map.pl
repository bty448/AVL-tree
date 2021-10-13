%node(Key, Val, LSon, RSon, H, Size)

max(A, B, A) :- B =< A, !.
max(A, B, B) :- A < B, !.

get_h(null, -1) :- !.
get_h(node(_, _, _, _, H, _), H).
get_size(null, 0) :- !.
get_size(node(_, _, _, _, _, Size), Size).
get_balance(node(_, _, LSon, RSon, _, _), Bal) :-
	get_h(LSon, LH),
	get_h(RSon, RH),
	Bal is RH - LH.

node_ctor(Key, Val, LSon, RSon, node(Key, Val, LSon, RSon, H, Size)) :-
	get_h(LSon, LH),
	get_h(RSon, RH),
	get_size(LSon, LSize),
	get_size(RSon, RSize),
	max(LH, RH, MH),
	H is MH + 1,
	Size is LSize + RSize + 1.

rotate_left(node(Key, Val, LSon, node(RKey, RVal, RLSon, RRSon, _, _), _, _), R) :-
	node_ctor(Key, Val, LSon, RLSon, NewLSon),
	node_ctor(RKey, RVal, NewLSon, RRSon, R).

rotate_right(node(Key, Val, node(LKey, LVal, LLSon, LRSon, _, _), RSon, _, _), R) :-
	node_ctor(Key, Val, LRSon, RSon, NewRSon),
	node_ctor(LKey, LVal, LLSon, NewRSon, R).

balance(Node, Node) :-
	get_balance(Node, Bal),
	Bal > -2, Bal < 2, !.
	
balance(node(Key, Val, LSon, RSon, H, Size), R) :-
	get_balance(node(Key, Val, LSon, RSon, H, Size), Bal),
	Bal = 2,
	get_balance(RSon, RBal),
	RBal < 0, !,
	rotate_right(RSon, NewRSon),
	node_ctor(Key, Val, LSon, NewRSon, NewNode),
	rotate_left(NewNode, R).

balance(Node, R) :-
	get_balance(Node, Bal),
	Bal = 2,
	rotate_left(Node, R).
	
balance(node(Key, Val, LSon, RSon, H, Size), R) :-
	get_balance(node(Key, Val, LSon, RSon, H, Size), Bal),
	Bal = -2,
	get_balance(LSon, LBal),
	LBal > 0, !,
	rotate_left(LSon, NewLSon),
	node_ctor(Key, Val, NewLSon, RSon, NewNode),
	rotate_right(NewNode, R).

balance(Node, R) :-
	get_balance(Node, Bal),
	Bal = -2,
	rotate_right(Node, R).

map_get(node(Key, Val, _, _, _, _), Key, Val) :- !.

map_get(node(VKey, _, LSon, _, _, _), Key, Val) :-
	Key < VKey,
	map_get(LSon, Key, Val).

map_get(node(VKey, _, _, RSon, _, _), Key, Val) :-
	Key > VKey,
	map_get(RSon, Key, Val).

map_put(null, Key, Val, node(Key, Val, null, null, 0, 1)) :- !.

map_put(node(Key, VVal, LSon, RSon, H, Size), Key, Val, node(Key, Val, LSon, RSon, H, Size)) :- !.

map_put(node(VKey, VVal, LSon, RSon, _, _), Key, Val, R) :-
	Key < VKey, !,
	map_put(LSon, Key, Val, NewLSon),
	node_ctor(VKey, VVal, NewLSon, RSon, NewNode),
	balance(NewNode, R).

map_put(node(VKey, VVal, LSon, RSon, _, _), Key, Val, R) :-
	Key > VKey, !,
	map_put(RSon, Key, Val, NewRSon),
	node_ctor(VKey, VVal, LSon, NewRSon, NewNode),
	balance(NewNode, R).

map_remove(null, Key, null) :- !.

map_remove(node(VKey, Val, LSon, RSon, _, _), Key, R) :-
	Key < VKey,
	map_remove(LSon, Key, NewLSon),
	node_ctor(VKey, Val, NewLSon, RSon, NewNode),
	balance(NewNode, R).

map_remove(node(VKey, Val, LSon, RSon, _, _), Key, R) :-
	Key > VKey,
	map_remove(RSon, Key, NewRSon),
	node_ctor(VKey, Val, LSon, NewRSon, NewNode),
	balance(NewNode, R).

get_max(null, null) :- !.

get_max(node(Key, Val, LSon, null, H, Size), node(Key, Val, LSon, null, H, Size)) :- !.

get_max(node(_, _, _, RSon, _, _), Max) :- get_max(RSon, Max).

remove_max(null, null) :- !.

remove_max(node(_, _, LSon, null, _, _), LSon) :- !.

remove_max(node(Key, Val, LSon, RSon, _, _), R) :-
	remove_max(RSon, NewRSon),
	node_ctor(Key, Val, LSon, NewRSon, NewNode),
	balance(NewNode, R).

map_remove(node(Key, _, null, RSon, _, _), Key, RSon) :- !.

map_remove(node(Key, _, LSon, RSon, _, _), Key, R) :- 
	get_max(LSon, node(MKey, MVal, MLSon, MRSon, _, _)),
	remove_max(LSon, NewLSon),
	node_ctor(MKey, MVal, NewLSon, RSon, NewNode),
	balance(NewNode, R).
	
map_build([], null) :- !.

map_build([(HKey, HVal) | T], R) :-
	map_build(T, Node),
	map_put(Node, HKey, HVal, R).

map_headMapSize(null, ToKey, 0) :- !.

map_headMapSize(node(Key, Val, LSon, RSon, H, Size), ToKey, R) :-
	ToKey =< Key,
	map_headMapSize(LSon, ToKey, R).

map_headMapSize(node(Key, Val, LSon, RSon, H, Size), ToKey, R) :- 
	ToKey > Key,
	map_headMapSize(RSon, ToKey, RRes),
	get_size(LSon, LSize),
	R is RRes + LSize + 1.

map_tailMapSize(null, FromKey, 0) :- !.

map_tailMapSize(node(Key, Val, LSon, RSon, H, Size), FromKey, R) :-
	FromKey > Key,
	map_tailMapSize(RSon, FromKey, R).

map_tailMapSize(node(Key, Val, LSon, RSon, H, Size), FromKey, R) :- 
	FromKey =< Key,
	map_tailMapSize(LSon, FromKey, LRes),
	get_size(RSon, RSize),
	R is LRes + RSize + 1.
	
