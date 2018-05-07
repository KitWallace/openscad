use <tile_fns-a.scad>

side = [[2,270],[1,270],[1,90],[1,90],[3,90],[1,90],[1,270],[1,270],[2,90]];

p_jigsaw= repeat(concat(side,mirror_side(side)),2);
peri_report(p_jigsaw);
t_jigsaw=peri_to_tile(p_jigsaw);
a_jigsaw=[[4,0,13]];
u_jigsaw=group_tiles(t_jigsaw,a_jigsaw);
//scale(20) fill_group(u_jigsaw,["red","green"]);

dx=group_offset(u_jigsaw,[0,4,1,31]);
dy=group_offset(u_jigsaw,[0,22,1,13]);

echo(dx,dy);
colors=["lightblue","green","blue" ,"red" ];
 
n=12;
m=12;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+j*dy)
             fill_group(u_jigsaw,colors);

