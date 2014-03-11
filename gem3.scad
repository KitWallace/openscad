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

module body(Size=70) {
    cube(Size,center=true);
}

module cut_facet_data(index_angle,axial_angle,height,Width=200,Depth=50) {
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

function gem_facets() =
 concat( 
    make_table(12)                   
   ,make_culet(12)                   
   ,make_facets(0,24,96,60,10,"C1")       
   ,make_facets_rev(0,24,96,60,10,"P1")  
   ,make_facets(0,12,96,90,10.6,"G2")       
   ,make_facets(12,24,96,51,11.5,"C2")       
   ,make_facets_rev(12,24,96,51,11.5,"P2")       
   ,make_facets(6,12,96,45,10.4,"C3")
   ,make_facets_rev(6,12,96,45,10.4,"P3")
       
   ); 

facets = gem_facets();
sfacets = facets_to(facets,"P3");
echo(sfacets);
gem(sfacets);
