use <tile_fns.scad>

hex_peri =  repeat([[1,120]],6);
hex_tile= peri_to_tile(hex_peri);
dx=[1+cos(60),-sin(60),0];
dy=[0,2*sin(60),0];
echo(dx,dy);
scale(20) 
   repeat_tile(2,2,dx,dy)
      fill_tile(inset_tile(hex_tile,0.02));
