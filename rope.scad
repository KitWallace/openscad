function epitrochoid (R, r, d, theta) = 
     [ (R+r)*cos(theta) - d*cos((R+r)/r*theta),
       (R+r)*sin(theta)  - d*sin((R+r)/r*theta) ];    

module shape_2D ( sweep=360, n=30) { 
    assign(dth = sweep/n)
    for ( i = [0 : n-1] ) 
         polygon( [
             F(dth * i),
             F(dth * (i+1)),
             [0,0] ] );
}

$fa=0.01; $fs=0.5;
function F(theta) =  epitrochoid(3, 1, 1, theta);
linear_extrude(height=20, twist=360) 
     shape_2D(sweep=360, n=50);


