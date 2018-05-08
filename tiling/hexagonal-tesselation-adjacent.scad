use <tile_fns.scad>

// hexagonal adjacent tesselation

// equilateral, adjacent sides 
p_base=repeat([[1,120]],6);
t_base=peri_to_tile(p_base);
//peri_report(p_base);

side1 = [[2,300],[1,120],[1,120],[1,60],[1,240],[1,240],[1,120],[1,240],[1,300],[1,60],[2,90]];
side2= [[1.5,240],[2,120],[2,120],[2,240],[1.5,120]];
side3=[[7,120]];
rside1= rmirror_side(side1);
rside2= rmirror_side(side2);
rside3= rmirror_side(side3);

p_jigsaw= replace_sides(p_base,[side1,rside1,side2,rside2,side3,rside3]);
peri_report(p_jigsaw,"adjacent sides");
t_jigsaw=peri_to_tile(p_jigsaw);

//scale(20) fill_tile(t_jigsaw);

b_transforms = group_transforms(t_base,[[1,0,0],[0,0,1]]);
echo("transforms",b_transforms);
u_base = apply_group_transforms(t_base,b_transforms);
//scale(20) fill_group(inset_group(u_base,0.04),colors);
u_jigsaw= apply_group_transforms(t_jigsaw,b_transforms);
// scale(20) fill_group(u_jigsaw,colors);

dx=offset_group(u_base,[0,5,2,4]);
dy=-offset_group(u_base,[0,3,2,2]);

echo(dx,dy);
colors=["lightblue","green","blue" ,"red" ];


n=10;
m=10;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+j*dy)
           fill_group(inset_group(u_jigsaw,0.01),colors);
