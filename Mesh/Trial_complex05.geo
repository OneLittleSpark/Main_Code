// Gmsh project created on Wed May 22 09:04:06 2019
SetFactory("OpenCASCADE");
Point(1) = {0, 0, 0, 2.0};
//Point(2) = {0, 10, 0, 2.0};
//Point(3) = {25, 10, 0, 2.0};
Point(4) = {25, 0, 0, 2.0};
Point(5) = {20, 0, 0, 2.0};
//Point(6) = {20, 5, 0, 2.0};
//Point(7) = {5, 5, 0, 2.0};
Point(8) = {5, 0, 0, 2.0};

Point(9) = {20, 2, 0, 2.0};
Point(10) = {17, 5, 0, 2.0};
Point(11) = {8, 5, 0, 2.0};
Point(12) = {5, 2, 0, 2.0};
Point(13) = {17, 2, 0, 2.0};
Point(14) = {8, 2, 0, 2.0};

Point(15) = {0, 5, 0, 2.0};
Point(16) = {5, 10, 0, 2.0};
Point(17) = {20, 10, 0, 2.0};
Point(18) = {25, 5, 0, 2.0};
Point(19) = {5, 5, 0, 2.0};
Point(20) = {20, 5, 0, 2.0};



Line(1) = {1, 15};
Line(2) = {16, 17};
Line(3) = {18, 4};
Line(4) = {4, 5};
Line(5) = {5, 9};
Line(6) = {10, 11};
Line(7) = {12, 8};
Line(8) = {8, 1};


Circle(10) = {9, 13, 10};
Circle(11) = {11, 14, 12};

Circle(12) = {15, 19, 16};
Circle(13) = {17, 20, 18};


Curve Loop(9) = {1, 12, 2, 13, 3, 4, 5, 10, 6, 11, 7, 8};

Plane Surface(10) = {9};


      //Transfinite surface:
	//Transfinite Surface {10};
	Recombine Surface {10};

 
	surfaceVector[] = Extrude {0, 0, 10} {
	 Surface{10};
	 Layers{2};
	 Recombine;
	};

// Physical Surface("top") = {27};

//+
Recursive Delete {
  Point{19}; Point{14}; Point{13}; Point{20}; 
}
