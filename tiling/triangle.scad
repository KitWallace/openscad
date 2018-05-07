use <tile_fns.scad>

a=1;
t_tri= repeat([[a,60]],3);
t= centre_tile(peri_to_tile(t_tri));

module tri() {
     color("lightsteelblue") outline_tile(t,0.2);
     color("lightcyan")  fill_tile(inset_tile(t,0.2));
    }

module r_tri() {
    rotate([0,0,180]) {
        color("lightcyan") outline_tile(t,0.2);
        color("lightsteelblue") fill_tile(inset_tile(t,0.2));
    }
}

module rhomb() {
      tri();
      translate([cos(60),sin(60)-tan(30),0]) r_tri();
}


n=6;
m=6;
di=[a,0];
dj=[a/2,a*sin(60)];
for (j=[0:m-1])
    for(i=[0:n-1]){
         translate([i*di.x+(j%2)*dj.x,(i%2)*di.y+j*dj.y,0]){
             rhomb(); 
         }
     }
