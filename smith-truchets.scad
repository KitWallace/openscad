// length of tile side
size=20;
// grid X size
N=5;
// grid Y size
M=5;
// tile separation ratio
sep=0
;
//tile-offset for interference fit
offset=0;


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
offset(offset/size) 
  polygon(tabbed_tile);
}

module anti_truchet(size,d,h) {
    r=size/2;
    color("green")
    linear_extrude(height=d)
//         square([size,size], center=true);
             translate([-size/2,-size/2,0])
                 scale(size) asym_tabbed_tile();
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
               scale(size) asym_tabbed_tile();
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
        let(last = i==0 ? 0: 
            i%N==0 ? (floor(i/N) -1)*N :
             i-1)
        let(lastt = i==0? 0 :tiles[last])
        let(k=(lastt+j)%4)
        random_tiles(N,M,i+1,concat(tiles,k))
      :tiles;

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
module truchet_tiling(size,d,h,tiles,N,sep=0) {
    rows = ceil(len(tiles)/N);
    offset = 1+sep;
    for (i=[0:rows-1]) 
    for (j = [0:N-1]) {
        form=tiles[i*N+j];
 //       color(colors[(i+2*j)%4])
        translate([j*size*offset,i*size*offset,0])
          truchet_tile(size,d,h,form); 
    }
}
  
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
           

eps=0.01;
$fn=50;
rt = random_tiles(N,M);
//echo(rt);

truchet_tiling(20,2,5,rt,N,sep);


