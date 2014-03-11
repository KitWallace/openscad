/*
  create a gem using faceting instructions 
  see http://kitwallace.tumblr.com/tagged/gem
  Kit Wallace 
*/

function make_facets(start,increment,limit,axial_angle,height,name) =
    start <= limit
      ? concat([[start/limit*360, axial_angle, height,name]] ,
               make_facets(start+increment,increment,limit,axial_angle,height,name))
      : [] ;

function make_facets_rev(start,increment,limit,axial_angle,height,name) =
    start <= limit
      ? concat([[(180 + start/limit*360) % 360, axial_angle+180, height,name]] ,
               make_facets_rev(start+increment,increment,limit,axial_angle,height,name))
      : [] ;

function make_facets_both(start,increment,limit,axial_angle,height,name)=
     concat(
         make_facets(start,increment,limit,axial_angle,height,name),
         make_facets_rev(start,increment,limit,axial_angle,height,name)
     );

function make_facets_list_r(indexes,i,limit, axial_angle, height,name) =
    i >= 0
      ? concat ([[indexes[i]/limit * 360,axial_angle,height,name,indexes[i]]],
             make_facets_list_r(indexes, i - 1, limit,axial_angle, height,name))
      : [];

function make_facets_list(indexes,limit, axial_angle, height,name) =
    make_facets_list_r(indexes,len(indexes)-1,limit,axial_angle,height,name);


function make_facets_list_rev_r(indexes,i,limit, axial_angle, height,name) =
    i >= 0
      ? concat ([[(180 + indexes[i]/limit * 360) % 360,axial_angle+180,height,name,indexes[i]]],
             make_facets_list_rev_r(indexes, i - 1, limit,axial_angle, height,name))
      : [];

function make_facets_list_rev(indexes,limit, axial_angle, height,name) =
    make_facets_list_rev_r(indexes,len(indexes)-1,limit,axial_angle,height,name);

function make_table(height) = [[0,0,height,"table"]];
function make_culet(height) = [[0,180,height,"culet"]];

module body(Size=30) {
    cube(Size,center=true);
}

module cut_facet_data(index_angle,axial_angle,height,Width=100,Depth=50) {
     rotate([0,0,index_angle])
        rotate([0,axial_angle,0])
           translate([0,0,Depth/2 + height])
              cube([Width,Width,Depth],center=true);
}

module cut_facets(facets, n) {
   for (i =[0:n-1]) 
       cut_facet(facets[i]);
}

module cut_facet(facet) {
   cut_facet_data(facet[0],facet[1],facet[2]);
}

function facets_to(facets,name,i=0,start=0) =
    facets[i][3]==name
       ? concat([facets[i]], facets_to(facets,name,i+1,1))
       : start == 0 && i < len(facets)
           ? concat([facets[i]], facets_to(facets,name,i+1,0))
           : []
    ;

module gem_n(facets,n) {
   difference() {
      if (n==1) body(); else gem_n(facets,n-1);
      cut_facet(facets[n-1]);
   }
}

module gem(facets) {
   gem_n(facets,len(facets));
}

function sphere_facets() =
 concat( 
    make_table(10.27)                   
   ,make_culet(10.27) 
   ,make_facets_both(3,6,96,86.3,10,"C1")        
   ,make_facets_both(0,6,96,79.9,10.06,"C2") 
   ,make_facets_both(0,6,96,65.56,10.15,"C3")       
   ,make_facets_both(3,6,96,60.19,10.18,"C4")
   ,make_facets_both(3,6,96,43.64,10.18,"C5")
   ,make_facets_both(0,6,96,40.65,10.19,"C6")
   ,make_facets_both(0,6,96,25.3,10.19,"C7")
   ,make_facets_both(3,6,96,23.91,10.20,"C8")
   ,make_facets_both(3,6,96,8.02,10.18,"C9")
                  
);

facets = sphere_facets();
// sfacets = facets_to(facets,"C9");
echo(len(facets),facets);
gem(facets);
