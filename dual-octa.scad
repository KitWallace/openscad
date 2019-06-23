use <arpruss-hull.scad>
a=1;
b=1.1;

octa1= 
[ [1, 1, 1]
, [1, 1, -1]
, [1, -1, 1]
, [1, -1, -1]
, [-1, 1, 1]
, [-1, 1, -1]
, [-1, -1, 1]
, [-1, -1, -1]
];
octa2= 
[ [b, 0, b]
, [b, 0, -b]
, [-b, 0, b]
, [-b, 0, -b]
, [0, b, b]
, [0, b, -b]
, [0, -b, b]
, [0, -b, -b]];

o1=dualHull_tri(octa1);
o2=dualHull_tri(octa2);

intersection() {
  color("red")
    polyhedron(o1[0],o1[1]);
  color("green") 
    polyhedron(o2[0],o2[1]);
}

comb= concat(octa1,octa2);

comb1=dualHull_tri(comb);
color("blue") 
   translate([6,0,0]) 
   polyhedron(comb1[0],comb1[1]);

   
comb2=dualHull(comb);
color("yellow") 
   translate([0,6,0]) 
   polyhedron(comb2[0],comb2[1]);

