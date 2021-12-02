include <../lib/tile.scad>


function interpolate (x,y,t) =
   x * (1 - t) + y * t;
   
function point_interpolate(a,b,t) =
   [ interpolate(a.x,b.x,t), interpolate(a.y,b.y,t)];
   
function points_interpolate(pnts,t) =
  [for (i=[0:len(pnts)-1])
      point_interpolate(pnts[(i -1 + len(pnts)) %len(pnts)], pnts[i],t)
  ];
  
function path_to_points(points,path) =
  [for (node = path) points[node]];
       
function r_points(base,r,n) =
    n==1 
  ? base
  :   // let (nr=interpolate(0.5,r,0.3))
    let (nbase=points_interpolate(base,r))
    concat(base,r_points(nbase,r,n-1))
  ;
  
function r_path(m,n,j=0) =
   j==n ? []
   : concat(
       [for (i=[0:m-1])
           j*m + i
       ],
       r_path(m,n,j+1),
       j > 0 ? j*m : []
       );

function polygon(r,n) =
  let (d= 360/n)
[for(i=[0:n-1])
   let (a=i*d)
     [r*cos(a),r*sin(a)]
];


//  main 
R=10;
m=4;
n=3;
r=0.5;
base=polygon(R,m);       
points= r_points(base,r,n) ;           
path= r_path(m,n);
path_points =   path_to_points(points,path);
fill_tile(path_points );  
echo (path_points );
          
