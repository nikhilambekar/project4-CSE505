% Initial State
% path (Source, Destination, Cost, Weather).
path(a, e, 5, sunny).
path(e, d, 10, rainy).
path(d, c, 13, sunny).
path(c, b, 4, rainy).
path(a, b, 2, sunny).
path(a, d, 12, sunny).
path(b, d, 8, sunny).
path(c, e, 3, sunny).


% package(e, b, 		   
bus(b,a,2).
bus(a,d,4).
bus(d,e,6).
bus(e,c,2).


% Variables
taxiRate(2).
walkLimit(5).

package(a, e).
package(e, d).
package(d, c).
package(c, b).

% End - initial state
min(X,Y,Z):-(X<Y->Z is X; Z is Y).

walk(X, Y):- path(X, Y, Dist, W),!,W\=rainy,walkLimit(D),D>Dist.
taxi(X, Y, Cost):- path(X, Y, Dist, _), taxiRate(Rate), Cost is Dist * Rate.

minpathcost(X,Y,C):-(walk(X,Y)->C is 0; (bus(X,Y,C1)->(taxi(X,Y,C2),min(C1,C2,C));taxi(X,Y,C))).

packagelist(X,L):-findall((X,Y),package(X,Y),L).
destList(L):-findall(Y,package(_,Y),L1),compress(L1,L).
delivered(Y,L,FL):-delete(L,(_,Y),L1),packagelist(Y,L2),union(L1,L2,FL).

deliver(X,Y,L):-package(X,Y),packagelist(X,L1),delete(L1,(X,Y),L2),(package(Y,Z)->pickup(Y,Z,L2,L3);true),union(L2,L3,L).
pickup(X,Y,L2,L3):-(package(X,Y)->union([(X,Y)],L2,L3);union([],L2,L3)).

paths(Start,Visited, Cost,FL,TotalFare):-%tour(Start, End, Visited, Cost,[],FL,TotalFare).
aggregate(min(C,V),(tour(Start, End, V, C,[],FL,TotalFare),destList(DL),subset(DL,V)),min(Cost,Visited)).

tour(Start,Dest,Visited,Cost,L,FL,TotalFare):- package(Start,Int),allPaths(Start, Int,Visited, Cost,L,FL,TotalFare),\+ package(Int,_).
tour(Start,Dest,Visited,Cost,L,FL,TotalFare):- package(Start,Int),allPaths(Start, Int,Visited1, Cost1,L,L1,TotalFare1),tour(Int,Dest,[H|Visited2],Cost2,L1,FL,TotalFare2),append(Visited1,Visited2,Visited),Cost is Cost1+Cost2,TotalFare is TotalFare1+TotalFare2.

allPaths(Start, End,Visited, Cost,List,FL,TotalFare):-
aggregate(min(C,V),getallpathsMain(Start, End, V, C,List,FL,TotalFare),min(Cost,Visited)).

getallpathsMain(Start, End,Visited, Cost,L,FL,TotalFare):-
	packagelist(Start,List),union(L,List,List1),getallpaths(Start, End, [Start], 0, Visited, Cost,List1,FL,0,TotalFare).

getallpaths(Start, End, InterPaths, DistAcc, Visited, TotDist,L,IL,Fare,TotalFare):-
	path(Start, End, Distance, _),
	reverse([End|InterPaths], Visited),
	delivered(End,L,IL),
	minpathcost(Start,End,IntFare),
	TotDist is DistAcc + Distance,
	TotalFare is IntFare+Fare.

getallpaths(Start, End, InterPaths, DistAcc, Visited, TotDist,L,IL,Fare,TotalFare):-
	path(Start, InterPoint, Dist, _),
	\+ member(InterPoint, InterPaths),
	minpathcost(Start,InterPoint,IntFare),
	NewDistAcc is DistAcc + Dist,
	NewFare is Fare + IntFare,
	delivered(InterPoint,L,FL),
	getallpaths(InterPoint, End, [InterPoint|InterPaths], NewDistAcc, Visited, TotDist,FL,IL,NewFare,TotalFare).

subset([ ],_).
subset([H|T],List) :-
    member(H,List),
    subset(T,List).

intersectionCount(X,Y,N):-
intersection(X,Y,L),count(L,N).
	
count([],0).
count([H|T],N):-
			count(T,N1),N is N1+1.
			
compress([],[]).
compress([X],[X]).
compress([X,X|Xs],Zs) :- compress([X|Xs],Zs).
compress([X,Y|Ys],[X|Zs]) :- X \= Y, compress([Y|Ys],Zs).
