/*
  crystal solids via Miller indices 
  
   Kit Wallace June 2015
   
*/



function flatten(l) = [ for (a = l) for (b = a) b ] ;

function vcontains(val,list) =
     search([val],list)[0] != [];
       
function distinct(list,dlist=[],i=0) =  // return only distinct items of list
      i==len(list)
         ? dlist
         : vcontains(list[i],dlist)
             ? distinct(list,dlist,i+1)
             : distinct(list,concat(dlist,[list[i]]),i+1)
      ;

function perm3(l) =
// lazy until I code gemeral perms with duplicates
 distinct(
   [[l[0],l[1],l[2]],
   [l[0],l[2],l[1]],
   [l[1],l[0],l[2]],
   [l[1],l[2],l[0]],
   [l[2],l[0],l[1]],
   [l[2],l[1],l[0]]
]);
        
function combs(list,n=0) =
   n < len(list)-1
   ? [for (j=list[n])
       for (sl= combs(list,n+1))
           concat(j,sl)
     ]
   : list[n] ;
 
function full_miller(list) =
  [for (x= list)
      x== 0 ? 0 : [x,-x]
  ];

function opposite(face) =
   [for (a=face) 
       a==0 ?0 : - a];
   
function full_symmetry(list) =
  flatten([for (comb = combs(full_miller(list)))
      perm3(comb)
  ]);

function pinacoid(face) =
    [ face,opposite(face)];
  
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

module facet(normal, d=1, size=20) {
   orient_to([0,0,0],normal)
       translate([0,0, d + size/2])
            cube(size,center=true);
} 

module form(facets,size=1,color="green") {
// Scan through the crystal facets (with the unit plane normals in cartesian coords)
 color(color)
    difference() {
     cube(20,center=true);
     for(f = facets)  
       facet(f,size);
 }
}


cube = full_symmetry([0,0,1]);
octa = full_symmetry([1,1,1]);  // octahedron
th= full_symmetry([0,1,2]);  // tetrakis hexahedron
rd= full_symmetry([0,1,1]);  // rhombic dodecahedron
di= full_symmetry([1,1,2]);
dd =full_symmetry([1,2,3]);  // dysdakis dodecahedron



tp1 = [[1,1,0],[1,-1,0],[-1,1,0],[-1,-1,0]]; 
tp2= [[1,0,0],[0,1,0],[-1,0,0],[0,-1,0]];

// form {00k}  is a cube
// tetrakis hexahedron has form {0hk}  so any values of h and k make ths shape
// form {01k}  is
//       k = 0  cube
//       k < 1  tetrakis hexahedron
//       k = 1  rhombic dodecahedron
//       k > 1  tetrakis hexahedron
//form {11k} 
// where  
//         k = 0 rhombic dodecahedron
//         k < 1 tetrakis ocatahedron
//         k = 1 octahedron
//         k > 1 deltoid icosatetrahedron
// form {jkl} where jkl all different = dysdakis dodecahedron


k=2*$t;

//florite 
/*
k=0.81;

scale(20)
intersection () {
   form(cube,k,"red");    =//octahedron
   form(dd,1,"green");   // disdyakis dodecahedron
}

*/

// zircon
scale(20)
intersection(){
     form(tp1,color="red");
     scale([1,1,3]) form(octa,color="green");
     scale(1.5) form(octa,color="blue");
}
