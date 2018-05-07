use <tile_fns-a.scad>

t_sq = repeat([ 225,90,225,90],4);
t_cross= repeat([ 270,135,90,135],4);
   
d=2*(1+ sqrt(2));
sq=scale_tile(centre_tile(peri_to_tile(t_sq)),1/d);
cross=scale_tile(centre_tile(peri_to_tile(t_cross)),1/d);

w=0.05;
t=0.01;
n=10;m=10;
ca="chocolate";
cb="goldenrod";
cc="white";
for (i=[0:n])
    for (j=[0:m]) 
        translate([i,j,0]) {
           color(ca) 
              outline_tile(inset_tile(sq,t),w);
           color(cc)
              outline_tile(scale_tile(sq,0.85),w/3);
           color(cb)
              outline_tile(scale_tile(sq,0.81),w);
           color(ca)
              fill_tile(scale_tile(sq,0.25),w);
           translate([1/2,1/2,0]) {
              color(cb) 
                 outline_tile(inset_tile(cross,t),w);
              color(ca)
                  fill_tile(scale_tile(cross,0.3),w);
           }
        }
