$fa = 0.01; $fs =2; 
pi = 3.14159265359;
max=200;
function v_sum_r(v,n,k) =
      k > n ? 0 : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

module facade () {
    difference()  {  
         rotate([0,90,0])  child(0);
         translate([max-1,0,-max]) cube (2*max,center=true);
    }
}

module bottom(x) {
     difference() {
          child(0);
          translate([0,0,$max+x]) cube(2*$max,center=true);
   
  }
}

module top(x) {
      difference() {
          translate([0,0,-x]) child(0);
          translate([0,0,-$max]) cube(2*$max,center=true);
     }
}


//--------------------------------------------------------------------------------------

//  modules to build simple greek columns

module capped_column (r1,r2,height,caps=0,delta=0) {
    if (caps==0) {  //none 
         cylinder(r1=r1,r2=r2,h=height+delta,center=true);
    }
   if (caps==1)  // top
    union() {
       translate([0,0,-r2/2]) 
          cylinder(r1=r1,r2=r2,h=height-r2+delta,center=true);
       translate([0,0,height/2-r2-delta]) sphere(r2);
    }
  if (caps==2) // bottom
    union() {
       translate([0,0,r1/2]) 
          cylinder(r1=r1,r2=r2,h=height-r1+delta,center=true);
       translate([0,0,-(height/2 -r1-delta)]) sphere(r1);
    }
  if (caps==3) // both
    union() { 
       cylinder(r1=r1,r2=r2,h=height-r1-r2,center=true);
       translate([0,0,-(height/2 - r1-delta)]) sphere(r1);
       translate([0,0,height/2 - r2-delta]) sphere(r2);
    }
}

module tapered_column(r1,r2,height) {
    cylinder(r1=r1,r2=r2,h=height,center=true);
}

module tapered_fluted_column(r1,r2,height,nflutes=20,arris=0,caps=0,delta=0.2) {
    assign(flute_r1 = (1 - arris) *  pi * r1  / nflutes,
               flute_r2 = (1 - arris) * pi * r2  / nflutes, 
               taper = atan((r1-r2)/height)
              )
      {
        echo("flute_r1",flute_r1,"flute_r2",flute_r2); 
        translate([0,0,height/2])
            difference ()  {
                tapered_column(r1=r1,r2=r2, height =height);    
                for (i = [1:nflutes]) {
                     rotate( [0,0,i *360 /nflutes]) 
                     translate([(r1+r2)/2,0,0]) 
                         rotate([0,-taper,0])
                             capped_column(r1=flute_r1,r2=flute_r2, height=height, caps=caps,delta=delta);
                }
          } 
   }
}

module slab(radius,height) {
      translate([0,0,height/2])
           cube([radius*2, radius*2,height],center=true);
}

module rounded_slab(radius,height,round) {
      translate([0,0,height/2])
      minkowski() {
           cube([radius*2, radius*2,height],center=true);
           sphere(round);
     }
}

module fillet(radius, height) {
   translate([0,0,height/2]) cylinder(r=radius,h=height,center=true);
}

module trocia (radius, height,offset) {
    assign(trocia_radius = height/2)
    translate([0,0,trocia_radius])
       difference() {
         cylinder(r=radius,h=height,center=true);
         rotate_extrude(convexity = 10)  
               translate([radius+offset, 0,  trocia_radius])  
                  circle(r = trocia_radius);
     }
}

module torus(radius, height) {
    assign(torus_radius =height/2)
    assign(inner_radius = radius - torus_radius) {
    echo("torus_radius",torus_radius);
    translate([0,0,torus_radius]) {
       rotate_extrude(convexity = 10)  
            translate([inner_radius, 0, 0])  
               circle(torus_radius);
        cylinder(r=inner_radius,h=height,center=true);
    }
  }
}

module stack (separations) {
    union() {
       for (i = [1:len(separations)]) {
           assign(offset = v_sum(separations,i)) {
               echo("i",i,"offset",offset);
               translate ([0,0,offset])
               child(i-1);
          }
      }
   }
}

// a 20 sided straight fluted column with an attic base, and doric capital

module column() {
stack( [0,6,5,1,4,1,4,0.5,0.5,0.5,185,1,5,1,3]) {
// first an attic base 
   slab(20,6);
   torus(20,5);
   fillet(18,1);
   trocia(17,4,0);  
   fillet(16,1);
   torus(18,4);
   fillet(16,0.5);
   fillet(15,0.5);
   fillet(14,0.5);
// then the fluted column
   tapered_fluted_column( r1=13,r2=13,height=185,caps=0);
   fillet(11,1); // hypertrachelium
   tapered_fluted_column( r1=13,r2=13,height=5,,caps=1);
   fillet(13,1);
 // the echinus - bottum half of torus
   bottom(3) torus (17,6); 
// the abacus
   slab(17,4);  
  }
}

facade() column();

