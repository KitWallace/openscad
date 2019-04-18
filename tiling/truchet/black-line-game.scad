// length of tile side in mm
size=20;
// grid X size
n=20;
// grid Y size
m=20;
// tile separation ratio
sep=0;
//tile inset for interference fit
inset=0;
// 0 plain base 1 base is tabbed 
Base=1;
//base height in mm
base_height=2;
// truchet height
truchet_height=2;
// line width
line_width=2;

//foreground color
fg_color="orange";
//background color
bg_color="linen";

function flatten(l) = [ for (a = l) for (b = a) b ] ;

module plain_tile() {
    square([1,1]);
}

module sym_tabbed_tile() {
    

function sym_tab(tab_width,angle,tab_depth,dwell) =
[
     [(1 - tab_width)/2, 360-angle],
     [tab_depth/sin(angle), angle],
     [tab_depth/tan(angle)+ tab_width/2-dwell, 90],
     [tab_depth, 270],
     [2*dwell,90],
     [tab_depth,270],
     [tab_depth/tan(angle)+ tab_width /2 -dwell, 360-angle],    

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
dwell=0.08;
pt = 
    concat(sym_tab(width,angle,depth,dwell),
     sym_tab(width,angle,depth,dwell),
     sym_tab(width,angle,depth,dwell),
     sym_tab(width,angle,depth,dwell)
    );
// echo(pt); 
tabbed_tile= peri_to_tile(pt);
offset(-inset/size) 
  polygon(tabbed_tile);
}

module truchet(size,d,h) {
    color(bg_color)
    linear_extrude(height=d)
//         square([size,size], center=true);
             translate([-size/2,-size/2,0])
                 scale(size) 
                   if (Base==1)
                        sym_tabbed_tile();
                   else plain_tile();
    translate([0,0,d])
      color(fg_color)
        linear_extrude(height=h) 
          translate([-size/2,-size/2])
            intersection() {
                square([size,size]);
                if (Base==1)
                    scale(size) 
                        sym_tabbed_tile();

                union() {
                 difference() {
                    circle(r=size/2+line_width/2);
                    circle(r=size/2-line_width/2); 
                 }
                 translate([size,size]) 
                   difference() {
                      circle(r=size/2+line_width/2);
                      circle(r=size/2-line_width/2); 
                 }
               }
           }                    
}

module cross (size,d,h) {
    cs = size/2-line_width/2;
    color(bg_color)
    linear_extrude(height=d)
//         square([size,size], center=true);
             translate([-size/2,-size/2,0])
                 scale(size) 
                   if (Base==1)
                        sym_tabbed_tile();
                   else plain_tile();
    translate([0,0,d])
      color(fg_color)
        linear_extrude(height=h) 
          translate([-size/2,-size/2])
            intersection() {
                square([size,size]);              
                difference() {
                   square([size,size]);   
                   union() {
                       square([cs,cs]);
                       translate([size/2+line_width/2,0])
                            square([cs,cs]);
                       translate([size/2+line_width/2,size/2+line_width/2])
                            square([cs,cs]);
                       translate([0,size/2+line_width/2])
                            square([cs,cs]);
                   }
               }
           }                    
}


function f(i,j,choices) =floor(rands(0,choices,1)[0]);   
//function f(i,j,choices) = (i%2 +j%2)%choices;
//function f(i,j,choices) = (i+j*2)%choices;
//function f(i,j,choices) = j%2==0 ? i%choices : (i+j) %choices;
//function f(i,j,choices) = [1,0,1,2][(i+j)%choices]; 
   
function rule_tiles(N,M,choices) =
   flatten([for (j=[0:M-1])
    [for (i=[0:N-1])
        f(i,j,choices)
     ]
    ]);

module truchet_tile(size,d,h,form) {
   if(form==0)
      truchet(size,d,h);
   else if (form==1)
      rotate([0,0,90])
         truchet(size,d,h); 
   else if (form==2)    
      cross(size,d,h);
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
tiles = rule_tiles(n,m,3);
//echo(rt);
truchet_tiling(size,base_height,truchet_height,tiles,n,m,sep);


