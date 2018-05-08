use <tile_fns.scad>

// rectangular abitary tesselation
// midpoint rotation

p_base=repeat([[10,90],[8,90]],2);
t_base=peri_to_tile(p_base);
//peri_report(p_base);

side1 = [[2,300],[1,120],[1,120],[1,60],[1,240],[1,240],[1,120],[1,240],[1,300],[1,60],[2,90]];
side2= [[2,240],[1,120],[1,120],[1,240],[2,90]];
side3= [[3,240],[1,120],[1,120],[1,240],[2,90]];
mside1= rmidpoint_side(side1);
mside3= rmidpoint_side(side3);

// scale(20) fill_tile(peri_to_tile(mside1));

rside2= rmirror_side(side2);

p_jigsaw= replace_sides(p_base,[mside1,side2,mside3,rside2]);
peri_report(p_jigsaw,"jigsaw");
t_jigsaw=peri_to_tile(p_jigsaw);
// scale(20) fill_tile(t_jigsaw);
b_transforms = group_transforms(t_base,[[0,0,0]]);
echo("transforms",b_transforms);
u_base = apply_group_transforms(t_base,b_transforms);
//scale(20) fill_group(inset_group(u_base,0.04),colors);
u_jigsaw= apply_group_transforms(t_jigsaw,b_transforms);
// scale(20) fill_group(inset_group(u_jigsaw,0.1),colors);

dx=offset_group(u_base,[0,3,0,1]);
dy=offset_group(u_base,[1,0,0,2]);
echo(dx,dy);
colors=["lightblue","green","blue" ,"red" ];

n=10;
m=10;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+j*dy)
             color(colors[(i+2*j)%4])
                  fill_group(inset_group(u_jigsaw,0.05),colors);

