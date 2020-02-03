// Gmsh project created on Mon May 20 09:33:32 2019
//+
Point(1) = {0, 0, 0, 2.0};
Point(2) = {0, 10, 0, 2.0};
Point(3) = {26, 10, 0, 2.0};
Point(4) = {26, 0, 0, 2.0};
Point(5) = {20, 0, 0, 2.0};
Point(6) = {20, 4, 0, 2.0};
Point(7) = {6, 4, 0, 2.0};
Point(8) = {6, 0, 0, 2.0};



Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 1};

Curve Loop(9) = {1, 2, 3, 4, 5, 6, 7, 8};

Plane Surface(10) = {9};


      //Transfinite surface:
	Transfinite Surface {10};
	Recombine Surface {10};

 
	surfaceVector[] = Extrude {0, 0, 10} {
	 Surface{10};
	 Layers{5};
	 Recombine;
	};

// Physical Surface("top") = {27};
