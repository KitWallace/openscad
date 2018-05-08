
/*
Tiling functions

- reduction of tiles to  a vertex/edge structure - for export to SVG at least
- unclear which functions work on internal angles (should be all now except where notes
    and on normalised (ie with lengths and angles not just angles - better word needed

*/
// basic functions
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function depth(a) =
   len(a)== undef 
       ? 0
       : 1+depth(a[0]);

function signx (x) =
     x==0 ? 1 : sign(x);

//  angles 

function angle_between(u, v) = 
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     let (d = cross(u,v).z)
      d  > 0 ? a : 360- a;
                  

// transformation matrices

function m_translate(v) = [ [1, 0, 0, 0],
                            [0, 1, 0, 0],
                            [0, 0, 1, 0],
                            [v.x, v.y, v.z, 1  ] ];
                            
function m_rotate(v) =  [ [1,  0,         0,        0],
                          [0,  cos(v.x),  sin(v.x), 0],
                          [0, -sin(v.x),  cos(v.x), 0],
                          [0,  0,         0,        1] ]
                      * [ [ cos(v.y), 0,  -sin(v.y), 0],
                          [0,         1,  0,        0],
                          [ sin(v.y), 0,  cos(v.y), 0],
                          [0,         0,  0,        1] ]
                      * [ [ cos(v.z),  sin(v.z), 0, 0],
                          [-sin(v.z),  cos(v.z), 0, 0],
                          [ 0,         0,        1, 0],
                          [ 0,         0,        0, 1] ];
 
function m_scale(v,s) =
     depth(v)==2
      	? [ [v[0],0,0,0],
	        [0,v[1],0,0],
	        [0,0,v[2],0],
	        [0,0,0,1]
          ]
        : [ [v,0,0,0],
	        [0,v,0,0],
	        [0,0,v,0],
	        [0,0,0,1]
          ];
          
function vec3(v) = [v.x, v.y, v.z];
function transform(v, m)  = vec3([v.x, v.y, v.z, 1] * m);

// vector operations 
function zero(v) =
    len(v) == undef ? 0 : [for (i=[0:len(v)-1]) 0];
   
function slice(v,d,i=0) =
     i < len(v) ?  concat([v[i][d]], slice(v,d,i+1) ) : [] ;

function subseq(v,start,end) =
    [for (i=[0:len(v)-1]) if(i>= start && i <= end ) v[i]];
        
function reverse(v) = 
     [for (i=[1:len(v)]) v[len(v)-i]];

function shift(v,shift=0) = 
   [for (i=[0:len(v)-1]) v[(i + shift + len(v))%len(v)]];  
       
function unitv(v)=  v/ norm(v);
   
function v_sum_r(v,n,k) =
      k > n ? zero(v[0]) : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

function v_min_r(v,m,i) =
     i < len(v)-1
        ? v[i] < m
           ?  v_min_r(v,v[i],i+1)
           :  v_min_r(v,m,i+1)
        : m ;
function v_min(v) = v_min_r(v,m=v[0],i=1);
 
function v_max_r(v,m,i) =
     i < len(v)-1
        ? v[i] > m
           ?  v_max_r(v,v[i],i+1)
           :  v_max_r(v,m,i+1)
        : m ;
function v_max(v) = v_max_r(v,m=v[0],i=1);
   
function avg(v) =v_sum(v,len(v)) / len(v);
    
function v_centre(v) =  avg(v);

// sort table on column col
function quicksort1(arr,col=0) = 
  !(len(arr)>0) ? [] : 
      let(  pivot   = arr[floor(len(arr)/2)][col], 
            lesser  = [ for (y = arr) if (y[col]  < pivot) y ], 
            equal   = [ for (y = arr) if (y[col] == pivot) y ], 
            greater = [ for (y = arr) if (y[col]  > pivot) y ] 
      ) 
      concat( quicksort1(lesser), equal, quicksort1(greater) );  
            
function v_scale(v,scale) =
    let(m=m_scale(scale))
    [for (p=v) transform(p,m) ];

function v_rotate(v,angle) =
    let(m=m_rotate([0,0,angle]))
    [for (p=v) transform(p,m)];

function v_translate(v,d) =
    let(m=m_translate(d))
    [for (p=v) transform(p,m)];
        
function bounding_box(points) =
    [[max(slice(points,0))- min(slice(points,0)),min(slice(points,0)), max(slice(points,0)),

        min([for (p=points) p.x <0  ? -p.x:9999999]) ,
        max([for (p=points) p.x>0 ? p.x:0])   ], 
     [max(slice(points,1))- min(slice(points,1)),min(slice(points,1)), max(slice(points,1))]
    ];  
        
function 3d_to_2d(points)=
    [ for (p=points) [p.x,p.y]];
        
function 2d_to_3d(points)=
    [ for (p=points) [p.x,p.y,0]];

function f(x,v) =x;
    
  
// general turtle commands
// recursion limits are a problem here - can this be written non-recursively or to exploit tail recusion
    
function turtle_path(steps,pos=[0,0,0],dir=0,i=0) =
   i == len(steps)
      ? [[pos,dir]]
      : let(step = steps[i], command=step[0])
        command=="F"
          ? let (distance = step[1])
            let (newpos = pos + distance* [cos(dir), sin(dir),0])
            concat([[pos,dir]],turtle_path(steps,newpos,dir,i+1)) 
          : command=="L" 
            ?  let (angle = step[1])
               turtle_path(steps,pos,(dir+angle) % 360,i+1)
            : command=="R"
               ? let (angle = step[1])
                 turtle_path(steps,pos,dir-angle,i+1)
               : turtle_path(steps,pos,dir,i+1)
     ;       

//  perimeter operations   
//  perimeter is  defined  either 
//     as a sequence of length/interior angle pairs, going anticlockwise 
//    or for an equilateral figure, just the list of angles, going anticlockwise 

function norm_peri(peri) =
     [for (p=peri)
        len(p)==undef
           ? [1,p]
           :[p.x,p.y] 
     ];
function scale_peri(scale,peri) =
   [for (p=peri)
        len(p)==undef
           ? [scale,p]
           :[scale * p[0],p[1]] 
   ];
 
function peri_to_turtle(peri) =
    flatten([for (p=peri)
        len(p)==undef
           ?  [["F",1],["L",p]]
           :  [["F",p.x],["L",p.y]]
    ]);

function peri_to_turtle_int(peri) =
    flatten([for (p=peri)
        len(p)==undef
           ?  [["F",1],["L",180-p]]
           :  [["F",p.x],["L",180-p.y]]
    ]);
 
function int_to_ext(peri) =
    [for (p=norm_peri(peri)) [p.x,180-p.y]];

function ext_to_int(peri) = int_to_ext(peri);
    
function repeat(p,n) =
   norm_peri( flatten([for (i=[0:n-1]) p]));
 
function reverse(p) =
   [for (i=[0:len(p)-1]) p[len(p)-1-i]];

function mirror_side(side) =
    [for (i=[0:len(side)-1])
        let(p=side[i])
        i < len(side)-1 ? [p.x,360-p.y] : p
    ]; 
    
// assumes the angle at the end of a side is the same as the angle at the beginning - ok for rectangles and hexs oh and it works for parallelograms too!
function rmirror_side(side) =
    [for (i=[0:len(side)-1])
        let(p0=side[len(side)-1-i])
        let(p1=side[len(side)-2-i])
        i < len(side)-1 
             ? [p0.x,360-p1.y] 
             : [p0.x,side[len(side)-1].y]
    ]; 
 
 function rmidpoint_side(side) =
     flatten(
    [
      [for (i=[0:len(side)-2]) side[i]],
      [for (i=[0:len(side)-1])
        let(p0=side[len(side)-1-i])
        let(p1=side[len(side)-2-i])
        i==0 
          ?  [2*p0.x,360-p1.y]
          : i  < len(side)-1 
             ? [p0.x,360-p1.y] 
             : [p0.x,side[len(side)-1].y]
    ]]); 
function mirror_peri(peri)=   
      flatten([for (p=peri)
        len(p)==undef
           ?  [[360-p]]
           :  [[p.x,360-p.y]]
    ]);
function convex(peri,i=0) =
   i<len(peri)
     ? peri[i].y > 0  && peri[i].y < 180  && peri[i].x > 0 && convex(peri,i+1)
     : true;

function total_internal(peri) =
     v_sum(slice(peri,1),len(peri));

function total_external(peri) =
     let (eperi = int_to_ext(peri))
     v_sum(slice(eperi,1),len(eperi));
      
function polygon(peri) =
     total_external(peri) == 360;
       
function peri_to_tile(peri,last=false) = 
    let (p =turtle_path(peri_to_turtle_int(peri)))  
    last 
       ? [for (i=[0:len(p)-1]) p[i][0]] 
       : [for (i=[0:len(p)-2]) p[i][0]]; 

function peri_end(peri) =
    let(t=peri_to_tile(peri,true))
    t[len(t)-1];
       
function peri_last(peri) =
    let(t=peri_to_tile(peri,true))
    let (d= norm(t[len(t)-1]))
    let (a=peri[len(peri)-1].y)
    [d,a];

function peri_error(peri) = 
    norm(peri_end(peri));

function CCW(p1, p2, p3) =
    (p3.y - p1.y) * (p2.x - p1.x) > (p2.y - p1.y) * (p3.x - p1.x);

function isIntersecting(p1, p2, p3, p4) =
   ( CCW(p1, p3, p4) != CCW(p2, p3, p4)) && (CCW(p1, p2, p3) != CCW(p1, p2, p4));
 
function isSimple (peri) =
    let(t = peri_to_tile(peri))
    let(v = flatten([for (i=[0:len(t)-2])
        if (i + 2 < len(t) - 2)
         flatten( [for (j=[i+2:len(t) -2])
              if( isIntersecting(t[i],t[(i+1)%len(t)],t[j],t[(j+1)%len(t)]))
               1])
          ]))
     v_sum(v,len(v)) == 0;

function replace_sides(peri,sides) =
 flatten( [for (i=[0:len(peri)-1])
      let (bside = peri[i])
      let (mside = sides[i])
      let (mside_m = 
              len(mside) >1 
                 ? concat([for (i=[0:len(mside)-2]) mside[i]],[[mside[len(mside)-1][0],bside[1]]])
                 : [[mside[0][0],bside[1]]]
           )
      let (mside_length = peri_error(mside_m))
      let (mside_scaled = scale_peri(bside[0]/mside_length,mside_m))
      mside_scaled
  ]);
  
module peri_report(peri,name="Peri",eps=0.000001) {
   echo(" ");
  echo("Name",name);
  echo("Perimeter",peri);
  echo("Sides",len(peri));
  echo("Convex",convex(peri));
  echo("Complete",polygon(peri),total_external(peri));
  echo("Closed", peri_error(peri) < eps,peri_error(peri));
  echo("Simple", isSimple(peri));
};   
// tile operations
    
function tile_to_peri(points) =
    [for (i=[0:len(points)-1])
        let (a = angle_between(
          points[(i+1) % len(points)] - points[i],
          points[(i+2) % len(points)] -  points[(i+1) % len(points)]))
          
       [norm(points[(i+1) % len(points)] - points[i]),
       180-a
       ]
    ] ;
    
// points need to be extended
function path_error(points) = 
    let(last=points[len(points)-1])
    norm(last);
    
function close(points)= concat(points,[[0,0,0]]); 
  
function peri_to_points(peri,last=false) = peri_to_tile(peri,last=false);  // synonym

function scale_tile(tile,scale) = v_scale(tile,scale);

function translate_tile(t,d) =
      [for (p=t) p+d]; 
   
function rotate_tile(t,a) = v_rotate(t,a);
      
function centre_tile(t) =
    let(c = v_centre(t))
    translate_tile(t,-c);
 
// mirror a tile 
function reflect_x(tile) = 
     [for (p = tile) [-p.x,p.y,p.z]];

function mirror_tile(tile) =
    let (m = reverse(reflect_x(tile)))
    let (mp= tile_to_peri(m))
    let (mps = shift(mp,len(mp)-2))
    peri_to_tile(mps);

function rmirror_tile(tile) =
     reverse(mirror_tile(tile));
     
/* function to test niceness of a tile
   max / min < pmin
   all angles > amin
   all 180-angles > amin

*/
     
// presentation 
     
module label_points(points) {
  for (i=[0:len(points)-1]) {
     label = chr(i + 65);
     translate(points[i])
      translate ([0,0,0.5])
       scale(0.05) text(label); 
  }};
  
module number_points(points,size=0.01) {
  for (i=[0:len(points)-1]) {
     label = chr(i + 48);
     translate(points[i])
      translate ([0,0,0.5])
       scale(size) text(label); 
  }};
  
module number_edges(points,size=0.01) { 
  //# edges <10
  for (i=[0:len(points)-1]) {
     label = chr(i + 48);
     mid= (points[i] + points[(i+1) % len(points)])/2;
     translate(mid)
       translate([0,0,5])
         scale(size) text(label); 
  }};

// edges
  
function edge(points,i) =
   [points[i],points[(i +1) %len(points)]];

function m_edge_to_edge(edge1, edge2,end=0) =
  // need to 
    let (start = (end==0 || end== undef) ? 1 : 0)
    let (a = angle_between(  
                edge2[1] - edge2[0],
                edge1[0] - edge1[1]))
    let (t1 = m_translate(-edge1[start]))
    let (r =  m_rotate([0,0,-a]))
    let (t2 = m_translate(edge2[end])) 
    t1*r*t2;
 
function m_pos_dir(pd)=
     let(t = m_translate(pd[0]))
     let(r = m_rotate([0,0,pd[1]]))
     r*t;

function distance(t1,t2) =
    avg(t2) -avg(t1);

function translation(a,b) = distance(a,b);

function copy_tile(tile,m) =
    [for (p = tile) transform(p,m)];

function copy_tile_to_edge(source,i,target,j,end=0) =
   let (m = m_edge_to_edge(edge(source,i),edge(target,j),end))
   copy_tile(source,m);
 
 function copy_tile_to_edges(source,i,targets,j) =
     [for (k=[0:len(targets)-1])
          copy_tile_to_edge(source,i,targets[k],j)
     ] 
     ; 
 function copy_tile_to_position(source,steps) =
    let (points= turtle_path(peri_to_turtle(steps)))
    let (end = points[len(points)-1])
    let (m = m_pos_dir(end))
    copy_tile(source,m);  
     
function rcopy_tile(tile,m,n) =
     n > 0 ?
       let (t = copy_tile(tile,m))
       concat([tile],rcopy_tile(t,m,n-1))
       : [tile];     

function offset_tile(t,sedge,tedge,end=0) =
      translation(t,copy_tile_to_edge(t,sedge,t,tedge,end));
 
function offset_group(g,offset) = group_offset(g,offset);
function group_offset(g,offset) =
     let(end = offset[4]== undef ? 0 : offset[4])
     translation(g[offset[0]],
         copy_tile_to_edge(g[offset[0]],offset[1],g[offset[2]],offset[3],end));
        
  
// create the tile inset by d 

//  doesnt handle the case where v1 and v2 are colinear (eg when the angle between them is 180 
// current fix doesnt realy work  but its Ok for small d
function inset_tile (tile, d=0.1) =
  [for (i=[0:len(tile)-1])
      let (v1 = unitv(tile[(i+len(tile) - 1 )% len(tile)] - tile[i]))
      let (v2 = unitv(tile[i] - tile[(i+1 )% len(tile)] ))
      let (vm = unitv((v1 - v2) /2))
      let (a = 180 - angle_between(v1,v2))
      let (offset = d / sin(a/2))
      tile[i]+offset * vm
  ];

// tile to objects    
module fill_tile(tile,color="red") {
    color(color)
       polygon(3d_to_2d(tile)); 
};

module fill_group (group,colors=["lightgreen"]) {
    for (i=[0:len(group)-1]) {
       colors = colors[i % len(colors)];
       g=group[i];  
        if(depth(g)==2)
           fill_tile(g,colors); 
       else fill_group(g,[colors]);          
   }
}

module outline_group(group,colours,d) {
   for (i=[0:len(group)-1]) {
      g= group[i];
      if(depth(g)==2)
           color(colours[i % len(colours)]) outline_tile(g,d); 
      else outline_group(g,[colours[i % len(colours)]],d);
   }
};

module inset_group(group,colours,d) {
   for (i=[0:len(group)-1]) {
      g= group[i];
      if(depth(g)==2)
           fill_tile( inset_tile(g,d),colours[i % len(colours)]); 
      else inset_group(g,[colours[i % len(colours)]],d);
   }
};


//groups of tiles to create a tiling unit
/*
 assemble a group of tiles using assembly instructions
 these are a sequence of copy instructions to copy the base tile to other tiles
 each instruction defines
    [edge of copy tile,
     target tiles as an index in the developing group,
     target edge - the edge of the target tile to be aligned with the  copy tile
     ?   1 if copy to be mirrored
    ]

*/
function group_tiles(tile,assembly,group=[],i=0) =
    i==len(assembly)+1
        ? group
        :  
          i==0 
           ? group_tiles(tile,assembly,[tile],i+1)
           : let(move = assembly[i-1])
             let(nt = 
                   len(move)==4
                       ?  copy_tile_to_edge(mirror_tile(tile),move[0],group[move[1]],move[2])
                       :  copy_tile_to_edge(tile,move[0],group[move[1]],move[2]))
             group_tiles(tile,assembly,concat(group,[nt]),i+1);

// break this up into 
// create list of transformations 
//  apply the transformations


function group_transforms(tile,assembly,group=[],transforms=[],i=0) =
    i==len(assembly)+1
        ? transforms
        :  
          i==0 
           ? group_transforms(tile,assembly,[tile],[],i+1)
           : let(move = assembly[i-1])
             let(m=m_edge_to_edge(edge(tile,move[0]),edge(group[move[1]],move[2])))
             let(nt = 
                   len(move)==4
                       ?  copy_tile(mirror_tile(tile),m)
                       :  copy_tile(tile,m)
                       )
             group_transforms(tile,assembly,concat(group,[nt]),concat(transforms,[m]),i+1);
// doesnt handle mirror since thats not a transform 
function apply_group_transforms(tile,transforms,group=[],i=0) =
    i==len(transforms)+1
        ? group
        : i==0
           ?apply_group_transforms(tile,transforms,[tile],i+1)
           :let (nt = copy_tile(tile,transforms[i-1]))
            apply_group_transforms(tile,transforms,concat(group,[nt]),i+1);
            
                
module group_report(group) {
     echo("No of Tiles",len(group));
    // add tests for tile overlap 
}

// to convert a group to a tile
 function eq(a,b,tol=0.000001) =
      norm(a - b) <= tol;
            
 function equal_edge(e1,e2) =
     eq(e1[0],e2[0]) && eq(e1[1], e2[1])
    ||  eq(e1[0],e2[1]) && eq(e1[1], e2[0])     ; 

//get all edges in a group
function group_edges(g) =
    let(edges = flatten(
         [for (p = g)
            [for (i =[0:len(p)-1])
                [p[i],p[(i+1)%len(p)]]
            ]
         ]))
    edges;
 // remove repeated edges which must be inner edges            
 function outer_edges(edges) =
     [for (i = [0:len(edges)-1] )
        let(e = edges[i]) 
        let(matches =
            [for (j=[0:len(edges) - 1])
               if (equal_edge(e,edges[j])) j
            ])
        if (len(matches) == 1) e
      ];

function remove_edge(edges,edge) =
   [for (e = edges) if (!equal_edge(e,edge)) e];
       
function connect_edges_r(edge,edges) =
   len(edges) == 0 
      ? []
      : let (next =
          [for (i=[0:len(edges)-1])
           if(eq(edge[1],edges[i][0]))
           edges[i] 
          ][0])
        concat([edge],connect_edges_r(next,remove_edge(edges,edge)))
  ;

function connect_edges(edges) =
   connect_edges_r(edges[0],remove_edge(edges,edges[0]));

           
function edges_to_points(edges) =
   [for (e = edges) e[1]];

// simplify perimeter 
   // if abs(step.angle) =180 then carry distance.
   // if not add carry to distance and output step
   
function simplify(steps,i=0,carry=0) =
     i < len(steps)
     ? let (s = steps[i])
       abs(s[1]) == 180
         ?  simplify (steps, i+1,carry+ s[0])
         :  concat([[s[0]+carry,s[1]]],
             simplify (steps, i+1,0))
      : [];
 
function outer(g) =
      outer_edges(group_edges(g));
  
function copy_group(group,m) =
    [for (g = group) copy_tile(g,m)];
   
function rcopy_group(group,m,n) =
     n > 0 ?
       let (t = copy_group(group,m))
       concat(group,rcopy_group(t,m,n-1))
       : group;  
 
 function group_to_tile(g) =
    let (outer_edges = outer(g))
    let (points = edges_to_points(connect_edges(outer_edges)))
    let (peri = simplify(tile_to_peri(points)))
    peri_to_tile(peri);
    
function centre_group(g) =
    let(cs = [for (t=g) v_centre(t)])
    let(c=v_centre(cs))
    [for (t=g) translate_tile(t,-c)];
   
function inset_group(g,d)=
   [for (t=g)  inset_tile(t,d)];

module outline_tile(t,d=0.1) {
     difference(){
          fill_tile(t);
          fill_tile(inset_tile(t,d));
   };
 };
 
module outline_tile_centred(t,d) {
   difference(){
          fill_tile(inset_tile(t,-d/2));
          fill_tile(inset_tile(t,d/2));
   };
 };

module line_tile(t,d=0.01) {
      for (i=[0:len(t)-1]) {
           hull() {
               translate(t[i]) sphere(d);
               translate(t[(i+1) % len(t)]) sphere(d);
           }
           translate(t[i]) sphere(2*d);
       }
}
module number_tiles(group,size=0.02) {
   for (i=[0:len(group)-1])  
       translate([0,0,2]) translate(v_centre(group[i])) scale(size) text( chr(i + 48));  
}
module repeat_tile(n,m,dx,dy) {
   for (j=[0:m-1])
      for(i=[0:n-1]) {
          trans= i*dx+j*dy;
             translate(trans)
               children();
      }
}
