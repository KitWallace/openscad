use <tile_fns.scad>

/* 
  alhambra generalised

*/

function tri_arrow(b) =
   let (a=2+cos(60))
   let( p_3=[[a, 300], [b, 120], [b, 60], [a, 120], [a, 60], [b, 120], [b, 300], [a, 240]])
   repeat(p_3,3);
   
  
b=1.21;   // vary in range (0,(2+cos(60))/2)
echo(b);
arrow_p=tri_arrow(b);
d=(2+cos(60))-b/2;
peri_report(arrow_p);
arrow_t=rotate_tile(peri_to_tile(arrow_p),30);
dx=group_offset([arrow_t],[0,0,0,3]);
dy=group_offset([arrow_t],[0,0,0,11]);


echo(dx,dy);
// scale(20) linear_extrude(height=0.2) arrows_tile(0.01);
colors=["chocolate","goldenrod","lightgreen","yellow"];

n=20;m=20;
scale(20) 
for (i=[0:n-1])
  for(j=[0:m-1]) {
       translate(i*dx+j*dy)
           color(colors[(i+2*j)%4]) 
              fill_tile(arrow_t);
}

