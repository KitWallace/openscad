use <tile_fns.scad>

a=1;
t_sq= repeat([[a,90]],4);
sq = centre_tile(peri_to_tile(t_sq));

module plain_sq() {
     outline_tile(sq,0.2);
    }

n=10;
m=10;

dx=[1,0,0];
dy=[0,1,0];
colors=["red","orange","tomato" ,"yellow"   ];
for (j=[0:m-1])
    for(i=[0:n-1]){
         translate(i*dx+j*dy){
             color(colors[(i+2*j)%4]) plain_sq();  
         }
     }
     
    
