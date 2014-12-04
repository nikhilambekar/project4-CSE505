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
edge(X,Y,D) :- path(X,Y,D,_),!.
edge(X,Y,D) :- path(Y,X,D,_),!.

%  		   
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

% Check if List is Empty
isEmpty([]):-true.

min(X,Y,Z):-(X<Y->Z is X; Z is Y).

%Call to get nearest node to start with if no packages from current node
getMinimumAdjEdge(X,Y,D):-aggregate(min(D1,Y1),edge(X,Y1,D1),min(D,Y)).

%Check if walk is possible between given nodes X,Y
walk(X, Y):- edge(X,Y,Dist),(path(X,Y,Dist,W)->W\=rainy;path(Y,X,Dist,W),W\=rainy),walkLimit(D),D>Dist.

%Calculate the fare for taxi between X, Y 
taxi(X, Y, Cost):- edge(X, Y, Dist), taxiRate(Rate), Cost is Dist * Rate.

%Calculate the minimum fare among walk,taxi,bus
%if walk not possible bus or taxi will be selected and the corresponding fare is returned
minpathcost(X,Y,C):-(walk(X,Y)->C is 0; (bus(X,Y,C1)->(taxi(X,Y,C2),min(C1,C2,C));taxi(X,Y,C))).

%All packages available in the list.
allPackagelist(L):-findall((X,Y),package(X,Y),L).

%All packages with source X.
packagelist(X,L):-findall((X,Y),package(X,Y),L).

% Action Performed on delivery.Remove all packages with person which has destination as node Y and add to list the packages originating from Y
delivered(Y,L,FL):-delete(L,(_,Y),L1),packagelist(Y,L2),union(L1,L2,FL).

% Get all packets in List ending with Some node
getEndingWith(End,L,IL):-findall((X,End),member((X,End),L),IL).

% Main function to determine the shortest path through all packages
paths(Start,Visited, Cost,TotalFare):-
allPackagelist(FinalList),aggregate(min(C,V),(tour(Start, End, V, C,[],FL,TotalFare,FinalList,FinalListRemaining)),min(Cost,Visited)),!.

% Function to get all paths through all nodes of the delivery and pickup list
% A starting node is provided recursively cost and paths is calculated


% If no package is available from the given start node,the nearest node is picked and continued
tour(Start,Dest,Visited,Cost,L,FL,TotalFare,FinalList,FinalListRemaining):- \+ package(Start,_),getMinimumAdjEdge(Start,H,D),tour(H,Dest,V1,C1,L1,FL1,TotalFare1,FinalList,FinalListRemaining),Cost is C1+D, minpathcost(Start,H,Fare), TotalFare is Fare+TotalFare1, append([Start],V1,Visited).

tour(Start,Dest,Visited,Cost,L,FL,TotalFare,FinalList,FinalListRemaining):- 
package(Start,Int),
(package(Int,X)->
(	allPaths(Start, Int,Visited1,Cost1,L,L1,TotalFare1,FinalList,FinalListRemainingInt),
	tour(Int,Dest,[H|Visited2],Cost2,L1,FL,TotalFare2,FinalListRemainingInt,FinalListRemaining)
)	;
(	allPaths(Start, Int,Visited1,Cost1,L,L1,TotalFare1,FinalList,FinalListRemainingInt),
	(isEmpty(FinalListRemainingInt)->(
		Visited2 = [],
		append(FinalListRemainingInt,[],FinalListRemaining),
		Cost2 = 0,
		TotalFare2 = 0,
		append(L1,[],FL))
		;(member((X,Y),FinalListRemainingInt),!,
		tour(X,Y,Visited2,Cost2,L1,FL,TotalFare2,FinalListRemainingInt,FinalListRemaining)
		)
	)
)
),
append(Visited1,Visited2,Visited),
Cost is Cost1+Cost2,
TotalFare is TotalFare1+TotalFare2.


allPaths(Start, End,Visited, Cost,List,FL,TotalFare,FinalList,FinalListRemaining):-
aggregate(min(C,V),getallpathsMain(Start, End, V, C,List,FL,TotalFare,FinalList,FinalListRemaining),min(Cost,Visited)).

getallpathsMain(Start, End,Visited, Cost,L,FL,TotalFare,FinalList,FinalListRemaining):-
	packagelist(Start,List),union(L,List,List1),getallpaths(Start, End, [Start], 0, Visited, Cost,List1,FL,0,TotalFare,FinalList,FinalListRemaining).

% Get all paths to nodes from start to node
getallpaths(Start, End, InterPaths, DistAcc, Visited, TotDist,L,IL,Fare,TotalFare,FinalList,FinalListRemaining):-
	edge(Start, End, Distance),
	reverse([End|InterPaths], Visited),
	getEndingWith(End,L,IntList),
	delivered(End,L,IL),
	minpathcost(Start,End,IntFare),
	subtract(FinalList,IntList,FinalListRemaining),
	TotDist is DistAcc + Distance,
	TotalFare is IntFare+Fare.


% Get all paths to nodes from start to node if no direct node from start to end
getallpaths(Start, End, InterPaths, DistAcc, Visited, TotDist,L,IL,Fare,TotalFare,FinalList,FinalListRemaining):-
	edge(Start, InterPoint, Dist),
	\+ member(InterPoint, InterPaths),
	minpathcost(Start,InterPoint,IntFare),
	NewDistAcc is DistAcc + Dist,
	NewFare is Fare + IntFare,
	getEndingWith(InterPoint,L,IntList),
	subtract(FinalList,IntList,FinalListInt),
	delivered(InterPoint,L,FL),
	getallpaths(InterPoint, End, [InterPoint|InterPaths], NewDistAcc, Visited, TotDist,FL,IL,NewFare,TotalFare,FinalListInt,FinalListRemaining).