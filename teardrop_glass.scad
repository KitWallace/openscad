/*  creatung a teardrop shot gass

*/

$fn=50;
eps=0.01;

function scale(base,height,slope) =
    let( top = base + tan(slope)*height)
    top/base;

module teardrop(base,height,scale=1.5) {
     linear_extrude(height=height,scale=scale)
     union () {
         circle(base);
         square(base);
     }
 } 
 
module teardrop_hull(base,height,scale=1.5,round=2) {
     linear_extrude(height=height,scale=scale)
     hull () {
         circle(base);
         translate([base-round/2,base-round/2,0]) 
              circle(round);
     }
 } 

module teardrop_mink(base,height,scale=1.5,round=2) {
  minkowski() {
     linear_extrude(height=height,scale=scale)
        union () {
         circle(base);
         square(base);
     }
     sphere(round);
   }
 }
 
//translate([0,0,-61])
module teardrop_glass(base,height,thickness,slope) {
    outer_scale= scale(base,height,slope);
    top = base * outer_scale;
    inner_base = (base - thickness)+ tan(slope) * thickness;
    inner_scale =  (top -thickness) / inner_base;
 //   echo(outer_scale,top,inner_base,inner_scale);
    difference() {
       teardrop_hull(base,height,outer_scale);
       translate([0,0,thickness])
            teardrop_hull(inner_base, height-thickness+eps,inner_scale);
    //   cube(100);
    }
}


teardrop_glass(15,45,2,8);
