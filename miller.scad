/*
  crystal solids via Miller indices 
  
   see http://kitwallace.tumblr.com/tagged/crystal 
   
   Kit Wallace June 2015
   
   done 
      redone the face rendering
      distinct over a whole form
      new minerals added
      random forms
      
   todo 
      hex cones for corundum
      
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

// solid construction
  
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

module face(normal, d=1, size=20) {
   orient_to([0,0,0],normal)
       translate([0,0, d + size/2])
            cube([10*size,10*size,size],center=true);
} 

module solid(faces,d=1,color="lightblue",size=20) {
 /* faces is a list of normals (Miller indices)
    d is either a scaler, the distance of each face from the origin or a list of distances, one for each face
 */  
 color(color)
    difference() {
     sphere(size,center=true);
     for(i = [0:len(faces)-1])  {
       fd = len(d) == undef ? d : d[i];
       face(faces[i],d=fd,size=size);
     }
 }
}

// perms and combs

function perm3(l) =
// lazy until I code general perms with duplicates
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

function expand(list) =   
// needs a better name
  [for (x= list)
      x== 0 ? 0 : [x,-x]
  ];

function opposite(face) =
   [for (a=face) 
       a==0 ? 0 : - a];
   
function full_symmetry(list) =
  distinct(flatten([for (comb = combs(expand(list)))
      perm3(comb)
  ]));


//  forms - not complete yet
function pinacoid(face) =  [ face,opposite(face)];

cube = full_symmetry([0,0,1]);
octa = full_symmetry([1,1,1]);  // octahedron
th= full_symmetry([0,1,2]);     // tetrakis hexahedron, tetrahexahedron(cy)
rd= full_symmetry([0,1,1]);     // rhombic dodecahedron
di= full_symmetry([1,1,2]);     // deltoid icosatetrahedron, trapezahedron (cy),  tetragon-trioctahedron(cy)
dd =full_symmetry([1,2,3]);     // dysdakis dodecahedron, 

tp1 = [[1,1,0],[1,-1,0],[-1,1,0],[-1,-1,0]];   // tetrahedral prism 
tp2= [[1,0,0],[0,1,0],[-1,0,0],[0,-1,0]];      // tetrahedral prism
function ty1(k=1) =[[1,1,k],[1,-1,k],[-1,1,k],[-1,-1,k]];   // tetrahedral prism 
function ty2(k=1) =[[1,0,k],[0,1,k],[-1,0,k],[0,-1,k]];     // tetrahedral pyramid
function hy(k=1) =concat(ty1(k),ty2(k/1.414));              // octagonal pyramid
tetra1=  [[1, 1, 1], [-1, -1, 1] ,[1, -1, -1], [-1, 1, -1]];  // tetrahedron - orientation 1
tetra2=  [[1, 1, -1], [1, -1, 1], [-1, 1, 1],  [-1, -1, -1]];  // tetrahedron - orientation 2
k=tan(60);
hex = [[k,1,0],[0,1,0],[-k,1,0],[-k,-1,0],[0,-1,0],[k,-1,0]];

// crystals 

module fluorite(d_cube,d_dd) {
  intersection () {
      solid(cube,d_cube,"red");    //octahedron
      solid(dd,d_dd,"green");   // disdyakis dodecahedron
  }
}

module zircon () {
  intersection(){
     solid(tp1,color="red");
     scale([1,1,3]) solid(octa,color="green");
     scale(1.5) solid(octa,color="blue");
  }
}

module garnet(d_di,d_rd) {
  intersection () {
    solid(di,d=d_di,color="red");
    solid(rd,d=d_rd,color="green");
  }     
}

module random_cube_octahedron(d_cube,d_octa) {
   intersection() {
     solid (cube,d=d_cube,color="green");
     solid (octa,d=d_octa,color="red") ;
   }
}

module r_octa(d_octa) {
    solid(octa,d=d_octa);  
}

module r_rd(d_rd) {
    solid(rd,d=d_rd);  
}

module r_th(d_rh) {
    solid(rd,d=d_th);  
}

module tetrahedrite(d_tetra=1,d_th) {
  intersection() {    
    solid(tetra2,d=d_tetra,color="red");
    solid(th,d=d_th,color="green");
  }
}

module sphalerite(d_tetra1,d_tetra2) {
  intersection() {    
    solid(tetra1,d_tetra1,color="red");
    solid(tetra2,d=d_tetra2,color="green");
  }
}

module boracite(d_cube,d_rd,d_tetra2) {
  intersection() {    
    solid(cube,d=d_cube,color="green");
    solid(rd,d=d_rd,color="red");
    solid(tetra2,d=d_tetra2,color="orange");
  }
}

// main

d_tetra1=1;
d_tetra2=rands(0.8,1.2,4);
scale(20) sphalerite(d_tetra1,d_tetra2);
