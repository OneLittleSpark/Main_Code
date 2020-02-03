// Gmsh project created on Wed Sep 25 11:01:05 2019

Point(1) = {0, 0, 0, 1};
Point(2) = {1, 0, 0, 1};
Point(3) = {1, 1, 0, 1};
Point(4) = {0, 1, 0, 1};
	Line(1) = {1, 2};				// bottom line
	Line(2) = {2, 3};				// right line
	Line(3) = {3, 4};				// top line
	Line(4) = {4, 1};				// left line
	Line Loop(5) = {1, 2, 3, 4}; 	
	Plane Surface(6) = {5};
 
        //Transfinite surface:
	//Transfinite Surface {6};
	//Recombine Surface {6};
 
	surfaceVector[] = Extrude {0, 0, 4} {
	 Surface{6};
	 Layers{4};
	 Recombine;
	};


