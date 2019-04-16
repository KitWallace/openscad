// length of tile side in mm
size=20;
// grid X size
n=1;
// grid Y size
m=2;
// tile separation ratio
sep=0.3;
//tile inset for interference fit
inset=0.3;
// 0 plain base 1 base is tabbed 
Base=1;
//base height in mm
base_height=2;
// truchet height
truchet_height=2;

module plain_tile() {
    square([1,1]);
}

module asym_tabbed_tile() {
    
function asym_tab_in(tab_ratio,angle,inset) =
   [
   [(1-tab_ratio)/2,angle],
   [inset/sin(angle),360-angle],
   [2*inset/tan(angle)+tab_ratio, 360-angle],
   [inset/sin(angle),angle],
   [(1-tab_ratio)/2,90]
   ];
    
function asym_tab_out(tab_ratio,angle,inset) =
   [
   [(1-tab_ratio)/2,360-angle],
   [inset/sin(angle),angle],
   [2*inset/tan(angle)+tab_ratio, angle],
   [inset/sin(angle),360-angle],
   [(1-tab_ratio)/2,90]
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
width=0.3;
depth=0.2;

pt = 
    concat(asym_tab_in(width,angle,depth),
     asym_tab_out(width,angle,depth),
     asym_tab_in(width,angle,depth),
     asym_tab_out(width,angle,depth)
    );
 
tabbed_tile= peri_to_tile(pt);
offset(-inset/size) 
  polygon(tabbed_tile);
}

module anti_truchet(size,d,h) {
    r=size/2;
    color("green")
    linear_extrude(height=d)
//         square([size,size], center=true);
             translate([-size/2,-size/2,0])
                 scale(size) 
                   if (Base==1)
                        asym_tabbed_tile();
                   else plain_tile();
    translate([0,0,d+eps])
    color("red")
    linear_extrude(height=h) 
    intersection() {
      square([size,size], center=true);
      union() {
         translate([size/2,size/2]) circle(r=r);
         translate([-size/2,-size/2]) circle(r=r);      
     }
   }
}

module truchet(size,d,h) {
   r=size/2;
   color("green")
    linear_extrude(height=d)
 //        square([size,size], center=true);
           rotate([0,0,90])
             translate([-size/2,-size/2,0])
               scale(size) 
                   if (Base==1)
                        asym_tabbed_tile();
                   else plain_tile();
   translate([0,0,d+eps])
   color("red")
   linear_extrude(height=h) 
    difference() {
      square([size,size], center=true);
      union() {
         translate([size/2,size/2]) circle(r=r);
         translate([-size/2,-size/2]) circle(r=r);
      }
   }
}

function random_tiles(N,M,i=0,tiles=[]) =
   len(tiles) < N*M
      ? let(r=rands(0,1,1)[0])
        let(j= r < 0.5 ? 1 : 3)
        let(l =
          i==0 
            ? 0 
            : i%N==0 
               ? (floor(i/N) -1)*N 
               : i-1)
        let(last = i==0? 0 :tiles[l])
        let(k=(last+j)%4)
        random_tiles(N,M,i+1,concat(tiles,k))
      : tiles;

module truchet_tile(size,d,h,form) {
   if(form==0)
      truchet(size,d,h);
   else if (form==1)
      rotate([0,0,90])
         truchet(size,d,h);
   else if (form==2)
      rotate([0,0,90])
         anti_truchet(size,d,h);
   else if (form==3)           
      anti_truchet(size,d,h,90);
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
  

eps=0.01;
$fn=50;
tiles = random_tiles(n,m);
//echo(rt);
truchet_tiling(size,base_height,truchet_height,tiles,n,m,sep);


