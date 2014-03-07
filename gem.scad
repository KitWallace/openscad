/*
  create a brilliant cut diamond based on the guidance in 
     http://www.usfacetersguild.org/gem_designs/simple_brilliance/
  with an added culet to make a total of (1+16+8+8+16+1+16 )= 66 facets
  
  function make_facets() creates the data for each facet 
     (index_angle, axial_angle and height) 
  based on data in the design
  e.g.
     B 	35.00 	01-03-05-07-09-11-13-15-17-19-21-23-25-27-29-31
  translates to 
     make_facets(1,2,32,35)

  the distance from the centre of these facets is height and 
  this is set by experimentation to make the facets follow the pattern
  (I guess they could be computed but changing them by hand retains a 
   sense of the operation of a mechanical faceting machine)

  gem() then recursively creates each facet and removes it from 
  the remainder of  the original cube

  thanks to nop-head and the openscad forum

  Kit Wallace 
*/

function make_facets(start,increment,limit,axial_angle,height) =
    start <= limit
      ? concat([[start/limit*360, axial_angle, height]] ,
               make_facets(start+increment,increment,limit,axial_angle,height))
      : [] ;

module body(Size=100) {
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

module gem(facets,n) {
   difference() {
      if (n==1) body(); else gem(facets,n-1);
      cut_facet(facets[n-1]);
   }
}

function brilliant_facets() =
 concat( 
   make_facets(1,1,1,0,2.28),      // table
   make_facets(1,1,1,180,7.8),     // culet
   make_facets(1,2,32,35,5),       // B
   make_facets(4,4,32,30,4.46),    // M
   make_facets(2,4,32,16,3.46),    // S
   make_facets(2,2,32,90,8.5),     // girdle
   make_facets(1,2,32,42+180,6)    // C
 ); 

facets = brilliant_facets();
// echo (len(facets), facets);

scale(3) gem(facets,len(facets));
