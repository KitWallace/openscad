module cagegear(r,n,h,d,p,a) {
 difference() {
   union() {
     linear_extrude(height=h) circle(r);
     translate([0,0,d])  linear_extrude(height=h) circle(r);
      for (i=[1:n]) {
          rotate(i * 360 / n)
            translate ([r - 2*p,0,0])
               linear_extrude(height=d) circle(p);
      }
   }
   translate([0,0,-1])  linear_extrude(height=d+ 2 * p) circle(a);
 }
}

$fa = 0.01;
$fs = 0.5;
cagegear(20,12,2,10,2,3);