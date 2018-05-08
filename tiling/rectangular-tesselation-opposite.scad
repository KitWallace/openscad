use <tile_fns.scad>

//  parallelogram opposing  tesselation

p_base=repeat([[10,110],[8,70]],2);
t_base=peri_to_tile(p_base);
//peri_report(p_base);

side1 = [[2,300],[1,120],[1,120],[1,60],[1,240],[1,240],[1,120],[1,240],[1,300],[1,60],[2,90]];
side2= [[2,240],[1,120],[1,120],[1,240],[2,90]];

p_jigsaw =  modify_sides(p_base,[side1,side2,rmirror_side(side1),rmirror_side(side2)]);
//peri_report(p_jigsaw);
t_jigsaw=peri_to_tile(p_jigsaw);
// scale(20) fill_tile(t_jigsaw);

dx=offset_tile(t_base,3,1);
dy=offset_tile(t_base,0,2);
echo(dx,dy);
colors=["lightblue","green","blue" ,"red" ];

n=2;
m=2;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+j*dy)
             color(colors[(i+2*j)%4])
                  fill_tile(inset_tile(t_jigsaw,0.05),colors);
