/* One more initial state
   Refer to shortest-path.png

path(a, b, 15, _).
path(b, h, 12, _).
path(h, i, 11, _).
path(i, d, 99, _).
path(d, a, 5, _).
path(a, c, 13, _).
path(c, b, 2, _).
path(d, c, 18, _).
path(b, f, 8, _).
path(f, h, 17, _).
path(c, f, 6, _).
path(f, g, 16, _).
path(h, g, 7, _).
path(g, i, 10, _).
path(e, d, 4, _).
path(e, c, 3, _).
path(e, f, 1, _).
path(e, g, 9, _).
path(e, i, 14, _).
path(X, Y, Dist):- path(Y, X, Dist).

taxiRate(2).
walkLimit(15).

package(a, g).
package(a, e).
package(g, b).
   */

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
