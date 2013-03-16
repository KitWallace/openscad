
use <fluted_column.scad>;

module groin_vault (r,l,t) {
   difference() {
   rotate([0,90,0])
   difference () {
     union(){
          cylinder(r=r/2,h=l,center=true);
          rotate([90,0,0])  cylinder(r=r/2,h=l,center=true);
     }
     union() {
               translate([0,0,-1]) cylinder(r=r/2-t,h=l+4,center=true);
               rotate([90,0,0])   translate([0,0,-1]) cylinder(r=r/2-t,h=l+4,center=true);
      }
   }
    translate([0,0,-50]) cube(100,center=true);
  }
}

*groin_vault(20,20,2);

module grid_replicate(x_spacing,y_spacing,x_n,y_n) {
    for (i = [0:x_n -1])
       for (j=[0:y_n -1])
          translate([i *x_spacing , j*y_spacing,0]) child();
}

module column () {
     stack([0,1,1,12,1]) {
         slab(2,1);
         torus(1.5,1);
         tapered_fluted_column(radius=2,height=12,nflutes=0);
         slab(1.5,1);
     }
}

module colonade(spacing,overlap,height,thickness,x_n,y_n){
assign(grid_space= spacing - overlap) {
   grid_replicate(grid_space,grid_space,x_n,y_n) {
       translate([0,0,height]) groin_vault(spacing,spacing,thickness);
       }

   translate ([-grid_space/2,-grid_space/2,0])
      grid_replicate(grid_space,grid_space,x_n+1,y_n+1) {
          column();
       }
  }
}

$fa=0.01; $fs=0.5;
colonade(20,2,15,2,4,3);


