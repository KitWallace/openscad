use <../lib/basics.scad>
use <../lib/poly.scad>
use <solid.scad>

/*
  exhaustive search for circuits in the polyhedron defined in solid.scad
  
    the general step starts with a face and one of its edges 
    for each adjacent edge (or any other edge)
       where the connecting face is unvisited
         add the the face to the circuit and continue
       if no unvisited faces
       the sucess if the circuit is complete, failure if it is not
   the output is the set of all circuits
*/

function dflatten(l,d=2) =
// hack to flattened mixed list and list of lists
   flatten([for (a = l) depth(a) > d ? dflatten(a, d) : [a]]) ;
    
function purge(l) =
    [for (a = l) if (a != [] && a[0] != []) a];
                
function face_edges(f) =
 // edges are ordered anticlockwise
    [for (j=[0:len(f)-1])
        [f[j],f[(j+1)%len(f)]]
    ];

function face_with_edge(edge,faces) =
    [for (i = [0:len(faces)-1])
            if (vcontains(edge,face_edges(faces[i])))
            i
    ][0];

function other_edges (edge,face) =
     [ for (e= face_edges(face)) if( e != edge ) e];

function adjacent_edges(edge,face) =
     let (edges = face_edges(face) )    
     let (ei = [for (i=[0:len(edges)-1]) if (edge==edges[i]) i][0]) 
     [edges[(ei+len(edges) +1)%len(edges)], edges[(ei+len(edges) -1 )%len(edges)]];
     
function ham(faces,adjacent=true,cycle=[],f=0,e=0) =
     len(cycle) == len(faces) && f==0  // a ham
     ? dflatten(cycle,2)
     : let (face=faces[f],
            edge=  e==0 ? face_edges(face)[0] : e,
            ef = adjacent ? adjacent_edges(edge,face) : other_edges(edge,face),
            af = [for (e=ef) face_with_edge(reverse(e),faces)])          
       [for (i=[0:len(af)-1])
          let (e=ef[i],f=af[i])
            if (!vcontains(f,cycle))
               ham(faces,adjacent,concat(cycle,[f]),f,reverse(e))
       ]
         ;

   
solid=Z();
faces = p_faces(solid);
fs=ham(faces,false); 
paths = purge(dflatten(fs,1));
echo (len(paths));
echo (paths);
