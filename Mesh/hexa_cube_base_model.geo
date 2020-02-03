Point(1) = {0, 0, 0, 0.5};
Point(2) = {1, 0, 0, 0.5};
Point(3) = {1, 1, 0, 0.5};
Point(4) = {0, 1, 0, 0.5};
	Line(1) = {1, 2};				// bottom line
	Line(2) = {2, 3};				// right line
	Line(3) = {3, 4};				// top line
	Line(4) = {4, 1};				// left line
	Line Loop(5) = {1, 2, 3, 4}; 	
	Plane Surface(6) = {5};
 
        //Transfinite surface:
	Transfinite Surface {6};
	Recombine Surface {6};
 
	surfaceVector[] = Extrude {0, 0, 1} {
	 Surface{6};
	 Layers{2};
	 Recombine;
	};

  
  	