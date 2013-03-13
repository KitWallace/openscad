module sector (a) {
    module sq() {
      assign(r=100)
      translate([0, r/2,0]) square(r,center=true);
    }
    if (a <= 180) 
        difference() {
           child(0);
           rotate([0,0, a])  sq();
           rotate([0,0, 180])  sq();
       }
   else
       rotate(- (360 - a))
          difference () {
             child(0);
             difference() {
                child(0);
                rotate([0,0, 360-a])  sq();
                rotate([0,0, 180])  sq();
          }
      }
}

module staircase_full(core_radius,step_width, step_depth,num_per_rev,num_revs, overlap_angle) {
        cylinder(r=core_radius+step_width,h=step_depth);
        translate([0,0,step_depth]) 
          staircase(core_radius,step_width, step_depth,num_per_rev,num_revs, overlap_angle);
        translate([0,0,step_depth * (num_revs * num_per_rev + 1) ]) 
              linear_extrude(height=step_depth) 
                    sector(180) 
                         circle(r=core_radius+step_width,h=step_depth);
}

module staircase(core_radius,step_width, step_depth,num_per_rev,num_revs, overlap_angle)  {
     assign(step_angle = 360 /num_per_rev)
     for (i = [0:num_per_rev *num_revs-1])
           assign( angle = i * step_angle,
                       height = i * step_depth
           )
             translate([0,0,height])
         rotate(angle)
               step(core_radius, step_width,step_angle+overlap_angle, step_depth);
}

module step(core_radius, step_width,step_angle, step_depth) {
   linear_extrude(height=step_depth)
      union (){
            circle(core_radius);
            sector(step_angle) circle(core_radius  + step_width);
     }
}

$fa=0.1;$fs=0.5;
staircase_full(2,10,2,10,2,10);
