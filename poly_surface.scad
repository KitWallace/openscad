/*
    computed surface construction  by  Kit Wallace
    
    Code licensed under the Creative Commons - Attribution - Share Alike license.

   The project is being documented in my blog 
     http://kitwallace.tumblr.com/tagged/openscad
  
    2022-05-07  - corrected to ensure surface is axisymmetric for a axisymmetric function thanks to 
       Yoshi Takeyasu 
*/

function flatten(l) = 
// remove one level of brackets
    [ for (a = l) for (b = a) b ] ;
function reverse(l) = 
//  reverse the elements of an array
    [ for (i=[1:len(l)]) l[len(l)-i]];   

// vertex indexes
// vertex indexes
function vt(i,j,nx,ny) = i*(nx+1) + j;
function vb(i,j,nx,ny) = (nx+1)*(ny+1) +i * (nx+1) + j;

function surface_vertices (minx,maxx,miny,maxy,nx,ny) =
// vertices
concat(
    flatten(
    [for (i=[0:nx])
      let (x= minx + (maxx-minx)*i/nx)
      [for (j=[0:ny])
        let (y= miny + (maxy-miny)*j/ny)
          [x,y,ftop(x,y)]
     ]
   ]),
    flatten(
    [for (i=[0:nx])
       let (x= minx + (maxx-minx)*i/nx)
       [for (j=[0:ny])
         let (y= miny + (maxy-miny)*j/ny)
         [x,y,fbottom(x,y)]
       ]
    ]
    )
  )
;

function surface_faces (nx,ny) =
  concat(
   flatten(
      [for (i=[0:nx-1])
        [for (j=[0:ny-1])
           reverse(
             [vt(i,j,nx,nx),
              vt(i+1,j,nx,nx),
              vt(i+1,j+1,nx,nx),
              vt(i,j+1,nx,nx)
            ]
          )
       ]
     ]
  ),
  flatten(
     [for (i=[0:nx-1])
        [for (j=[0:ny-1])
          [vb(i,j,nx,nx),
           vb(i+1,j,nx,nx),
           vb(i+1,j+1,nx,nx),
           vb(i,j+1,nx,nx)
         ]
       ]
    ]
   ),
   [for (i=[0:nx-1])
      [vt(i,0,nx,nx),
       vt(i+1,0,nx,nx),
       vb(i+1,0,,nx,nx),
       vb(i,0,,nx,nx)
      ]
   ],
   [for (i=[0:nx-1])
     reverse(
        [vt(i,ny,nx,nx),
         vt(i+1,ny,nx,nx),
         vb(i+1,ny,nx,nx),
         vb(i,ny,nx,nx)
        ]
     )
   ],
   [for (j=[0:ny-1])
     reverse(
       [vt(0,j,nx,nx),
        vt(0,j+1,nx,nx),
        vb(0,j+1,nx,nx),
        vb(0,j,nx,nx)
       ]
     )
   ],
   [for (j=[0:ny-1])
     [vt(nx,j,nx,nx),
      vt(nx,j+1,nx,nx),
      vb(nx,j+1,nx,nx),
      vb(nx,j,nx,nx)
     ]
   ]
  )
;
module poly_surface (minx,maxx,miny,maxy,nx,ny) {
// uses ftop() and fbottom()  to computer surface heights 
   sv=surface_vertices(minx,maxx,miny,maxy,nx,ny);   
   // echo("vertices",sv);
   sf=surface_faces(nx,ny);     
   // echo("faces",sf);    
   polyhedron(sv,sf);
};
  
module ruler(n) {
    color([0,0,1,0.5])
    for (i=[0:n-1]) 
       translate([(i-n/2 +0.5)* 10,0,0]) cube([9.8,5,2], center=true);
}

module ground(z=200) {
    translate([0,0,-z]) cube(z*2,center=true);
} 

module sky(height,z=200) {
   translate([0,0,height])
      rotate([0,180,0]) ground(z);
}

// example uses 

/*
function ftop(x,y) = sin(60*x)*sin(90*y) + 2 ;
function fbottom(x,y) =ftop(x,y)-0.5 ;

color("pink") 
    scale([5,5,2.5]) poly_surface(-4,4,-4,4,100,100);  


*/

/*    
function fsinc(x,y) =
// eps eliminates a hole at the peak
     let (eps=0.001,r = sqrt(x*x + y*y + eps))
     sin(180*r)/r;
    
function ftop(x,y) = fsinc(x,y);
function fbottom(x,y) = ftop(x,y)-0.2 ;

color("forestgreen") 
   scale([5,5,2.5]) poly_surface(-4,4,-4,4,100,100);  

*/
/*
function fquartic(x,y) = x*x+y*y;
function ftop(x,y) = fquartic(x,y)+5;
function fbottom(x,y) = ftop(x,y)-5 ;

color("forestgreen") 
 scale([5,5,0.5]) poly_surface(-4,4,-4,4,100,100);  

*/


function fquartic(x,y,a,b) = a*x*x-b*y*y;
function ftop(x,y) = fquartic(x,y,1,1)+20;
function fbottom(x,y) = 0 ;

color("cornsilk") 
 scale([5,5,0.5]) poly_surface(-4,4,-4,4,100,100);  

* ruler(10);
