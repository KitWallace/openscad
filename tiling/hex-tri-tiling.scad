use <tile_fns.scad>

a=1;
b=0.8;  //  variable

p_hex=repeat([[a,120]],6);
p_tri= repeat([[a,240],[a,120],[b,120],[b,120]],3);

// and tiled with various forms of these basic tiles with:

hex =  centre_tile(peri_to_tile(p_hex));
tri   =centre_tile(peri_to_tile(p_tri));

module hex_tile() {

  color("skyblue") 
      outline_tile(inset_tile(hex,0.02),0.3);
  color("lightblue")
      fill_tile(inset_tile(hex,0.4));
  };

module tri_tile() { 
  color("gray") 
      outline_tile(inset_tile(tri,0.02),0.2);
  color("white")
      fill_tile(inset_tile(tri,0.4));
  color("lightblue")
      fill_tile(inset_tile(tri,0.65));
  };

dx=(a+b)*sin(30);
dy=(a+b)*cos(30);

n=10;
m=30;
for (j=[0:m])
  for(i=[0:n])
    translate([i*6*dx+(j%2)*3*dx,j*dy,0]) {
       tri_tile();
       translate([2*dx,0,0]) 
          hex_tile();  
