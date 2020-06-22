/* kinematics for a two-link SCARA arm
   there are always 2 positions of the links to get to [x,y] , except in the degenerate case where [x,y] is on the limiting circle, with the elbow either side of the line from origin to [x,y]  

   this algorithm returns both solutions because incrementally we want to minimize movement, so need to choose the solution to [x+dx,y+dy] closest to [x,y]

   points outside the radius of the scara need to be rejected
   the origin (0,0) is also an unreachable point because there are infinite solutions here [a,180] where a = [0,360].  

   note that r2 must be = r1 if all points inside are to be reachable

   showing the pose of the the scara - this is valuable for testing that all points within the scara radius are reachable and with animate
   can generate the frames for a GIF
*/


use <../lib/tile_fns-v19.scad>

function ab_to_xy(r1,r2,ab) =
  let (a = ab[0])
  let (b = ab[1])
  [r1*cos(a) + r2*cos(a+b),
   r1*sin(a) + r2*sin(a+b)];

function xy_reachable(r1,r2,xy) =
   let (x = xy.x,
        y = xy.y,
        L = sqrt(x*x+y*y))
   L <= (r1+r2)  && L>= abs(r1-r2)  && L >0;

function SSS(a,b,c) =
   abs(a + b - c) < 0.00001
        ? 0   // degenerate case triangle has zero area
        : acos((a*a + b*b - c*c)/ (2*a*b));
   
function xy_to_ab(r1,r2,xy) =
   let (x = xy.x,
        y = xy.y,
        L = sqrt(x*x+y*y),
        a1= atan2(y,x),
        a2= SSS(r1,L,r2),
        b = 180 - SSS(r1,r2,L))
   [[a1+a2,-b],[a1-a2,b]];

function xy_to_ab_best(r1,r2,current_ab,next_xy) =
  let (next_ab = xy_to_ab(r1,r2,next_xy))
  let (ab_diff= [for (ab = next_ab) norm(current_ab - ab)])
   (ab_diff[0] < ab_diff[1])
     ? next_ab[0] 
     : next_ab[1] ;

function polar_to_xy(polar) =
  let (r=polar[0])
  let (theta = polar[1])
  [r*cos(theta), r*sin(theta)];
  
module round_trip_ab(ab=[0,0]){
 echo("test round tripping ab<>xy");
 echo ("ab",ab);
 xy = ab_to_xy(r1,r2,ab);
 echo("xy",xy);
 ab2= xy_to_ab(r1,r2,xy);
 echo("ab2",ab2);
};

module round_trip_xy(xy=[0,0]) {
 echo("test round tripping xy <> ab");
 echo("xy",xy);
 ab= xy_to_ab(r1,r2,xy);
 echo("ab",ab);   
 for (ab_i = ab) {  // all solutions
      xy1=ab_to_xy(r1,r2,ab_i);
      echo("xy1",xy1);
  }
}
  
module xy_increment(){
 echo("move between points");
 p=[5,5];
 echo("from",p);
 ab_p = xy_to_ab(r1,r2,p)[0];
 echo("p angles",ab_p);
 q=[5.1,4.9];
 echo("to",q);
 ab_q = xy_to_ab_best(r1,r2,ab_p,q);
 echo ("q angles",ab_q);
 ab_diff = ab_q - ab_p;
 echo ("diff",ab_diff,"degrees");   
}

module polar_increment() {
 echo("move between polar points");
 p=[10,60];
 echo("from",p);
 ab_p = xy_to_ab(r1,r2,polar_to_xy(p))[0];
 echo("p angles",ab_p);
 q=[10.1,61];
 echo("to",q);
 ab_q = xy_to_ab_best(r1,r2,ab_p,polar_to_xy(q));
 echo ("q angles",ab_q);
 ab_diff = ab_q - ab_p;
 echo ("diff",ab_diff,"degrees");   
}

module link(length,r) {
    hull() {
        circle(r);
        translate([length,0]) circle(r);
    }
}

module show_scara(r1,r2,xy,r=0.2,k=0) {
    if (!(xy_reachable(r1,r2,xy)))
        echo("unreachable",r1,r2,xy);
    else {
    ab=xy_to_ab(r1,r2,xy)[k];
    a=ab[0];
    b=ab[1];
    echo(xy,ab);
    rotate([0,0,a]) {
        color("red") link(r1,r);
        color("black") circle(3*r);

        translate([r1,0,0])  {      
               rotate([0,0,b]) {
                   color("red") link(r2,r);
                   color("black") circle(3*r);
                   translate ([r2,0,0])
                      color("black") circle(2*r);
             }
         }
    }
} 
 } 
module show_polygon(p,r=0.1) {
   for (i=[0:len(p)-1])
       hull() {
          translate(p[i])  circle(r);
          translate(p[(i+1)%len(p)]) circle(r); 
     }
}

// polygon interpolation - 
function interpolate_points (a,b,t) =
  // t= [0,1]
   t*b + (1-t) *a;

function qsum(v,q,i=0) =
       i < len(v)
       ? qsum(v,concat(q,[v[i]+q[i]]),i+1)
       : q;  
    
function poly_qlengths(poly) =
  let (n_sides = len(poly))   
  let (side_lengths = [for (i=[0:n_sides-1])
            norm(poly[(i+1)%n_sides] - poly[i])
  ])
  qsum(side_lengths,[0],0);
  
function interpolate_polygon(poly,t) =
// very suboptimal for repetative conversion 
  let (n_sides = len(poly))   
  let (side_lengths = [for (i=[0:n_sides-1])
            norm(poly[(i+1)%n_sides] - poly[i])
  ])
    let (qlengths = qsum(side_lengths,[0],0))
    let (total =qlengths[n_sides])
    let (length = t*total)

  [for (i =[0:n_sides]) 
          if  (length >= qlengths[i] && length < qlengths[i+1] )
             interpolate_points (poly[i],poly[(i+1) % n_sides],
             (length - qlengths[i]) / side_lengths[i])][0]
  ;

module trace_square() {
// with animate
   s=(r1+r2)/sqrt(2);
   sq = [[s,s],[-s,s],[-s,-s],[s,-s]];
   color("black") show_polygon(sq);
   t=$t;         
   xy = interpolate_polygon(sq,t);
   show_scara(r1,r2,xy); 
} 
   
module trace_star() {
// with animate
   s=50;
   p=repeat([[s,36]],5);
//   peri_report(p);
   poly=centre_tile(peri_to_tile(p));
        echo(len(poly), poly);
    echo (poly_qlengths(poly));

   color("green") show_polygon(poly,0.5);
   t=$t;         
   xy = interpolate_polygon(poly,t);
   show_scara(r1,r2,xy,r=0.5); 
} 

function flip_polygon(poly)=
  [for (p=poly) [-p.x,-p.y]];
      
    
$fn=50;
 // scara arms
r1=20;
r2=20;

module trace_elephant () {
// from a png via Inkscape and an XQuery script 
  poly_abs= [[228.3178,425.73232],[217.52614,422.14091],[214.3178,416.35481],[223.18595,404.64377],[233.78814,392.49188],[236.86305,376.30957],[253.19193,274.88984],[264.84391,203.88984],[265.33,199.88984],[257.17032,193.88984],[247.82526,187.18028],[241.72885,187.92853],[225.89076,191.91147],[209.37639,196.94403],[200.89359,204.67066],[182.43644,231.40399],[163.33377,248.22177],[148.8178,251.88984],[137.8178,251.05566],[134.8178,250.22148],[140.3178,245.23183],[144.2669,241.30942],[143.3178,240.75776],[128.13204,242.45225],[105.3487,242.67924],[84.204211,239.21741],[65.732911,232.33679],[50.969161,222.30743],[40.498091,210.23142],[33.655921,196.15785],[30.817801,173.38984],[32.517791,152.5247],[39.481091,134.56911],[55.293991,111.30644],[73.261851,96.618447],[85.068571,93.742797],[95.877351,96.920957],[102.88099,103.10464],[104.40542,109.15384],[102.68092,111.53697],[95.245641,111.88984],[81.469451,114.8523],[67.226071,128.24534],[58.160671,147.53934],[56.389801,163.47324],[59.309131,177.5771],[66.652781,189.18485],[78.154901,197.63041],[94.826641,201.22833],[109.84235,199.57646],[121.33671,190.71047],[134.48183,169.73074],[145.80665,131.88984],[160.01517,82.972507],[168.32576,69.889837],[179.11562,53.389837],[187.68936,41.675247],[197.71608,33.682677],[210.11812,28.886227],[225.8178,26.759957],[241.95133,27.657167],[281.06279,35.836267],[308.97892,40.763817],[327.99657,40.783317],[360.3178,32.885407],[390.82761,25.423877],[414.67825,22.404417],[436.84866,23.633297],[462.31776,28.916817],[508.33826,43.911277],[552.31776,61.879587],[573.61946,74.014727],[591.45286,87.454397],[605.57316,101.98424],[615.73536,117.38989],[627.03276,148.95089],[636.77596,204.71041],[652.67826,294.00458],[661.40956,324.51436],[671.67276,349.80645],[677.00776,362.03329],[661.78336,341.49913],[644.34056,305.6887],[629.82736,261.38989],[618.22866,205.91185],[616.41006,200.19229],[614.36716,213.38989],[603.28646,268.88989],[595.62426,304.15084],[594.65266,327.88989],[597.39986,355.10218],[605.46306,391.17385],[610.58666,415.77908],[608.95926,419.82294],[604.40676,422.25626],[590.88326,425.62966],[569.88976,426.24265],[550.64036,423.78956],[547.61946,419.04687],[550.74036,412.06752],[554.05146,402.83049],[546.75366,389.25823],[535.73506,370.74638],[526.31826,344.69177],[525.38196,343.93989],[514.15516,385.38989],[514.39986,400.51649],[516.01626,409.31226],[512.61216,413.65567],[498.25846,416.58682],[472.81936,417.12027],[455.36466,415.83789],[447.27336,412.55455],[445.34846,407.14765],[451.06376,397.15144],[457.67936,385.88989],[460.34076,358.88989],[464.20176,325.12534],[470.25616,297.88989],[473.84246,283.60333],[456.19846,283.08349],[429.31826,279.55648],[403.3183,268.45507],[370.7587,255.38989],[369.3183,259.66612],[368.34724,271.91612],[365.37558,306.88989],[364.75603,343.56256],[373.83028,366.38989],[386.34082,391.26773],[387.28731,398.27778],[385.25295,403.48166],[371.82443,411.98427],[346.68057,414.80778],[329.43057,412.9849],[327.49378,408.74361],[330.42917,400.13728],[332.89597,387.91133],[326.01205,369.81935],[318.19195,350.55842],[314.3993,333.29737],[308.87068,316.38989],[287.31408,365.38989],[278.18719,388.52197],[274.5545,399.26161],[276.42994,408.47592],[276.67994,418.05076],[269.61468,424.60125],[249.3183,426.04889],[228.3183,425.73237]];
    poly = flip_polygon(scale_tile(centre_tile(poly_abs),0.1));
  
    color("green") show_polygon(poly,0.2);
    t=$t;         
    xy = interpolate_polygon(poly,t);
    show_scara(r1,r2,xy,r=0.2);   
}

//round_trip_ab([30,30]);
//echo(xy_reachable(r1,r2,[2,2]));
//round_trip_xy([2,2]);
// xy_to_ab_best();
// polar_increment();
// color("red") show_scara(r1,r2,[20,20],k=0);
// color("green") show_scara(r1,r2,[20,20],k=1);
          
trace_star();          
          
