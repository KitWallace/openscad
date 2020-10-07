// list operations
eps=0.0001;

function flatten(l) = [ for (a = l) for (b = a) b ] ;

function _subseq(list,start,end=undef) =
    let(end = end==undef ? len(list):end)
    [for(i=[start:1:end-1]) list[i]];
        
function _delete(list,pos) =
    [for (i=[0:len(list)-1])
        if (i != pos) list[i]
    ];

function _remove(list,entry) =
    [for (e=list)
        if (e != entry) e
    ];

function _remove_all(list,entries,pos=0) =
   pos >= len(entries)
     ? list
     : _remove_all(_remove(list,entries[pos]),entries,pos+1)
   ; 
        
// basic geometry tests          
function _isCollinear(a,b,c) = norm(cross(b-a,c-a)) < eps;

function _firstnoncollinear(list,point1,point2,pos=0) = 
    pos >= len(list) 
        ? undef 
        : ! _isCollinear(point1,point2,list[pos]) 
           ? pos 
           : _firstnoncollinear(list,point1,point2,pos+1);
                
function _isCoplanar(a,b,c,d) = abs((d-a)*cross(b-a,c-a)) < eps;

function _firstnoncoplanar(list,point1,point2,point3,pos=0) =
   pos >= len(list) 
        ? undef 
        : ! _isCoplanar(point1,point2,point3,list[pos]) 
           ? pos : 
           _firstnoncoplanar(list,point1,point2,point3,pos+1);

// orientation tests        
function _sameSide(p1,p2, a,b) = 
    let(cp1 = cross(b-a, p1-a),
        cp2 = cross(b-a, p2-a)) 
    cp1*cp2 >= eps;
        
function _insideTriangle(p, t) = 
    _sameSide(p,t[0],t[1],t[2]) &&
    _sameSide(p,t[1],t[2],t[0]) &&
    _sameSide(p,t[2],t[0],t[1]);

function _isBoundedBy(a,face,strict=false) =
    cross(face[1]-face[0],face[2]-face[0])*(a-face[0]);

function _point_outside_triangle(p, triangle) =
    let(c=_isBoundedBy(p, triangle))
    c > 0 || (c == 0 && _insideTriangle(p, triangle));
    
function _insidePoly(p, triangles, pos=0) = 
    pos >= len(triangles) 
         ? true 
         : !_point_outside_triangle(p, triangles[pos]) 
           ? false 
           : _insidePoly(p, triangles, pos=pos+1);
           
function _orientTet(a,b,c,d) =
    _isBoundedBy(d,[a,b,c]) >= eps    //  get faces oriented the same way 
        ? [[a,b,c],[b,a,d],[c,b,d],[a,c,d]] 
        : [[c,b,a],[d,a,b],[d,b,c],[d,c,a]];
            
// list search 
function _find(list,value) =
    let(m=search([value],list,1)[0]) 
    m==[] ? undef : m;
    
function find(array,key) =  array[search([key],array)[0]];
         
function _distinct(list,dlist=[],i=0) =
    i >= len(list) 
      ? dlist 
      : _find(dlist,list[i]) == undef 
        ? _distinct(list,concat(dlist,[list[i]]),i+1) 
        : _distinct(list,dlist,i+1);

// find convex hull using ? quick hull ?         
function pointHull3D(points) =
// return hull as a number of triangular faces
    let (pts = _distinct(points))
    let (ft=_initialTet(pts))  
     _expandHull(ft[0], ft[1]);
     
function _initialTri(list) = 
    assert(len(list)>=3)
    let(a=list[0],
        b=list[1],
        rest=_subseq(list,2),
        ci=_firstnoncollinear(rest,a,b),        
        c=assert(ci != undef) rest[ci],
        rlist=_delete(rest,ci))
        [[a,b,c],rlist];
        
function _initialTet(list) = 
    let(ft=_initialTri(list),
        tri=ft[0],
        rest=ft[1],
        di=assert(len(rest)>0) _firstnoncoplanar(rest,tri[0],tri[1],tri[2]),
        d=assert(di != undef) rest[di],
        rrest= _delete(rest,di))
        [_orientTet(tri[0],tri[1],tri[2],d),rrest];
     
function _triangle_edges(triangle) =
    [[triangle[0],triangle[1]],
     [triangle[1],triangle[2]],
     [triangle[2],triangle[0]]
    ];

function _equal_edges(a,b) = a==b;

function _triangle_has_edge(triangle,edge) =
     let (edges = _triangle_edges(triangle))
     _equal_edges(edges[0],edge) || edges[1]==edge || edges[2] == edge ;
     
function _outerEdges(triangles) =
    let(edges=
        flatten([for(t=triangles) _triangle_edges(t)]))   
    [for(e=edges) 
        if(undef == _find(edges,[e[1],e[0]])) e];
      
function _unlit(triangles, p) = 
    [for(t=triangles) 
         if(_isBoundedBy(p, t) >= eps) t];
        
function _addToHull(hull, p) = 
    let(unlit = _unlit(hull,p),
        edges = _outerEdges(unlit))
        concat(unlit, [for(e=edges) [e[1],e[0],p]]);

function _expandHull(hull, points, pos=0) =
    pos >= len(points) 
        ? hull 
        : ! _insidePoly(points[pos],hull) 
            ? _expandHull(_addToHull(hull,points[pos]),points,pos=pos+1)  // add point
            : _expandHull(hull, points, pos=pos+1); // ignore point
 
// triangulated hull

function extractPointsFromHull(hull) =
    _distinct( [for(triangle=hull) for( v=triangle) v] );
        
function _makePointsAndFaces(triangles) =
    let(points=extractPointsFromHull(triangles))
    [points, [for(t=triangles) [for(v=t) _find(points,v)]]];

function pointHull(points) =
    _makePointsAndFaces(pointHull3D(points));

function triangulatedHull(points) =
    let (hull = pointHull3D(points))
    _makePointsAndFaces(hull);
    
    
// unite triangular faces to create polygonal faces 

function _tri_minus_edge(tri,edge)  =
     [for (p=tri) if(p != edge[0] && p != edge[1]) p];
        
function connected_tris(tri,tris,pos=1) =
    let(edges=_triangle_edges(tri))           
    flatten([for (e = edges)
       [for(a_tri = tris)
       let (a_edges = _triangle_edges(a_tri))
       if  (_find(a_edges,[e[1],e[0]]) != undef)
          let (p = _tri_minus_edge(a_tri, e))
          if(_isCoplanar(tri[0],tri[1],tri[2],p[0]))
             a_tri
       ]
    ]);  
          
function make_face(working,tris,face=[]) =
    len(working) == 0
       ? face
       : let (t=working[0])
         let (facex=concat(face,[t]))
         let (connected = connected_tris(t,tris))
         connected == undef
            ? let (workingx= _remove(working,t))
              let (trisx= _remove(tris,t))
              make_face(workingx,trisx,facex)
            : let (workingx= concat(_remove(working,t),connected))
              let (trisx = _remove_all(tris,concat(t,connected)))
              make_face(workingx,trisx,facex)
     ;
          
function make_poly(tris,faces=[]) =
    len(tris) == 0 
        ? faces 
        : let (t=tris[0])
          let (face = make_face([t],_remove(tris,t)))
          make_poly(_remove_all(tris,face),concat(faces,[face]));
      
function connect_edges_r(edge,edges) =
   len(edges) == 0 
      ? []
      : let (next =
          [for (i=[0:len(edges)-1])
           if(edge[1]==edges[i][0])
              edges[i] 
          ][0])
        concat([edge[0]],connect_edges_r(next,_remove(edges,edge)))
  ;

function connect_edges(edges) =
   connect_edges_r(edges[0],_remove(edges,edges[0]));
      
function edges_to_vertices(edges) =  
      [for (e = edges) e[0]];

function triangles_to_face (tris) =
      connect_edges(_outerEdges(tris)); 

function tris_to_faces(tris) =
    [for (t=tris) triangles_to_face(t)];
        
function facedHull(points) =
    let (tris = pointHull3D(points))
    let (grouped_tris= make_poly(tris))
    let (faces= tris_to_faces(grouped_tris))
    _makePointsAndFaces(faces);
