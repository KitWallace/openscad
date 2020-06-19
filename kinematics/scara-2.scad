
// there are always 2 positions of the arms to get to [x,y] , except inthe degenerate case where [x,y] is on the limiting circle, with the elbow either side of the line from origin to [x,y]  

//  this algorithm returns both solutions because incrementally we want to minimize movement, so need to choose the solution to [x+dx,y+dy] closest to [x,y]

// points outside the radius of the scara need to be rejected 
// note that r2 must be = r1 , otherwise there will be points inside which are unreachable

// show the pose of the the scara - this is valuable for testing that all points within the scara radius are reachable

  
function forward_scara(r1,r2,ab) =
  let (a = ab[0])
  let (b = ab[1])
  [r1*cos(a) + r2*cos(a+b),
   r1*sin(a) + r2*sin(a+b)];

function reachable(r1,r2,xy) =
   let (x = xy.x)
   let (y = xy.y)
   let (L = sqrt(x*x+y*y))
   L <= (r1+r2)  && L>= abs(r1-r2);
   
function reverse_scara(r1,r2,xy) =
   let (x = xy.x)
   let (y = xy.y)
   let (L = sqrt(x*x+y*y))
   let (a1= atan2(y,x))
   let (a2= acos((r1*r1+L*L - r2*r2)/(2*r1*L)))
   let (eps = 0.00001)
   let (b =  (abs(r1+r2 -L) < eps) 
              ? 0   // degenarate case where arm 1 and arm 2 are colinear
              : acos((r1*r1+r2*r2-L*L)/( 2*r1*r2)) - 180)
   [[a1+a2,b],[a1-a2,-b]];

function increment_scara(r1,r2,current_ab,next_xy) =
  let (next_ab = reverse_scara(r1,r2,next_xy))
  let (ab_diff= [for (ab = next_ab) norm(current_ab - ab)])
   (ab_diff[0] < ab_diff[1]) ? next_ab[0] : next_ab[1] ;

function polar_to_xy(polar) =
  let (r=polar[0])
  let (theta = polar[1])
  [r*cos(theta), r*sin(theta)];
  
 // scara arms
 r1=15;
 r2=15;
  
module round_trip_ab(ab=[0,0]){
 echo("test round tripping ab<>xy");
 echo ("ab",ab);
 xy = forward_scara(r1,r2,ab);
 echo("xy",xy);
 ab2= reverse_scara(r1,r2,xy);
 echo("ab2",ab2);
};

module round_trip_xy(xy=[0,0]) {
 echo("test round tripping xy <> ab");
 echo("xy",xy);
 ab= reverse_scara(r1,r2,xy);
 echo("ab",ab);
 xy1=forward_scara(r1,r2,ab[0]);
 echo("xy1",xy1);
 xy2=forward_scara(r1,r2,ab[1]);
 echo("xy2",xy2);
}
  
module xy_increment(){
 echo("move between points");
 p=[5,5];
 echo("from",p);
 ab_p = reverse_scara(r1,r2,p)[0];
 echo("p angles",ab_p);
 q=[5.1,4.9];
 echo("to",q);
 ab_q = increment_scara(r1,r2,ab_p,q);
 echo ("q angles",ab_q);
 ab_diff = ab_q - ab_p;
 echo ("diff",ab_diff,"degrees");   
}

module polar_increment() {
 echo("move between polar points");
 p=[10,60];
 echo("from",p);
 ab_p = reverse_scara(r1,r2,polar_to_xy(p))[0];
 echo("p angles",ab_p);
 q=[10.1,61];
 echo("to",q);
 ab_q = increment_scara(r1,r2,ab_p,polar_to_xy(q));
 echo ("q angles",ab_q);
 ab_diff = ab_q - ab_p;
 echo ("diff",ab_diff,"degrees");   
}
$fn=50;
module arm(length,r) {
    hull() {
        circle(r);
        translate([length,0]) circle(r);
    }
}

module show_scara(r1,r2,xy,radius=0.2,k=0) {
    if (!(reachable(r1,r2,xy)))
        echo("unreachable",r1,r2,xy);
    else {
    ab=reverse_scara(r1,r2,xy)[k];
    a=ab[0];
    b=ab[1];
    echo(xy,ab);
    rotate([0,0,a]) {
        arm(r1,radius);
        translate([r1,0,0])        
               rotate([0,0,b])
                   arm(r2,radius);
       }
       }
   } 
   
module show_polygon(p) {
   for (i=[0:len(p)-1])
       hull() {
          translate(p[i])  circle(0.1);
          translate(p[(i+1)%len(p)]) circle(0.1); 
     }
}

function sum(v, i = 0) =
    i < len(v) 
       ? v[i] + sum(v, i + 1) 
       : 0;

function qsum(v,i=0) =
    [for (i=[0:len(v)])
      sum(v,len(v)-i)
    ];    
function interpolate_points (a,b,t) =
  // t= [0,1]
   t*b + (1-t) *a;
 
function interpolate_polygon(poly,t) =
  let (n_sides = len(poly))   
  let (side_lengths = [for (i=[0:n_sides-1])
                  norm(poly[(i+1)%n_sides] - poly[i])
  ])
  let (qlengths = qsum(side_lengths))
  let (total =qlengths[n_sides])
  let (length = t*total)
//  [qlengths,total,length];

  [for (i =[0:n_sides]) 
          if  (length >= qlengths[i] && length < qlengths[i+1] )
             interpolate_points (poly[i],poly[(i+1) % n_sides],
             (length - qlengths[i]) / side_lengths[i])][0]

  ;
  
module trace_square() {
// with animate
   s=20;
   sq = [[s,s],[-s,s],[-s,-s],[s,-s]];
   color("black") show_polygon(sq);
   t=$t;         
   xy = interpolate_polygon(sq,t);
   color("blue") show_scara(r1,r2,xy); 
}

//round_trip_ab([30,30]);
//echo(reachable(r1,r2,[2,2]));
//round_trip_xy([2,2]);
// xy_increment();
// polar_increment();
// color("red") show_scara(r1,r2,[20,20],k=0);
/ /color("green") show_scara(r1,r2,[20,20],k=1);

trace_square();

          
          
