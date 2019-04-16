// length of tile side in mm
size=20;
// grid X size
n=30;
// grid Y size
m=30;
// tile separation ratio
sep=0;
//tile inset for interference fit
inset=0;
// 0 plain base 1 base is tabbed 
Base=0;
//base height in mm
base_height=2;
// truchet height
truchet_height=2;
// line width
line_width=2;

module plain_tile() {
    square([1,1]);
}

module sym_tabbed_tile() {
    

function sym_tab(tab_width,angle,tab_depth) =
[
     [(1 - tab_width)/2, 360-angle],
     [tab_depth/sin(angle), angle],
     [2*tab_depth/tan(angle)+ tab_width/2, angle],
     [2*tab_depth/sin(angle), 360-angle],
     [2*tab_depth/tan(angle)+ tab_width /2, 360-angle],
     [tab_depth/sin(angle),angle],
     [(1 - tab_width)/2, 90]
     ];
    
function peri_to_points(peri,pos=[0,0],dir=0,i=0) =
    i == len(peri)
      ? [pos]
      : let (side = peri[i])
        let (distance = side[0])
        let (newpos = pos + distance* [cos(dir), sin(dir)])
        let (angle = side[1])
        let (newdir = dir + (180 - angle))
        concat([pos],peri_to_points(peri,newpos,newdir,i+1)) 
     ;                 

function peri_to_tile(peri,last=false) = 
    let (p = peri_to_points(peri))  
    last 
       ? [for (i=[0:len(p)-1]) p[i]] 
       : [for (i=[0:len(p)-2]) p[i]]; 
           
angle=70;
width=0.5;
depth=0.15;

pt = 
    concat(sym_tab(width,angle,depth),
     sym_tab(width,angle,depth),
     sym_tab(width,angle,depth),
     sym_tab(width,angle,depth)
    );
// echo(pt); 
tabbed_tile= peri_to_tile(pt);
offset(-inset/size) 
  polygon(tabbed_tile);
}

module truchet(size,d,h) {
    color("lightgreen")
    linear_extrude(height=d)
//         square([size,size], center=true);
             translate([-size/2,-size/2,0])
                 scale(size) 
                   if (Base==1)
                        sym_tabbed_tile();
                   else plain_tile();
    translate([0,0,d])
      color("green")
        linear_extrude(height=h) 
          translate([-size/2,-size/2])
            intersection() {
                square([size,size]);
                union() {
                 difference() {
                    circle(r=size/2+line_width);
                    circle(r=size/2-line_width); 
                 }
                 translate([size,size]) 
                   difference() {
                      circle(r=size/2+line_width);
                      circle(r=size/2-line_width); 
                 }
               }
           }                    
}

function random_tiles(N,M,i=0,tiles=[]) =
   len(tiles) < N*M
      ? let(k=floor(rands(0,4,1)[0]))
        
        random_tiles(N,M,i+1,concat(tiles,k))
      : tiles;

module truchet_tile(size,d,h,form) {
   if(form==0)
      truchet(size,d,h);
   else if (form==1)
      rotate([0,0,90])
         truchet(size,d,h);
   else if (form==2)
      rotate([0,0,180])
         truchet(size,d,h);
   else if (form==3)           
      rotate([0,0,270])
         truchet(size,d,h);
}

module truchet_tiling(size,d,h,tiles,N,M,sep=0) {
    offset = 1+sep;
    for (i=[0:M-1]) 
    for (j = [0:N-1]) {
        form=tiles[i*N+j];
 //       color(colors[(i+2*j)%4])
        translate([j*size*offset,i*size*offset,0])
          truchet_tile(size,d,h,form); 
    }
}
  

$fn=50;
tiles = random_tiles(n,m);
//echo(rt);
truchet_tiling(size,base_height,truchet_height,tiles,n,m,sep);


