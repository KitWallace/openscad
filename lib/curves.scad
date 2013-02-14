EPS = 0.1;

// change a to th - short for theta - but have to do it by hand 
module hypotrochoid(R, r, d, n=50,rev=1) {
// see http://en.wikipedia.org/wiki/Hypotrochoid
//        http://en.wikipedia.org/wiki/Hypocycloid
//        http://en.wikipedia.org/wiki/Deltoid_curve
//  r= d   >  hypocycloid  
//  r= d and R= kr  > deltoid 
// weird things happen if n is too large

// parametric equations :

    function x(R,r,a) = (R-r)*cos(a) + d*cos((R-r)/r*a);
    function y(R,r,a) = (R-r)*sin(a)  -  d*sin((R-r)/r*a) ;      
    assign(dth = rev*360/n)
	for (i = [0:n-1] ) 
            polygon( 
                  [
                   [0,0], 
                   [x(R,r,dth*i), y(R,r,dth*i)], 
	             [x(R,r,dth*(i+1)),  y(R,r,dth*(i+1))]
                  ]
            );
}
//  ..parameters are R = 5, r = 3, d = 5).
*   hypotrochoid(5,3,5,rev=3);
//  Hypocycloid  r = d 
// eg  ..parameters are R=3.0, r=1.0, and d=r) ie a deltoid
//   
//    linear_extrude(height=20)    
//    hypotrochoid(5,3,4,rev=3);
//        hypotrochoid(9,3,3);


module epitrochoid(R, r, d, n=100,rev=1) {
// see http://en.wikipedia.org/wiki/Epitrochoid
//        http://en.wikipedia.org/wiki/Epicycloid

//  r=d  > epicycloid 
// r=d and R=r  > cardiod
// parametric equations :
    function x(R,r,a) = (R+r)*cos(a) - d*cos((R+r)/r*a);
    function y(R,r,a) = (R+r)*sin(a)  -  d*sin((R+r)/r*a) ;      
    assign(dth = rev*360/n)
	for (i = [0:n-1] ) 
            polygon( 
                  [
                   [0,0], 
                   [x(R,r,dth*i), y(R,r,dth*i)], 
	             [x(R,r,dth*(i+1)),  y(R,r,dth*(i+1))]
                  ]
            );
}

//The epitrochoid with R = 3, r = 1 and d = 1/2

*      epitrochoid(3,1,1/2);
* difference() {
       linear_extrude(height=20, twist=180)   epitrochoid(9,3,3);
       translate([0,0,-EPS]) cylinder(r=8,h=20+2*EPS);
}
  

* difference() {
        
          minkowski() {
                linear_extrude(height=20) epitrochoid(10,10,10); 
                cylinder(3);
         }  
         translate([0,0,3]) 
                linear_extrude(height=20+2*EPS) epitrochoid(10,10,10);
 }

* epitrochoid(10,10,10);

module rose(R, k, n=100,rev=1) {
// see http://en.wikipedia.org/wiki/Rose_%28mathematics%29
// parametric equations :
    function x(R,k,a) = R*cos(k*a) * sin(a);
    function y(R,k,a) = R*cos(k*a) * cos(a);   

// generate curve by sectors
    assign(dth = rev*360/n)
	for (i = [0:n-1] ) 
            polygon( 
                  [
                   [0,0], 
                   [x(R,k,dth*i), y(R,k,dth*i)], 
	           [x(R,k,dth*(i+1)), y(R,k,dth*(i+1))]
                  ]
            );
}

* linear_extrude(height=20)  rose (10,0.5,rev=2,n=300);

module circle_involute(R, f, n=50,rev=1) {
// see http://en.wikipedia.org/wiki/
// this caught me out because the dimensions get very large very quickly so it looks flat

// parametric equations :
    function x(R,a) = cos(a) + a * sin(a);
    function y(R,a) = sin(a) +  a * cos(a);   

    assign(da = rev*360/n)
	for (i = [1:n] ) 
            polygon( 
                  [
                   [x(R,da*i)*f, y(R,da*i)*f ], 
                   [x(R,da*i), y(R,da*i)], 
	             [x(R,da*(i+1)),  y(R,da*(i+1))],
                   [x(R,da*(i+1))*f,  y(R,da*(i+1))*f]
                  ]
            );
}

*linear_extrude(height=100)
     circle_involute(10,0.7,rev=0.75);
     
function radians(d) = d * 2 * PI / 360;


module archimedean_spiral(a,b,f,n=100,rev=1) {
// see http://en.wikipedia.org/wiki/
// this caught me out because the dimensions get very large very quickly so it looks flat

// parametric equations :
    function x(a,b,theta) = (a + b* theta) * sin(theta) ;   
    function y(a,b,theta) = (a + b* theta) * cos(theta) ;
 
    assign(da = rev*360/n)
	for (i = [1:n] ) 
            polygon( 
                  [
                   [x(a,b,da*i)*f, y(a,b,da*i)*f ], 
                   [x(a,b,da*i), y(a,b,da*i)], 
	             [x(a,b,da*(i+1)),  y(a,b,da*(i+1))],
                   [x(a,b,da*(i+1))*f,  y(a,b,da*(i+1))*f]
                  ]
            );
}

*linear_extrude(height=10)
     archimedean_spiral(10,0.03,0.9,rev=2);
     
$fn=20;
module spiral(a,b,f,n=100,rev=1) {
// see http://en.wikipedia.org/wiki/
// this caught me out because the dimensions get very large very quickly so it looks flat

// parametric equations :
    function x(a,b,theta) = (a + b* theta) * sin(theta) ;   
    function y(a,b,theta) = (a + b* theta) * cos(theta) ;
 
    assign(da = rev*360/n)
	for (i = [1:n] ) 
            translate([x(a,b,da*i), y(a,b,da*i),0])
            circle(f);
}
 linear_extrude(height=10)  spiral(10,0.03,2,rev=2);


function sign(x) =  x > 0 ? +1 : -1;

module superellipse(R, p, e, n=100) {

// see  http://en.wikipedia.org/wiki/Superellipse

      function x(R,p,e,a) =  R * pow(abs(cos(a)),2/p) * sign(cos(a)) ;
      function y(R,p,e,a) =  R *e * pow(abs(sin(a)),2/p) * sign(sin(a)) ;    
      assign(dth = 360/n)
	for ( i = [0:n-1] ) {
          echo( x(R,p,e,dth*i), y(R,p,e,dth*i));
          polygon( 
                  [
                    [0,0], 
	              [x(R,p,e,dth*i), y(R,p,e,dth*i)], 
	              [x(R,p,e,dth*(i+1)),  y(R,p,e,dth*(i+1))]
                  ] );
        }
}

$fa=0.01; $fs=0.5;

rotate_extrude() superellipse(20,5,1.25);
