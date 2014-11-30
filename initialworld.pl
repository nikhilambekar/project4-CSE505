% Initial State
% path (Source, Destination, Cost, Weather).
path(a, e, 5, sunny).
path(e, d, 10, rainy).
path(d, c, 3, sunny).
path(b, c, 4, rainy).
path(a, b, 2, sunny).
path(a, d, 12, sunny).
path(b, d, 8, sunny).
path(c, e, 3, sunny).
path(X, Y, Dist):- path(Y, X, Dist).

% package(e, b, 		   
bus(b,a,2).
bus(a,d,4).
bus(d,e,6).
bus(e,c,2).

% Variables
taxiRate(2).
walkLimit(15).

package(a, d).
package(a, e).
package(b, e).

% End - initial state

taxi(X, Y, Cost):- path(X, Y, Dist, _), taxiRate(Rate), Cost is D * Rate.

getallpathsMain(Start, End,Visited, Cost):-
	aggregate(min(C,V),getallpaths(Start, End, [Start], 0, V, C),min(Cost,Visited)).

getallpaths(Start, End, InterPaths, DistAcc, Visited, TotDist):-
	path(Start, End, Distance, _),
	reverse([End|InterPaths], Visited),
	TotDist is DistAcc + Distance.

getallpaths(Start, End, InterPaths, DistAcc, Visited, TotDist):-
	path(Start, InterPoint, Dist, _),
	not (member(InterPoint, InterPaths)),
	NewDistAcc is DistAcc + Dist,
	getallpaths(InterPoint, End, [InterPoint|InterPaths], NewDistAcc, Visited, TotDist).
