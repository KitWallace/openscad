/*
  crystal solids via Miller indices 
  
   see http://kitwallace.tumblr.com/tagged/crystal 
   
   Kit Wallace October 2015
   
   systems
       cubic - complete 
       tetra  - only one class
   
   todo
      remaining classes
      deduce modifiers from crystal class   
      twinning
      get right/left or positive/negative terminology right 
*/

// some constants
PHI = (1 + sqrt(5))/2;

K=tan(60);

COLORS=["red","green","blue","gold","silver","pink","lightblue","orange","lightgreen","white"];

// basic functions

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

function sum(list,i=0) =  
      i < len(list)
        ?  list[i] + sum(list,i+1)
        :  0;

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

// functions to expand a form into faces using eg perms and combs

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

// face generators
  
function shift(face,k=1) = [face[k%3],face[(k+1)%3],face[(k+2)%3]];
       
function cycle(face) =
    [face,shift(face,1),shift(face,2)];

function full_symmetry(form) =
   distinct(flatten([for (comb = combs(expand(form))) perm3(comb)]));
  
function tetra_symmetry(form) =
   distinct(flatten([for (face = [form,[form[1],form[0],form[2]]]) combs(expand(face))]));

function gyroid_symmetry(form,even=true) =
    concat(parity_filter(distinct(flatten([for (face = cycle(form)) combs(expand(face))])),even),
           parity_filter(distinct(flatten([for (face = cycle([form[0],form[2],-form[1]])) combs(expand(face))])), ! even)
    );

function opposite(face) =
   [for (a=face) 
       a==0 ? 0 : - a];

function mirror(face) =  [ face,opposite(face)];   

function switch(face) = [face[1],face[0],face[2]];

function trapezohedral_symmetry(form) =
 concat(
    parity_filter(combs(expand(form)),form),
    parity_filter(combs(expand(switch(form))),mirror(form))
    );
           
 // filters
           
function parity(face) =
    let(parity = sum( [for (i=face) i > 0 ? 1 : 0]))
    parity % 2 == 0 ;
 
function parity_filter(faces,form) =
    [for (face=faces) if (parity(face) == parity(form) ) face]; 

function unsigned(face) = [abs(face[0]),abs(face[1]),abs(face[2])];

function same_order(form,face) = 
    form == face || form==shift(face) || form==shift(shift(face));

function order_filter(faces,form) =
    [for (face=faces) 
        if (same_order(unsigned(form),unsigned(face))) face
    ];
        
// face construction      
function filter_faces(form,faces,modifiers,i=0) =
    i < len(modifiers)
       ? let(filter=modifiers[i])
         let(filtered_faces =
             filter=="order"
             ? order_filter(faces,form)
             : filter=="parity" 
             ? parity_filter(faces,form)
             : faces)
         filter_faces(form,filtered_faces,modifiers,i+1)
       : faces;
          
function form_faces(form,base,modifiers) =
    let(base_faces = 
         base=="full" 
       ? full_symmetry(form)
       : base=="tetra" 
       ? tetra_symmetry(form)
       : base=="gyroid"
       ? gyroid_symmetry(form)
       : base=="trapezoid" 
       ? trapezohedral_symmetry(form)
       : base=="mirror"
       ? mirror(form)
       :  base=="pedion"
       ? form
       : form)
     let(faces = filter_faces(form,base_faces,modifiers) )
     faces;

// crystal rendering

module c_render(crystal,pert=0) {
    forms=crystal[1];
    intersection_for (i=[0:len(forms)-1]) 
       c_render_part(crystal,i,pert);
}

module c_render_part(crystal,k,pert=0) {
    data=crystal[0];
    forms=crystal[1];
    scale(data[1])  
      {
         form_spec=forms[k];     
         form=form_spec[0];
         d=form_spec[1];
         base = form_spec[2] == "" || form_spec[2] == undef  ?  data[2] : form_spec[2];
         modifiers=form_spec[3] == undef ? [] : form_spec[3] ;  
         name = form_spec[4] == undef ? "" :   form_spec[4];     
         color = COLORS[k]== undef ? "green" : COLORS[k];
         faces=form_faces(form,base,modifiers);  
         echo(name,color,form,d+pert*rands(0,1,1)[0],base,modifiers, len(faces));
         solid(faces,d,COLORS[k]);      
      }  
}

module c_animate(crystal) {
    n=len(crystal[1]);
    k=min(floor($t*n),n-1);
    c_render_part(crystal,k); 
}

// general classes 
// Cubic system

cubic_system = [
    ["cubic system",[1,1,1], "full"],
    [
      [[1,0,0],1,"",[],"cube"],
      [[1,1,0],1,"",[],"rhombdodecahedron"],
      [[1,2,0],1,"",[],"tetrahexahedron"],
      [[1,2,0],1,"",["order"],"pentagonal dodecahedron : right"],
      [[2,1,0],1,"",["order"],"pentagonal dodecahedron : left"],
      [[1,1,1],1,"",[],"octahedron"],
      [[1,1,1],1,"",["parity"],"tetrahedron :right"],
      [[1,-1,1],1,"",["parity"],"tetrahedron :left"],
      [[2,1,1],1,"",[],"icositetrahedron : hll h > l "],
      [[2,1,1],1,"",["parity"],"tristetrahedron : right"],
      [[2,-1,1],1,"",["parity"],"tristetrahedron: left"],
      [[2,2,1],1,"",[],"triakisoctahedron : hhl h > l "],
      [[2,2,1],1,"",["parity"],"deltoid dodecahedron :right"],
      [[2,-2,1],1,"",["parity"],"deltoid dodecahedron : left"],
      [[3,2,1],1,"",[],"hexoctahedron"],
      [[3,2,1],1,"",["order"],"diakisdodecahedron : right"],
      [[3,1,2],1,"",["order"],"diakisdodecahedron : left"],
      [[3,2,1],1,"",["parity"], "hexatetrahedron : right"],
      [[3,-2,1],1,"",["parity"], "hexatetrahedron : left"],
      [[3,2,1],1,"gyroid",[], "pentagonal icositetrahedron - actually 4 enantiomorphs"],
      [[3,2,1],1,"",["parity,order"],"tetrahedral pentagonal dodecaheron: right"],
      [[2,-3,1],1,"",["parity,order"],"tetrahedral pentagonal dodecaheron : left"]
    ]
];

class_m3m = [
// cubic holosymmetric, hexakis octheral. galena type
    ["class_m3m",[1,1,1],"full"],
    [
      [[1,0,0],1],  // cube
      [[1,1,0],1],  // rhombdodecahedron
      [[1,2,0],1],  // tetrahexahedron
      [[1,1,1],1],  // octahedron
      [[2,1,1],1],  // hll h > l icositetrahedron
      [[2,2,1],1],  // hhl h > l triakisoctahedron
      [[3,2,1],1]   // hexoctahedron
    ]
    ]; 
garnet = [
// http://www.smorf.nl/index.php?crystal=Garnet_84
  ["garnet",[1,1,1],"full","m3m"],
  [
    [[3,2,1],1.04],
    [[2,1,1],1],
    [[1,1,0],1.047]
  ]
];

fluorite_2 = [
// http://www.smorf.nl/index.php?crystal=Fluorite_066
   ["Fluorite",[1,1,1],"full","m3m"],
   [
    [[2,2,1],1],
    [[1,1,1],1],
    [[1,1,0],0.97]
   ] 
];

galena=
// http://www.smorf.nl/index.php?crystal=Galena_023 
   [
     ["Galena",[1,1,1],"full","m3m"],
     [
        [[2,2,1],1],
        [[1,0,0],1.02]
     ]
];


analcime_05 = [
   ["Analcime_05",[1,1,1],"full","m3m"],
   [
      [[3,2,2],0.99],
      [[2,1,1],1]
   ]   
];

class_m3 = [
// cubic diakisdodecahedral, pyrite type
    ["class_m3m",[1,1,1],"full"],
    [
      [[1,0,0],1],  // cube
      [[1,1,0],1],  // rhombdodecahedron
      [[1,2,0],1,"",["order"]],  // pentagonal dodecahedron
      [[2,1,0],1,"",["order"]],  // pentagonal dodecahedron
      [[1,1,1],1],  // octahedron
      [[2,1,1],1],  // hll h > l icositetrahedron
      [[2,2,1],1],  // hhl h > l triakisoctahedron
      [[3,2,1],1,"",["order"]],   // diakisdodecahedron
      [[3,1,2],1,"",["order"]]   // diakisdodecahedron
   ]
 ]; 

pyrite_008= [
   ["Pyrite_008",[1,1,1],"full","m3"],
   [
      [[2,1,0],1,"",["order"]],
      [[1,1,1],0.76]
   ]  
];

class_43m = [
// cubic hexakishedral
// tetrahedrite type

    ["class_-43m",[1,1,1],"full"],
    [
      [[1,0,0],1],  // cube
      [[1,1,0],1],  // rhombdodecahedron
      [[2,1,0],1],  // tetrahexahedron
      [[1,1,1],1,"",["parity"]],  // tetrahedron
      [[1,-1,1],1,"",["parity"]],  // tetrahedron
      [[2,1,1],1,"",["parity"]],  // tristetrahedron
      [[2,-1,1],1,"",["parity"]],  // tristetrahedron
      [[2,2,1],1,"",["parity"]],  // deltoid dodecahedron
      [[2,-2,1],1,"",["parity"]],  // deltoid dodecahedron
      [[1,2,3],1,"",["parity"]],  // hexatetrahedron
      [[1,-2,3],1,"",["parity"]]    // hexatetrahedron
   ]
 ];
 
 sphalerite= [
// http://www.smorf.nl/index.php?crystal=Sphalerite_MA1
   ["sphalerite",[1,1,1],"full","-43m"],
   [
      [[1,1,1],1,"",["parity"]],
      [[1,-1,1],0.5,"",["parity"]]
   ]
];

boracite = [
// http://www.smorf.nl/index.php?crystal=Boracite_02
    ["boracite", [1,1,1],"full","-43m"],
    [ [[1,0,0],1],
      [[0,1,1],1.2],
      [[1,1,1],1.3,"",["parity"]]
    ]
];

tetrahedrite= [
//  http://www.smorf.nl/index.php?crystal=Tetrahedrite_034
  ["Tetrahedrite",[1,1,1],"full","-43m"],
  [
    [[3,3,2],1.03,"",["parity"]],
    [[3,1,0],1.2841],
    [[2,1,1],1,"",["parity"]],      // positive tetrakis tetrahedron
    [[2,-1,1],1.535,"",["parity"]], // negative tetrakis tetrahedron
    [[1,1,1],1,"",["parity"]] ,     // positive tetrahedron
    [[1,1,0],1.37],
    [[1,0,0],1.09]
  ]
];

class_432 = [
// pentagonal icositetrahedral
    ["class_432",[1,1,1],"full","432"],
    [
      [[1,0,0],1],  //cube
      [[1,1,0],1],  // rhombdodecahedron
      [[1,2,0],1],  //tetrahexahedron
      [[1,1,1],1],  // octahedron
      [[2,1,1],1],  // hll h > l icositetrahedron
      [[2,2,1],1],  // hhl h > l triakisoctahedron
      [[1,1,2],1],  // triakisoctahedron
      [[1,2,3],1,"gyroid"],   // pentagonal icositetrahedron - actually 4 enantiomorphs
   ]
    ];    

cuprite= [
// http://www.smorf.nl/?crystal=Cuprite_D1
    ["Cuprite",[1,1,1],"full", "432"],
    [ [[1,0,0],1],
      [[1,1,1],1.15],
      [[9,8,6],1.2,"gyroid"]
    ]
 ];
 
class_23 = [
// tetrahedral pentagonal dodecahedral
    ["class_23",[1,1,1],"full","23"],
    [
      [[1,0,0],1],  //cube
      [[1,1,0],1],  // rhombdodecahedron
      [[1,2,0],1,"",["order"]],  // pentagonal dodecahedron
      [[3,1,0],1,"",["order"]],  // pentagonal dodecahedron
      [[1,1,1],1,"",["parity"]],  // tetrahedron
      [[1,-1,1],1,"",["parity"]],  // tetrahedron
      [[2,2,1],1,"",["parity"]],  // deltoid dodecahedron
      [[2,-2,1],1,"",["parity"]],  // deltoid dodecahedron
      [[3,2,1],1,"",["parity","order"]],   // tetrahedral pentagonal dodecaheron
      [[2,-3,1],1,"",["parity","order"]],   // tetrahedral pentagonal dodecaheron
   ]
    ]; 

// Tetrahedral system
// class 4/mmm Tetragonal holosymmetric, ditetragonal bipyramidal, zircon type
// after Bishop p104 ff
class_4mmm= [
     ["Class 4mmm",[1,1,1.2],"tetra","4/mmm"],
     [
       [[1,0,0],1],  //tetragonal prism - first order
       [[1,1,0],1],  //tetragonal prism - second order
       [[0,0,1],1,"mirror"],  //pinacoid 
       [[5,1,0],1],  // Ditetragonal prism {hk0]
       [[2,0,1],1],  //tetragonal bipyramid first order
       [[3,3,1],1],  //tetragonal bipyramid second order
       [[1,2,3],1]  // ditetragonal bipyramid
    ]
];

zircon = [
// http://webmineral.com/data/Zircon.shtml
// http://www.thingiverse.com/thing:833494
// estimated distances
     ["zircon",[1,1,1],"tetra","4mmm"],
     [
       [[1,1,0],0.8],
       [[1,1,1],1.3],
       [[3,3,1],1]
      ]
];

    
anatase_36 = [
    ["Anatase_036",[1,1,2.514],"tetra","4mmm"],
    [[[1,0,1],1],
    [[1,0,7],0.3],
    [[1,1,14],0.27],
    [[0,1,14],0.265],
    [[1,1,2],0.97],
    [[[0,0,1]],0.25,"mirror"]
]];

anatase_003=[
   ["anatase_003",[1,1,2.514],"tetra","4mmm"],
   [
        [[1,0,1],1] 
    ]
];

anatase_033=[
   ["anatase_033",[1,1,2.514],"tetra","4mmm"],
   [
       [[1,0,1],1],
       [[1,1,2],1.1],
       [[1,0,3],0.95],
       [[0,0,1],0.855]
   ]  
];

anatase_036 = [
   ["anatase_036",[1,1,2.514],"tetra","4mmm"],
   [
      [[1,0,1],1.25],
      [[1,0,2],0.92],
      [[1,0,3],0.8],
      [[0,0,1],0.6]
   ]
];

anatase_053=[["anatase_53",[1,1,2.514],"tetra","4mmm"],
    [
     [[1,0,1],1],
     [[1,0,7],0.3],
     [[1,1,14],0.27],
     [[0,1,14],0.265],
     [[1,1,2],0.97],
     [[0,0,1],0.25]
    ]   
];

anatase_063 = [
    ["anatase_63",[1,1,2.514],"tetra","4mmm"],
    [
      [[1,0,0],1.27],
      [[1,0,1],0.92],
      [[1,1,2],0.97],
      [[3,0,7],0.62],
      [[3,3,2],1.47]
    ]
];
Cassiterite_D1 =[
["Cassiterite_D1",[1,1,0.673],"tetra","4mmm"],
[ 
  [[1,1,1],1],
  [[1,0,1],1]
]  
];

Calomel_D4=  [
 ["Calomel_D4", [4.45,4.45,10.89],"tetra","4mmm"],
 [
  [[1,1,0],0.8],
  [[1,0,0],1.05],
  [[2,0,1],1.05],
  [[1,0,1],1],
  [[1,0,3],0.85]
  ]   
 ];


class_422 = [
// tetragonal holoaxial, tetragonal trapezohedral
    ["class_422",[1,1,1.2],"tetra","422"],
    [
      [[1,0,0],1],  //tetragonal prism - first order
      [[1,1,0],1],   //tetragonal prism - second order
      [[0,0,1],1,"mirror"],  //pinacoid 
      [[2,1,0],1], // Ditetragonal prism {hk0]
      [[2,0,1],1],  // tetragonal bipyramid first order
      [[3,3,1],1],  // tetragonal bipyramid second order
      [[1,2,3],1,"trapezoid"]   // tetragonal trapesohedron
    ]
    ];

class_42m = [
// tetragonal holoaxial, tetragonal trapezohedral
    ["class_-42m",[1,1,1.2],"tetra","-42m"],
    [
      [[1,0,0],1],  //tetragonal prism - first order
      [[1,1,0],1],   //tetragonal prism - second order
      [[0,0,1],1,"mirror"],  //pinacoid 
      [[2,1,0],1], // Ditetragonal prism {hk0]
      [[2,0,1],1],  // tetragonal bipyramid first order
      [[2,2,1],1,"",["parity"]],  // tetragonal sphenoid
      [[3,2,1],1,"",["parity"]]   // tetragonal scalenohedron, ditetragonal bisphenoid
    ]
    ];
chalcopyrite = [ 
// http://www.smorf.nl/?crystal=Chalcopyrite_019
   ["Chalcopyrite", [1,1,1.966],"tetra","42m"],
   [
       [[1,1,2],1,"",["parity"]],
       [[1,1,-2],0.6,"",["parity"]]
   ]
   ];

chalcopyrite_037 = [ 
// http://www.smorf.nl/?crystal=Chalcopyrite_019
   ["Chalcopyrite", [1,1,1.966],"tetra","42m"],
   [  [[0,0,1],1],
       [[0,1,-1],1.49],
       [[ 0,1,1],1.5],
       [[1,1,-2],0.91,"",["parity"]],
       [[1,1,2],1.12,"",["parity"]]
   ]
   ];
   
class_4mm = [
// ditetragonal pyramidal
    ["class_-4m",[1,1,0.5],"tetra","4m"],
    [
      [[1,0,0],1],  //tetragonal prism - first order
      [[1,1,0],1],   //tetragonal prism - second order
      [[0,0,1],1,"pedion"],  // pedion
      [[0,0,-1],1,"pedion"],  //pedion
      [[2,1,0],1], // Ditetragonal prism {hk0]
      [[2,0,1],1],  // tetragonal bipyramid first order
      [[2,2,1],1,"",["parity"]],  // tetragonal sphenoid
      [[3,2,1],1,"",["parity"]]   // tetragonal scalenohedron, ditetragonal bisphenoid
    ]
    ];

//scale(20)  c_render(chalcopyrite_037);
//scale(20) c_animate(cubic_system);
scale(20) c_render_part(class_422,6);
