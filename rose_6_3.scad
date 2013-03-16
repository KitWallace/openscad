

module ring_2d (r,w) 
{ 
     difference () 
   {
     circle(r);
     circle(r-w);
     }
}


module ring (outer_radius ,upper_width, lower_width, inner_height,outer_height) 
{ 
    assign(inner_radius = outer_radius - lower_width)
    difference () 
   {
     cylinder(r=outer_radius,h=outer_height);
     translate([0,0,-EPS]) cylinder(r=inner_radius,h=outer_height+2*EPS);
     translate([0,0,inner_height])
            cylinder(r1=inner_radius,r2=outer_radius-upper_width,h=(outer_height-inner_height)+EPS);
   }
}

module multi_ring (outer_radius, upper_width, lower_width, inner_height,outer_height,  n)
{
    assign(angle = 360 / n)
    assign(radius = (outer_radius + upper_width/ (2 * sin(angle/2)))/ (1 + (1 / sin(angle/2)))  )
    assign(ring_offset =   (radius  - upper_width) / sin(angle/2) )
    assign(inner_radius = ring_offset * cos(angle/2)) 
   {
    echo(angle, tan(angle/2),ring_offset,inner_radius);
    ring(outer_radius, upper_width, lower_width, inner_height,outer_height);
    assign(inner_radius = ring_offset * cos(angle/2) ) 
     difference() 
      {
        for (i=[1:n])
           rotate(i * angle)
           translate( [ring_offset,0,0])
           ring(radius, upper_width, lower_width, inner_height,outer_height);
           translate([0,0,-EPS]) cylinder(r=inner_radius,h=outer_height + 2 *EPS);
      }
   }
}

module window (outer_radius,upper_width,lower_width,inner_height,outer_height, n) 
{
    assign(angle = 360 / n)
    assign(radius = (outer_radius + upper_width/ (2 * sin(angle/2)))/ (1 + (1 / sin(angle/2)))  )
    assign(ring_offset =   (radius  - upper_width) / sin(angle/2) )
    assign(inner_radius = ring_offset * cos(angle/2) ) 
    assign(innermost_radius =ring_offset-radius + upper_width) 
   { 
      ring(outer_radius, upper_width,lower_width,inner_height,outer_height);
      multi_ring(outer_radius,upper_width,lower_width,inner_height,outer_height, n);
      ring(inner_radius,upper_width,lower_width,inner_height,outer_height);
      rotate(angle/2) 
           multi_ring(inner_radius, upper_width, lower_width, inner_height, outer_height,n/2); 
      ring(7, upper_width ,lower_width,inner_height,outer_height);
      
   }
}

$fa = 0.01; $fs=0.5;
EPS=0.2;

window(40,1,4,4,5,6);

