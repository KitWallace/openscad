/*
  create a gem based on the guidance in 
     http://www.usfacetersguild.org/gem_designs
     and http://www.ukfcg.org/
  
  see 
  Kit Wallace 
*/

function make_facets(start,increment,limit,axial_angle,height,name) =
    start <= limit
      ? concat([[start/limit*360, axial_angle, height,name]] ,
               make_facets(start+increment,increment,limit,axial_angle,height,name))
      : [] ;

function make_facets_list_r(indexes,i,limit, axial_angle, height,name) =
    i >= 0
      ? concat ([[indexes[i]/limit * 360,axial_angle,height,name,indexes[i]]],
             make_facets_list_r(indexes, i - 1, limit,axial_angle, height,name))
      : [];

function make_facets_list(indexes,limit, axial_angle, height,name) =
    make_facets_list_r(indexes,len(indexes)-1,limit,axial_angle,height,name);

function make_table(height) = [[0,0,height,"table"]];
function make_culet(height) = [[0,180,height,"culet"]];

module body(Size=60) {
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

function pinwheel_facets() =
 concat( 
    make_table(8.4)   
   ,make_culet(19.5)    
   ,make_facets(3,6,96,44.4+180,14.5,"pb")    
   ,make_facets(3,3,96,90,20,"g")        
   ,make_facets(0,12,96,43+180,14.42,"pm")   
   ,make_facets(3,6,96,43.5,13.5,"c1 breaks")       
   ,make_facets(0,12,96,37,12.05,"c2 mains")        
   ,make_facets(6,12,96,22,9.9,"c3 stars")         
   ,make_facets(0,12,96,14,8.95,"c4 high stars")    
   ,make_facets(0,12,96,8,8.3,"c5 pinwheel")       
  );

function ccsq03_facets() =
 concat( 
    make_table(6)   
   ,make_culet(27)    
   ,make_facets(4,4,96,42+180,20,"p1")    
   ,make_facets(0,24,96,90,23.5,"g1")        
   ,make_facets(12,24,96,90,30,"g2")   
   ,make_facets(0,24,96,63+180,21,"p2")
       
   ,make_facets(0,24,96,42,16,"c1")        
   ,make_facets(12,24,96,40,19.5,"c2")         
   ,make_facets(0,24,96,32,13.3,"c3")         
   ,make_facets_list([2,22,26,46,50,70,74,94],96,23,11.35,"c4")    
   ,make_facets(0,24,96,12,8.7,"c5")         
   ,make_facets(12,24,96,22.9,12.9,"c6")       
  );

facets = facets_to(ccsq03_facets(),"p2");
facets = pinwheel_facets();
echo(facets);
gem(facets);
