use <tile_fns.scad>

// hexagonal abitrary tesselation

// equilateral, opposing sides 

p_base=repeat([[5,120]],6);
t_base=peri_to_tile(p_base);
//peri_report(p_base);

side1 = [[1.5,300],[1,120],[3,120],[2,60],[3,240],[1,240],[0,120],[4,240],[2,300],[4,60],[1.5,120]];
side2= [[1.5,240],[2,120],[2,120],[2,240],[1.5,120]];
side3=[[7,120]];

p_jigsaw= replace_sides(p_base,[side1,side2,side3,rmirror_side(side1),rmirror_side(side2),rmirror_side(side3)]);

peri_report(p_jigsaw,"Opposing sides");
t_jigsaw=peri_to_tile(p_jigsaw);
//scale(20) fill_tile(t_jigsaw);
//scale(20) translate([0,0,1])color("red") fill_tile(t_base);


dy=offset_tile(t_base,0,3);
dx=offset_tile(t_base,0,2);
echo(dx,dy);
colors=["lightblue","green","blue" ,"red" ];

n=20;
m=20;
scale(20)
for(i=[0:n-1])
   for (j=[0:m-1]) 
        translate(i*dx+(j- floor(i/2))*dy)
             color(colors[(i+2*j)%4])
                  fill_tile(t_jigsaw,colors);
