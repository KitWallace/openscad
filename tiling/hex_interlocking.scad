use <tile_fns.scad>

function toothed_peri(side,angle,inset) =
    let(corner=120)
    let(d=side/3)
    let(dl=d+2*inset*cos(angle))
    let(edge=[[d,angle],[inset,360-angle],[dl,360-angle],[ inset,angle],[d,corner]]) 
    repeat(concat(edge,mirror_side(edge)),3);

side=2; 
tooth_angle=70;
tooth_inset=0.3;
tile_inset=0.01;
tile_height=0.5;
n=2;
m=2;

hex_peri= toothed_peri(side,tooth_angle,tooth_inset);
//echo(hex_peri);
hex_tile= peri_to_tile(hex_peri);
dx=side*[1+cos(60),-sin(60),0];
dy=side*[0,2*sin(60),0];
//  echo(dx,dy);
scale(10) 
  repeat_tile(n,m,dx,dy)
      linear_extrude(height=tile_height)  
           fill_tile(inset_tile(hex_tile,tile_inset));
