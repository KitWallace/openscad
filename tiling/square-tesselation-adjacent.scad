use <tile_fns.scad>

// quadralateral adjacent  tesselation
 
// tesselation unit is a unit of 4 tiles

p_base=repeat([[10,90]],4);
t_base=peri_to_tile(p_base);
peri_report(p_base);

side1 = [[2,300],[1,120],[1,120],[1,60],[1,240],[1,240],[1,120],[1,240],[1,300],[1,60],[2,90]];
side2= [[2,240],[1,120],[2,120],[1,240],[2,90]];

p_jigsaw= modify_sides(p_base,[side1,rmirror_side(side1),side2,rmirror_side(side2)]);
peri_report(p_jigsaw,"Adjacent sides");
t_jigsaw=peri_to_tile(p_jigsaw);

// scale(20) fill_tile(t_jigsaw);

colors=["lightblue","green","blue" ,"red" ];

b_transforms = group_transforms(t_base,[[0,0,1],[0,1,1],[1,0,0]]);
b_unit = apply_group_transforms(t_base,b_transforms);
// scale(20) fill_group(inset_group(b_unit,0.04),colors);
j_unit = apply_group_transforms(t_jigsaw,b_transforms);
//scale(20) fill_group(inset_group(j_unit,0.1),colors);

dx=offset_group(b_unit,[0,3,1,2]);
dy=offset_group(b_unit,[3,2,0,2]);
echo(dx,dy);
n=20;
m=20;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+j*dy)
            fill_group(inset_group(j_unit,0.05),colors);
