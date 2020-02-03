// Gmsh project created on Mon May 20 09:33:32 2019
//+
Point(1) = {0, 4, 0, 2.0};
Point(2) = {0, 10, 0, 2.0};
Point(3) = {26, 10, 0, 2.0};
Point(4) = {26, 4, 0, 2.0};

Point(5) = {4, 4, 5, 2.0};
Point(6) = {4, 10, 5, 2.0};

Point(7) = {22, 10, 5, 2.0};
Point(8) = {22, 4, 5, 2.0};


Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Curve Loop(5) = {1, 2, 3, 4};

Plane Surface(6) = {5};

Extrude {0, 0, 5} {
  Surface{6}; 
}

Line(23) = {14, 7};
Line(24) = {7, 8};
Line(25) = {8, 18};

Curve Loop(6) = {10, 23, 24, 25};

Plane Surface(20) = {6};


Extrude {0, 0, 10} {
  Surface{7}; 
}