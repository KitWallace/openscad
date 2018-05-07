use <tile_fns.scad>
side = [[2,300],[1,60],[2,60],[1,300],[2,90]];
p_jigsaw= repeat(concat(side,mirror_side(side)),2);
d_jigsaw=6-2*cos(60); 
echo (p_jigsaw);
echo (d_jigsaw);

module jigsaw() {
 fill_tile(inset_tile(centre_tile(peri_to_tile(p_jigsaw)),0));
}

n=2;
m=2;
d=d_jigsaw;

dx=[d,0,0];
dy=[0,d,0];
colors=["lightblue","green","blue" ,"red"   ];
for (j=[0:m-1])
    for(i=[0:n-1]){
         translate(i*dx + j*dy){
             color(colors[(i+2*j)%4])
               rotate([0,0,(i+j)%4 * 90 ]) jigsaw();
         }
     }
