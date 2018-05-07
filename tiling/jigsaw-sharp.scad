use <tile_fns.scad>
function toothed_peri(a,d) =
     let(corner = 90)
     let(dl=d+2*cos(a))
     let(side=[[d,360-a],[1,a],[dl,a],[1,360-a],[d,corner]]) 
       repeat(concat(side,mirror_side(side)),2);
 
function toothed_width(a,d)=
    3*d;

p_jigsaw= toothed_peri(70,4);
d_jigsaw= toothed_width(70,4);
echo (p_jigsaw);
echo (d_jigsaw);

module jigsaw() {
 fill_tile(inset_tile(centre_tile(peri_to_tile(p_jigsaw)),0));
}

// linear_extrude(height=1) jigsaw();

n=2;
m=2;
d=d_jigsaw;

dx=[d,0,0];
dy=[0,d,0];
echo(dx,dy);
colors=["lightblue","green","blue" ,"red"   ];
for (j=[0:m-1])
    for(i=[0:n-1]){
         translate(i*dx +j *dy){
             color(colors[(i+2*j)%4])
                rotate([0,0,(i+j)%2*90 ]) jigsaw();
         }
     }
