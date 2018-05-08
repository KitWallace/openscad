use <tile_fns.scad>
// triangular midpoint tesselation

function tri_SAS(a,A,b) =
    let (peri= [[a,A],[b,0]])
    let (tile=peri_to_tile(peri,true))
    tile_to_peri(tile);
    
p_base=tri_SAS(5,60,7);
t_base=peri_to_tile(p_base,true);
peri_report(p_base);

//scale(20) fill_tile(t_base);

side1 = [[2,300],[1,120],[1,120],[1,60],[1,240],[1,240],[1,120],[1,240],[1,300],[1,60],[2,60]];
side2= [[2,240],[1,120],[1,120],[1,240],[3,60]];
side3= [[3,240],[1,120],[1,120],[1,240],[2,60]];
mside1= rmidpoint_side(side1);
mside2= rmidpoint_side(side2);
mside3= rmidpoint_side(side3);


p_jigsaw= replace_sides(p_base,[mside1,mside2,mside3]);
peri_report(p_jigsaw,"jigsaw");
t_jigsaw=peri_to_tile(p_jigsaw);
// scale(20) fill_tile(t_jigsaw);

b_transforms = group_transforms(t_base,[[0,0,0]]);
echo("transforms",b_transforms);
u_base = apply_group_transforms(t_base,b_transforms);
//scale(20) fill_group(inset_group(u_base,0.04),colors);
u_jigsaw= apply_group_transforms(t_jigsaw,b_transforms);
// scale(20) fill_group(inset_group(u_jigsaw,0.1),colors);

colors=["green","blue" ,"red" ];
dx=offset_group(u_base,[1,1,0,1]);
dy=offset_group(u_base,[1,2,0,2]);
echo(dx,dy);


n=15;
m=15;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+j*dy)
            fill_group(inset_group(u_jigsaw,0.05),colors);
