function polar_to_xy(v) = [v[1] * cos(v[0]), v[1] * sin(v[0] )];

module polar_profile(control_points,step) {
/*
    control_points is an array of arrays, each of which defines a 
    point in polar cordinates [radius, angle] 
    the last angle must be the first angle + 360 for a complete profile
      e.g. [ [0,5], [130,9.9], [140,10], [350,10], [360,5] ]

    the result is a 2D profile interpolated at step degree intervals
    between these points

    by kit.wallace@gmail.com
*/
    for (angle =[0: step: 360 - 1])
         assign (ps = [angle,  lookup(angle, control_points)],
                 pe = [angle+step,  lookup(angle+step, control_points) ]
                )
         polygon ([ [0,0], polar_to_xy(ps), polar_to_xy(pe)]);
}

snail = [ [0,5], [140,10], [350,10], [360,5] ];
linear_extrude(height = 3) polar_profile(snail,5);

