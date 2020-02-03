// Gmsh project created on Mon May 20 09:33:32 2019
//+
Point(1) = {0, 4, 0, 2.0};
Point(2) = {0, 10, 0, 2.0};
Point(3) = {26, 10, 0, 2.0};
Point(4) = {26, 4, 0, 2.0};

Point(5) = {26, 0, 0, 2.0};
Point(6) = {20, 0, 0, 2.0};
Point(7) = {20, 4, 0, 2.0};

Point(8) = {6, 4, 0, 2.0};
Point(9) = {6, 0, 0, 2.0};
Point(10) = {0, 0, 0, 2.0};






Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 6};
Line(8) = {4, 1};

Curve Loop(9) = {1, 2, 3, 8};
Curve Loop(10) = {4,5,6,7};

Plane Surface(11) = {9};
Plane Surface(12) = {10};



      //Transfinite surface:
	Transfinite Surface {11};
	Recombine Surface {11};

      //Transfinite surface:
	Transfinite Surface {12};
	Recombine Surface {12};

 
	surfaceVector[] = Extrude {0, 0, 10} {
	 Surface{11,12};
	 Layers{5};
	 Recombine;
	};


 
// Physical Surface("top") = {27};
