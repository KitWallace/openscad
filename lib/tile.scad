
/*
Tiling functions

version Nov 2019

To do

- reduction of tiles to  a vertex/edge structure - for export to SVG at least
- unclear which functions work on internal angles (should be all now except where notes
    and on normalised (ie with lengths and angles not just angles - better word needed
    
- unclear which functions handle lsits of tiles and which handle nested lists (and retain the nesting)

- unclear which functions work with 2d and 3d points 
- inset_tile has problems with colinear sides

- language is confused 
    when to use vector as (2 or 3d point) or point or vertex
    when to use vector (as a list) or list or tile (list of points)
    when to use points - a simple list of points
                tile - a synonym for a list of points
                tiles - a list of tiles 
                group - also a list of tiles
                groups - a list of groups
           these differ only in their depth of nesting, and 
           typically operations like scale are applied    recursively through the structure

*/
include <basics.scad>


function angle_between(u, v, eps=0.00001) = 
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     let (d = cross(u,v).z)
     d  > 0 
        ? a 
        : 360 - a;
        
        
function zero(l) =
    l[0] == undef ? 0 : [for (i=[0:len(l)-1]) 0];
   
function shift(l,shift=0) = 
   [for (i=[0:len(l)-1]) l[(i + shift + len(l))%len(l)]];
       
function lshift(l,shift=0) = shift(l,shift);  
   
function rshift(l,shift=0) = 
   [for (i=[0:len(l)-1]) l[(i - shift + len(l))%len(l)]];  

/*
function l_sum_r(l,n,k) =
      k < n ?  l[k] + l_sum_r(l,n,k+1) : zero(l[0]) ;

function l_sum(l) = l_sum_r(l,len(l),0);
// function v_sum(v,n) = v_sum_r(v,n,0);



*/
   
function l_sum1(l, i = 0, a = 0) =
   i >= len(l) 
      ? a 
      : l_sum1(l, i + 1, a + l[i])
   ;

function l_sum(l) =
     l_sum1(l,0,zero(l[0]));
   

function l_min_r(l,m,i) =
     i < len(l)-1
        ? l[i] < m
           ?  l_min_r(l,l[i],i+1)
           :  l_min_r(l,m,i+1)
        : m ;
function l_min(l) = l_min_r(l,m=l[0],i=1);
 
function l_max_r(l,m,i) =
     i < len(l)-1
        ? l[i] > m
           ?  l_max_r(l,l[i],i+1)
           :  l_max_r(l,m,i+1)
        : m ;
function l_max(l) = l_max_r(l,m=l[0],i=1);
   
function l_avg(l) =l_sum(l) / len(l);
 
function v_avg(v) = l_avg(v);              

// operations on lists of points  
function 3d_to_2d(points)=
    [ for (p=points) [p.x,p.y]];
        
function 2d_to_3d(points)=
    [ for (p=points) [p.x,p.y,0]];

function scale_points(points,scale) =
     [for (p=points) p*scale];

function rotate_points(points,angle) =
    let(m=m_rotate([0,0,angle]))
    [for (p=points) m_transform(p,m)];
    
function translate_points(points,d) =
    [for (p=points) p+d];

function bounding_box(points) =
  let (b=[min(slice(points,0)),
          max(slice(points,0)),
          min(slice(points,1)),
          max(slice(points,1))])
     [ [b[0],b[3],0],
       [b[0],b[2],0],
       [b[1],b[2],0],
       [b[1],b[3],0]  
      ];  

function dimensions(points) =
    let (b=[min(slice(points,0)),
          max(slice(points,0)),
          min(slice(points,1)),
          max(slice(points,1))])
    [b[1]-b[0],b[3]-b[2]];
    
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
function scale_peri(peri,scale) =
   [for (p=norm_peri(peri))
      [scale * p[0],p[1]] 
   ];
 
function int_to_ext(peri) =
    [for (p=norm_peri(peri)) [p.x,180-p.y]];

function ext_to_int(peri) = int_to_ext(peri);
    
function multiple(p,n) =
   [for (i=[0:n-1]) p];

function repeat(p,n) =
   norm_peri( flatten([for (i=[0:n-1]) p]));
 
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
function in_360(a) =
      (a + 360) % 360;
      
function mirror_peri(peri)=   
      flatten([for (p=peri)
         let(a= in_360(p.y))
         [[p.x,360-a]]
    ]);
      
function convex(peri,i=0) =
   i<len(peri)
     ? peri[i].y > 0  && peri[i].y < 180  && peri[i].x > 0 && convex(peri,i+1)
     : true;

function total_internal(peri) =
     l_sum([for (a= slice(peri,1)) a<180 ? a : 180 - a]);

function total_external(peri) =
     l_sum([for (a= slice(peri,1)) let(e= a<0 ? 360+a : a)  180 - e]);
   
function polygon(peri,eps=0.0001) =
     abs(total_external(peri)- 360) < eps;
  
//  perimeter operations   
//  perimeter is  defined as a sequence of length/interior angle pairs, going anticlockwise 

function peri_to_points(peri,pos=[0,0,0],dir=0,i=0) =
    i == len(peri)
      ? [pos]
      : let(side = peri[i])
        let (distance = side[0])
        let (newpos = pos + distance* [cos(dir), sin(dir),0])
        let (angle = side[1])
        let (newdir = dir + (180 - angle))
        concat([pos],peri_to_points(peri,newpos,newdir,i+1)) 
     ;  
               
function peri_to_tile(peri,last=false) = 
    let (p = peri_to_points(norm_peri(peri)))  
    last 
       ? [for (i=[0:len(p)-1]) p[i]] 
       : [for (i=[0:len(p)-2]) p[i]]; 

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
     l_sum(v) == 0;

       
function isPolygon(peri) =
       let (n = len(peri))
       abs(total_internal(peri) - (n - 2) * 180)<  0.01;
       
function isConvex(peri,i=0) =
   i < len(peri)
     ? peri[i][1] > 0  && peri[i][1] < 180  && peri[i][0] > 0 && isConvex(peri,i+1)
     : true;     

function sym_tab(shoulder_ratio,angle,inset) =
[
     [shoulder_ratio/2, 360-angle],
     [inset/sin(angle), angle],
     [2*inset/tan(angle)+(1-shoulder_ratio)/2, angle],
     [2*inset/sin(angle), 360-angle],
     [2*inset/tan(angle)+(1-shoulder_ratio)/2, 360-angle],
     [inset/sin(angle),angle],
     [shoulder_ratio/2, 0]
     ];

function random_peri(n,min_length,max_length,min_angle,max_angle) =
   let (p1 =
    [for (i=[0:n-2])
        [ min_length==max_length ? min_length : rands(min_length,max_length,1)[0], 
           min_angle==max_angle ? min_angle : rands(min_angle,max_angle,1)[0]]
    ])

   let(p2 = tile_to_peri(peri_to_tile(p1,true)))  // close the polygon

   
   let(ln= p2[n-1][0])
   let(an= p2[n-1][1])
   let(an1= p2[n-2][1])
   isConvex(p2) &&
   isPolygon(p2) &&
           between (min_length,max_length,ln)
       &&  between (min_angle,max_angle,an) 
       &&  between (min_angle,max_angle,an1) 
    
       ? p2
       : random_peri(n,min_length,max_length,min_angle,max_angle)
  ;

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
    
function tile_to_peri(points,complete=true) =
    let(last = complete?1:2)
    [for (i=[0:len(points)- last])
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

function scale_tile(t,scale) = scale_points(t,scale);

function transform_tile(tile,m) =
    [for (p = tile) m_transform(p,m)];
    
function centre_tile(t) =
    let(c = l_avg(t))
    translate_points(t,-c);

function origin_tile(t) =
    let(box=bounding_box(t))
    translate_points(t,-box[1]);

function distance_between(tile1,tile2) =
    l_avg(tile2) - l_avg(tile1);
     
function triangle(a,b) = norm(cross(a,b))/2;

function tile_area(tile) =
// convex only
     l_sum([for (i=[0:len(tile)-1])
           triangle(tile[i], tile[(i+1)%len(tile)]) ]);

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

// create the tile inset by d 

//  doesnt handle the case where v1 and v2 are colinear (eg when the angle between them is 180 
// or where a side length is 0
// or where 
// current fix doesnt really work  but its Ok for small d
function inset_tile(tile, d=0.1) =
  [for (i=[0:len(tile)-1])
      let (v1 = unitv(tile[(i+len(tile) - 1 )% len(tile)] - tile[i]))
      let (v2 = unitv(tile[i] - tile[(i+1 )% len(tile)] ))
      let (vm = unitv((v1 - v2) /2))
      let (a = 180 - angle_between(v1,v2))
      let (offset = d / sin(a/2))
      tile[i]+offset * vm
  ];
  
function replace_sides(peri,sides) =
 flatten( [for (i=[0:len(peri)-1])
      let (bside = peri[i])
      let (mside =  sides[i % len(sides)])
      let (mside_m = 
              len(mside) >1 
                 ? concat([for (i=[0:len(mside)-2]) mside[i]],[[mside[len(mside)-1][0],bside[1]]])
                 : [[mside[0][0],bside[1]]]
           )
      let (mside_length = peri_error(mside_m))
      let (mside_scaled = scale_peri(mside_m,bside[0]/mside_length))
      mside_scaled
  ]);

function tabbed_tile(tile,tab)  =
  let(aperi=tile_to_peri(tile))
  let(tperi=replace_sides(aperi,[tab]))
  peri_to_tile(tperi);


     
function uniform_tabbed_tile(tile,shoulder_ratio,angle,inset)=
     let(peri=tile_to_peri(tile))
     peri_to_tile(flatten(
     [for (side=peri)
        let(d=side[0])
        let(a=side[1])
     [
     [d*shoulder_ratio/2, -angle],
     [inset/sin(angle), angle],
     [2*inset/tan(angle)+d*(1-shoulder_ratio)/2, angle],
     [2*inset/sin(angle), -angle],
     [2*inset/tan(angle)+d*(1-shoulder_ratio)/2, -angle],
     [inset/sin(angle),angle],
     [d*shoulder_ratio/2, a]
     ]
     ]));
               
/* function to test niceness of a tile
   max / min < pmin
   all angles > amin
   all 180-angles > amin

*/
                 
// operations on lists of tiles 

function scale_tiles(tiles,scale) =
// handles nested lists
   [for (t=tiles) 
      depth(t)==2
        ? scale_tile(t,scale)
        : scale_tiles(t,scale)
   ];

function transform_tiles (tiles,m) =
    [for (t = tiles) 
       depth(t)==2
         ? transform_tile(t,m)
         : transform_tiles(t,m)
    ];
      
function inset_tiles(tiles,d)=
   [for (t=tiles) inset_tile(t,d)];

function centre_tiles(tiles) =
    let(cs = [for (t=tiles) l_avg(t)])
    let(c=l_avg(cs))
    [for (t=tiles) translate_points(t,-c)];
     
function explode_tiles(tiles,factor) =
   [for (t=tiles)  
     let (c = l_avg(t))
     let (d = c*factor)
        translate_points(t,d)
   ];
  
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
   color("black")
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

/*
  function edge(points,i) =
   [points[(i-1 +len(points)) % len(points)],points[i %len(points)]];
*/
  
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

function copy_tile_to_edge(source,i,target,j,end=0) =
   let (m = m_edge_to_edge(edge(source,i),edge(target,j),end))
   transform_tile(source,m);
 
 function copy_tile_to_edges(source,i,targets,j) =
     [for (k=[0:len(targets)-1])
          transform_tile_to_edge(source,i,targets[k],j)
     ] ; 
     
 function copy_tile_to_position(source,steps) =
    let (points= peri_to_tile(steps))
    let (end = points[len(points)-1])
    let (m = m_pos_dir(end))
    transform_tile(source,m);  
     
function rcopy_tile(tile,m,n) =
     n > 0 ?
       let (t = transform_tile(tile,m))
       concat([tile],rcopy_tile(t,m,n-1))
       : [tile];     

function offset_tile(t,sedge,tedge,end=0) =
      distance_between(t,copy_tile_to_edge(t,sedge,t,tedge,end));

// ??? 
function offset_group(g,offset) = group_offset(g,offset);
     
function group_offset(g,offset) =
     let(end = offset[4]== undef ? 0 : offset[4])
     distance_between(g[offset[0]],
         copy_tile_to_edge(g[offset[0]],offset[1],g[offset[2]],offset[3],end));
        
function tile_offset(tiles,source,target) =   
     let(end = target[2]== undef ? 0 : target[2])
     distance_between(tiles[source[0]],
         copy_tile_to_edge(tiles[source[0]],source[1],tiles[target[0]],target[1],end));
 

//groups of tiles to create a tiling unit
/*
 assemble a group of tiles using assembly instructions
 these are a sequence of copy instructions to copy the base tile to other tiles
 each instruction defines
    [[source tile]
     [destination tile]
     ]
     source tile is
       [index of tile in tile list,
        edge of tile,
        1 if mirrored]
     destination tile is
    [index of tile in growing group,
     edge of tile ,
     1 if align to far end of edge]
     

*/
function group_tiles(tiles,assembly,group=[],i=0) =
    i==len(assembly)
        ? group
        : let(move = assembly[i])
          let(source = move[0])
          let(source_tile = len(source)==3 ? mirror_tile(tiles[source[0]])  : tiles[source[0]] )
          len(move) ==1
             ? group_tiles(tiles,assembly,[source_tile],i+1)
             : let (dest = move[1])
               let (end = len(dest)==3 ? 1 : 0)
               let (nt = copy_tile_to_edge(source_tile,source[1],group[dest[0]],dest[1],end))
               group_tiles(tiles,assembly,concat(group,[nt]),i+1);
               
// break this up into 
// create list of transformations 
// apply the transformations

function group_transforms(tiles,assembly,group=[],transforms=[],i=0) =
    i==len(assembly)
        ? transforms
        : let(move = assembly[i])
          let(source = move[0])
          let(source_i=source[0])
          let(source_side=len(source)==2 ? source[1] :0)
          let(mirror = len(source)==3 ? 1 : 0)
          let(source_tile = mirror==1 ? mirror_tile(tiles[source_i]) : tiles[source_i] )
          len(move) ==1
             ? let (m = m_edge_to_edge(edge(source_tile,0),edge(source_tile,source_side)))
               let (nt = transform_tile(source_tile,m))
               let (t= [source_i,m,mirror])            
               group_transforms(tiles,assembly,concat(group,[nt]),concat(transforms,[t]),i+1)
             : let (dest = move[1])
               let (dest_i=dest[0])
               let (dest_tile=group[dest_i])
               let (dest_side=dest[1])
               let (end = len(dest)==3 ? 1 : 0)
               let (m = m_edge_to_edge(edge(source_tile,source_side),edge(dest_tile,dest_side),end))
               let (nt = transform_tile(source_tile,m))
               let (t= [source_i,m,mirror])
               group_transforms(tiles,assembly,concat(group,[nt]),concat(transforms,[t]),i+1);

function apply_group_transforms(tiles,transforms,group=[],i=0) =
     i==len(transforms)
        ? group
        : let (transform = transforms[i])
          let (source_tile=tiles[transform[0]])
          let (m=transform[1])
          let (mirror = transform[2])
          let(nt = 
                   mirror
                       ?  transform_tile(mirror_tile(source_tile,m))
                       :  transform_tile(source_tile,m)
                       )
          apply_group_transforms(tiles,transforms,concat(group,[nt]),i+1);

// tesselate one or more tiles 
function tesselate_tiles(tiles,n,m,dx,dy) =
    [ for (j=[0:m-1])
      for (i=[0:n-1])
      let (trans= i*dx+j*dy)
      [for (t=tiles)
          translate_points(t,trans)
      ]
    ];
     
 function tesselate_tiles_orientation(tiles,n,m,dx,dy) =
    [[ for (j=[0:m-1])
      for (i=[0:n-1])
      let (trans= i*dx+j*dy)
      [for (t=tiles)
          translate_points(t,trans)
      ]
    ],
    atan2(dx.y,dx.x),
    atan2(dy.y,dy.x)
    ];

// tesselate one or more tiles
// offset to counter diagonal in positive xy quadrant
      
function tesselate_tiles_offset(tiles,n,m,dx,dy) =
    [ for (j=[0:m-1])
      let(rj=(j%2==0)?j/2:(j-1)/2)
      for (i=[0:n-1])
      let(trans= (i+rj)*dx+j*dy)
      [for (t=tiles)
          translate_points(t,trans)
      ]
    ];
               
// add tests for tile overlap 
           
// to convert a set of tiles to a single tile
// only works on edge-to-edge configurations
      
 function eq(a,b,eps=0.00001) =
      norm(a - b) <= eps;
            
 function equal_edge(e1,e2) =
     eq(e1[0],e2[0]) && eq(e1[1], e2[1])
    ||  eq(e1[0],e2[1]) && eq(e1[1], e2[0])     ; 

//get all edges in a group
function group_edges(tiles) =
    let(edges = flatten(
         [for (tile = tiles)
            [for (i =[0:len(tile)-1])
                [tile[i],tile[(i+1)%len(tile)]]
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
   // if abs(step.angle - 180) < eps  then carry distance.
   // if not add carry to distance and output step
   
function simplify(steps,i=0,carry=0,eps=0.0001) =
     i < len(steps)
     ? let (s = steps[i])
       abs(abs(s[1]) - 180)  < eps  // colinear
         ?  simplify (steps, i+1,carry+ s[0])
         :  let (d=s[0]+carry)
            d > 0
              ? concat([[d,s[1]]],  simplify (steps, i+1,0))
              :[]
      : [];
 
function outer(g) =
      outer_edges(group_edges(g));

function rcopy_group(group,m,n) =
     n > 0 ?
       let (t = transform_tiles(group,m))
       concat(group,rcopy_group(t,m,n-1))
       : group;  

// convert a set of tiles into one tile representing their boundary

function tiles_to_tile(tiles) =
    let (outer_edges = outer(tiles))
    let (points = edges_to_points(connect_edges(outer_edges)))
    let (peri = simplify(tile_to_peri(points)))
    peri_to_tile(peri);


// to crop tiles to a bounding box 

function point_in_box(p,box)=
       p.x >= box[0].x
    && p.x <= box[1].x
    && p.y >= box[0].y
    && p.y <= box[1].y
    ;
function points_in_box(points,box,i=0) =
   i< len(points)
    ? let(p=points[i])
      point_in_box(p,box)
       ? points_in_box(points,box,i+1)
       : false
    : true;
    
function crop_tiles(tiles,box) =
   [for (t=tiles)
       if(points_in_box(t,box)) t
   ];
       
function crop_groups(groups,box) =
   [for (group = groups)       
       if(points_in_box(flatten(group),box)) group
   ];
       
// tile to objects  
  
module fill_tile(tile,col="red") {
    color(col)
       polygon(3d_to_2d(tile)); 
};

module fill_tiles (tiles,colors=["lightgreen"]) {
    for (i=[0:len(tiles)-1]) {
       colors = colors[i % len(colors)];
       t=tiles[i];  
        if(depth(t)==2)
            fill_tile(t,colors); 
       else fill_tiles(t,[colors]);          
   }
}
module fill_group_shape (group,colors=["lightgreen"]) {
    for (i=[0:len(group)-1]) {
        g=group[i];  
        if(depth(g)==2) {
           color = colors[len(g)];
           fill_tile(g,color);
           } 
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
       translate([0,0,2]) translate(l_avg(group[i])) scale(size) text( chr(i + 48));  
}

module repeat_tile(n,m,dx,dy) {
   for (j=[0:m-1])
      for(i=[0:n-1]) {
          trans= i*dx+j*dy;
          translate(trans)
               children();
      }
}


// interpolate between points in a path
// two versions for closed (default) and open paths
weight = [-1, 9, 9, -1] / 16;

// closed paths
function interpolate(path,n,i) =
        path[(i + n - 1) %n] * weight[0] +
        path[i]             * weight[1] +
        path[(i + 1) %n]    * weight[2] +
        path[(i + 2) %n]    * weight[3] ;

function subdivide(path) = 
    flatten([for (i =[0:len(path)-1]) 
       [path[i],interpolate(path, len(path), i)]]);

function smooth(path,n) =
    n == 0
     ?  path
     :  smooth(subdivide(path),n-1);
    
// open path
function interpolate_open(path,n,i) =
        path[max(i-1,0)]        * weight[0] +
        path[i]               * weight[1] +
        path[min(i+1,n-1)]    * weight[2] +
        path[min(i+2,n-1)]  * weight[3] ;
   
function subdivide_open(path) = 
    flatten([for (i =[0:len(path)-1]) 
       [path[i],interpolate_open(path, len(path), i)]]);

function smooth_open(path,n) =
    n == 0
     ?  path
     :  smooth_open(subdivide_open(path),n-1);
