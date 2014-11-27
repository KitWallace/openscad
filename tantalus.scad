//Height of vase
Height=50;
// wall thickness - max 
Thickness = 1.5;
//base radius
Base=10;
// Thickness of Base
Base_Thickness = 1.5;
//Max amplitude of cos coefficient
Amplitude = 8;


function vadd(points,v) =
    [for (p = points) p + v];

function reverse(v) =
    [for (i = [0:len(v)-1])  v[len(v) -1 - i] ];

function coefficients(n,a) =
    [for (i=[0:n-1]) rands(0,a,1)[0] ] ;

function f(t,c) =
     c[1] * cos(t + 20*c[2])
   + c[3] * pow(cos(2*t +20*c[4]),2) 
   + c[5] * pow(cos(3*t +20*c[6]),3) 
   + c[7] * pow(cos(4*t +20*c[8]),4)  
    ;

function path(n,step,c) =
    [for (t=[0:step:n])  [t * step, 
        f(t,c)]];

    module ground() {
   translate([0,0,-100]) cube([200,200,200], center=true);

}

module ruler(n) {
   for (i=[0:n-1]) 
       translate([(i-n/2 +0.5)* 10,0,0]) cube([9.8,5,2], center=true);
}


module vase(base,thickness,step, max,coeff) {  
    assign (cut_path = path(max,step,coeff))
    assign (poly = concat(vadd(cut_path,[0,-thickness/2]),
                         vadd(reverse(cut_path),[0,thickness/2])))
    rotate_extrude()
       rotate([0,0,90]) 
         translate([0,base,0]) 
            polygon(points=poly);
   
};

eps=0.1;
$fn=50;

module ground() {
   translate([0,0,-100])
      cube([200,200,200], center=true);

};

module hemisphere(r){
    difference() {
       sphere(r);
       ground();
    }
};

module tube(r,t,h) {
   difference() {
     cylinder(r=r,h=h);
     translate([0,0,-eps])
        cylinder(r=r-t,h=h+2*eps);
   }
};

module rim(r ,cut, n=1) {
   for(a=[0:180/n:180])
         rotate([0,0,a])
              translate([0,0,cut/2-eps]) 
                  cube([r*2,cut,cut],center=true);
}

module syphon(h,r1,t1,r2,t2,cut=2) {
  difference() {
    tube(r2,t2,h);
    rim(r2+t2,cut);
   }
  translate([0,0,h])
   difference() {
      hemisphere(r2);
      hemisphere(r2-t2);   
   }
 tube(r1,t1,h);
}

eps=0.1;
$fn=60;
Delta= 0.1;
N= 60;
Step = Height / N;
coeff= coefficients(9, Amplitude);
coeff = [1.32822, 1.62383, 3.6031, 2.071, 2.55863, 5.89419, 6.48687, 7.10128, 5.93688];

echo(coeff);
vase(Base,Thickness,Step,N,coeff);

difference() {
     cylinder(h=Base_Thickness,r=Base+f(0,coeff)-Thickness/2);
     translate([0,0,-eps]) cylinder(r=1,Base_Thickness+2*eps);
}

//translate([20,0,0]) rotate([0,90,0]) ruler(10);

translate([0,0,Base_Thickness]) 
    syphon(Height*0.75,2,1,3,0.5);
