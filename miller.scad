/*
  crystal solids via Miller indices 
  
   see http://kitwallace.tumblr.com/tagged/crystal 
   
   Kit Wallace June 2015
   
   done 
      redone the face rendering
      distinct over a whole form
      random forms
      alternate_symmetry
      parity_symmetry
      more crystals
      
   todo 
      hex cones for corundum
      
*/
tau = (1 + sqrt(5))/2;
  
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

module solid(faces,d=1,color="lightblue",size=40) {
 /* faces is a list of normals (Miller indices)
    d is either a scaler, the distance of each face from the origin or a list of distances, one for each face
 */  
 color(color)
    difference() {
     sphere(size,center=true);
     for(i = [0:len(faces)-1])  {
       face = faces[i];
       fd = len(d) == undef ? d : d[i];
       face(face,d=fd,size=size);
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

function rotate(face) =
    [face[1],face[2],face[0]];
       
function cycle(face) =
    [face,rotate(face),rotate(rotate(face))];
       
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
  
function alternate_symmetry(list) =
   distinct(flatten([for (face = cycle(list)) combs(expand(face))]));
       
function sum(list,i=0) =  
      i < len(list)
        ?  (list[i] + sum(list,i+1))
        :  0;

function parity(face) =
    let(parity = sum( [for (i=face) i > 0 ? 1 : 0]))
    parity % 2 == 0 ;
 
function half_symmetry(list,even=true) =
    let(fs=full_symmetry(list))
    [for (i=fs) if (parity(i) == even ) i]; 

function pinacoid(face) =  [ face,opposite(face)];   
//  forms 

cube = full_symmetry([0,0,1]);
octahedron = full_symmetry([1,1,1]);  
hexatetrahedron= full_symmetry([0,1,2]);  
rhombic_dodecahedron= full_symmetry([0,1,1]);   
deltoid_icosahedron= full_symmetry([1,1,2]); 
dysdakis_dodecahedron =full_symmetry([1,2,3]); 

tetrahedral_prism_1 = [[1,1,0],[1,-1,0],[-1,1,0],[-1,-1,0]];   
tetrahedral_prism_2= [[1,0,0],[0,1,0],[-1,0,0],[0,-1,0]];    
function ty1(k=1) =[[1,1,k],[1,-1,k],[-1,1,k],[-1,-1,k]];   // tetrahedral prism 
function ty2(k=1) =[[1,0,k],[0,1,k],[-1,0,k],[0,-1,k]];     // tetrahedral pyramid
function hy(k=1) =concat(ty1(k),ty2(k/1.414));              // octagonal pyramid
function hex_prism(k=tan(60)) = [[k,1,0],[0,1,0],[-k,1,0],[-k,-1,0],[0,-1,0],[k,-1,0]];
    
tetrahedron_r = half_symmetry([1,1,1],true);
tetrahedron_l = half_symmetry([1,1,1],false);

pyritohedron = alternate_symmetry([0,1,2]);
dodecahedron = alternate_symmetry([0,1,tau]);
diakis_dodecahedron = alternate_symmetry([1,2,3]);
icosahedron = concat(full_symmetry([1,1,1]),alternate_symmetry([0,tau,1/tau]));

// crystals 

module fluorite_1(d_cube,d_dd) {
  intersection () {
      solid(cube,d_cube,"red");    
      solid(dysdakis_dodecahedron,d_dd,"green");   
  }
}

module zircon () {
  intersection(){
     solid(tetrahedral_prism_1,color="red");
     scale([1,1,3]) solid(octahedron,color="green");
     scale(1.5) solid(octahedron,color="blue");
  }
}

module garnet(d_di,d_rd) {
  intersection () {
    solid(deltoid_icosahedron,d=d_di,color="red");
    solid(dysdakis_dodecahedron,d=d_rd,color="green");
  }     
}

module random_cube_octahedron(d_cube,d_octa) {
   intersection() {
     solid (cube,d=d_cube,color="green");
     solid (octahedron,d=d_octa,color="red") ;
   }
}

module r_octahedron(d_octa) {
    solid(octahedron,d=d_octa);  
}

module r_rhombic_dodecahedron(d_rd) {
    solid(rhombic_dodecahedron,d=d_rd);  
}


// sample crystals
module sphalerite(d_tetra1=1,d_tetra2=0.8) {
  intersection() {    
    solid(tetrahedron_l,d_tetra1,color="red");
    solid(tetrahedron_r,d=d_tetra2,color="green");
  }
}

module boracite(d_cube=0.8,d_rd=1,d_tetra2=1) {
  intersection() {    
    solid(cube,d=d_cube,color="green");
    solid(rhombic_dodecahedron,d=d_rd,color="red");
    solid(tetrahedron_r,d=d_tetra2,color="orange");
  }
}

module tetrahedrite() {
  intersection() {
    solid(half_symmetry([3,3,2]),1.03,"red");
    solid(full_symmetry([3,1,0]),1.2841,"green");
    solid(half_symmetry([2,1,1]),1,"pink");  
          // positive tetrakis tetrahedron
    solid(half_symmetry([2,1,1],false),1.535,"white");
          // negative tetrakis tetrahedron
    solid(half_symmetry([1,1,1]),1,"orange");  
          // positive tetrahedron
    solid(full_symmetry([1,1,0]),1.37,"blue");
    solid(full_symmetry([1,0,0]),1.09,"silver");  
  }   
}

module garnet() {
  intersection() {
    solid(full_symmetry([3,2,1]),1.04,"red");
    solid(full_symmetry([2,1,1]),1,"green");
    solid(full_symmetry([1,1,0]),1.047,"blue");
   }   
}

module fluorite_2() {
// http://www.smorf.nl/index.php?crystal=Fluorite_066
  intersection() {
    solid(full_symmetry([2,2,1]),1,"red");
    solid(full_symmetry([1,1,1]),1,"green");
    solid(full_symmetry([1,1,0]),0.97,"blue");
   }   
}

module galena() {
// http://www.smorf.nl/index.php?crystal=Galena_023 
   intersection () {
      solid(full_symmetry([2,2,1]),1,"red");
      solid(full_symmetry([1,0,0]),1.02,"green");
   } 
    
}

module pyrite_008() {
   intersection () {
      solid(alternate_symmetry([2,1,0]),1,"red");
      solid(full_symmetry([1,1,1]),0.76,"green");
   }   
}

// h=$t*2; echo (h);
// color([236, 170, 136]/256) scale(20) solid(alternate_symmetry([0,1,h]));

//echo(pyritohedron);

scale(20) boracite();
