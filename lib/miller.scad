include <hull.scad>
include <basics.scad>
include <polyfns.scad>
 
eps= 0.01;

function comb_3 (N) =
   flatten(flatten([for (i=[0:N-3])
       [for (j=[i+1:N-2])
           [for (k=[j+1:N-1])
               [i,j,k]
           ]
       ]
   ]));

// solve matrix equation
function _d22(a00,a01,a10,a11) = a00*a11-a01*a10;

function _determinant3x3(m) =
     m[0][0]*_d22(m[1][1],m[1][2],m[2][1],m[2][2])
    -m[0][1]*_d22(m[1][0],m[1][2],m[2][0],m[2][2])
    +m[0][2]*_d22(m[1][0],m[1][1],m[2][0],m[2][1]);
        
// Cramer's rule for inversion

function _solve3(a,b,c) = 
     let (na=a[0],nb=b[0],nc=c[0])
     let (da=a[1],db=b[1],dc=c[1])
     let (det=_determinant3x3([na,nb,nc]))
     det == 0 
       ? undef 
       :
        let(rhs=[da,db,dc],
            col0=[na[0],nb[0],nc[0]],
            col1=[na[1],nb[1],nc[1]],
            col2=[na[2],nb[2],nc[2]])
       
       [_determinant3x3([rhs,col1,col2]),
        _determinant3x3([col0,rhs,col2]),
        _determinant3x3([col0,col1,rhs])
       ] / det;

     
function _perp_distance(plane,point) =
       plane[0]*point - plane[1] ;
         
function _point_on_or_inside(planes,point,i=0) =
    i >= len(planes)
       ? true
       : let (pd=_perp_distance(planes[i],point))
         pd > eps
           ? false         
           : _point_on_or_inside(planes,point,i+1);

function _normalize_planes(planes) =
      [for (plane= planes)
           [plane[0],plane[1]*norm(plane[0])]
      ];
      
function _intersections(combs,planes) =     
     [for (c = combs) 
      let (p = _solve3(planes[c[0]],planes[c[1]],planes[c[2]]))
      if (p != undef )
          flatten(p)
     ]; 

function _inside (points,planes) =
    [for (p=points)
       if( _point_on_or_inside(planes,p))
         p
    ];

function _equal_pts(a,b) = norm(a-b) < eps;

function _pt_in_pointsx(pt,pts) =
     let (same= [for (p=pts) if (_equal_pts(p,pt)) p])
     len(same) > 0;
     
function _pt_in_points(pt,pts,i=0) =
     i >= len(pts)
        ? false
        : _equal_pts(pts[i],pt)
          ? true
          : _pt_in_points(pt,pts,i+1);
     
function _distinct_points(list,dlist=[],i=0) =
    i >= len(list) 
      ? dlist 
      : _pt_in_points(list[i],dlist)
        ? _distinct_points(list,dlist,i+1)
        : _distinct_points(list,concat(dlist,[list[i]]),i+1); 
           
function perturb(faces,r) =
     [for (face=faces)
       let(d= rands(-r,+r,1)[0])
       [face[0],face[1]+d]
     ];

function miller_to_points(faces) =
  let (N=len(faces))
  let (combs = comb_3(N))
  let (nfaces=_normalize_planes(faces))
  let (inter = _intersections(combs,nfaces))
  let (inside = _inside(inter,nfaces))
  let (pts = _distinct_points(inside))
  pts;

function points_to_poly(name,pts) =
   let (polyhull=facedHull(pts))
   [name,polyhull[0],polyhull[1]];

function points_to_tri_poly(name,pts) =
   let (polyhull=triangulatedHull(pts))
   [name,polyhull[0],polyhull[1]];

module hull_points(pts) {
//     hull()
      for (p = pts) 
          translate(p)
             sphere(r=0.1);
  }

function compound(name,components) =
   [name,flatten(
   [for (component = components)
     let (faces =component[0][1])
     let (scale= component[1])
     [for (f = faces)
        [f[0],f[1]*scale]
     ]
   ])]; 

function face_to_miller(points) =
         let (normal = normal(points))
         let (d = normal*points[0])  //any point on the face
         [normal,d];
     
function poly_to_miller(obj) =
    [
      obj[0],
        [for (f=p_faces(obj))
         let (points =as_points(f,p_vertices(obj)))
         face_to_miller(points)
        ]
     ];  
