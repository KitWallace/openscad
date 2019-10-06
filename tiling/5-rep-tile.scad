use <../lib/tile_fns.scad>

/* 
 5-rep tile
 
  see http://mathafou.free.fr/pbm_en/sol218.html
   https://archive.bridgesmathart.org/2015/bridges2015-423.pdf  
Kit Wallace 2019-10-04
*/

k=2;
inset=0.02;
explode=0;
n=2;
m=2;
width=1;
d=0;
design=[["L"],["LRL"],["RLR"],["R"],["RFL"]];
    
function mirror(s,i=0) =  
   i <len(s)
     ? str(  s[i]=="R" ? "L" : "R",
             mirror(s,i+1))
     : "";

function lr_to_peri(f) =
  [for (i=[0:len(f)-1])
      let(d=f[i])
      [1,d=="R"? 270: d=="L"? 90 : 0]
  ];

/*
module fx(k,l,n=2,m=2,side=1,inset=0,explode=0,colors=["palegreen","lime","forestgreen","red"]) {
fib_curve=fib_curve(k);
    echo(fib_curve);
fib_dir = k % 2 == 0 ?  fib_curve : mirror(fib_curve);   
echo(fib_dir); 
p=scale_peri(repeat(lr_to_peri(fib_dir),4),side);
//peri= k % 2 ? mirror_peri(p) : p;
peri=p;
peri_report(peri);
tile=peri_to_tile(peri);
dx=tile_offset([tile],[0,0],[0,l]);
dy=[dx.y,-dx.x,0];
tiles=tesselate_tiles([inset_tile(tile,inset)],n,m,dx,dy);
//projection()  linear_extrude(height=2) 
        fill_tiles(explode_tiles(flatten(tiles),explode),colors);
};

*/

function reverse_last(s) =
   flatten(concat(
       len(s)>1 
           ?[for (i=[0:len(s)-2]) s[i]] 
           : [],
       let (c=s[len(s)-1])
       c=="R" ? "L" : c=="L" ? "R" : c
    ));
           
function reverse_all(s) =
       [for (i=[0:len(s)-1])
           s[i]=="R" ? "L" : "R"
       ];
           
function f(s,n) =
   n==0
     ? s
     : let (t= flatten(
             concat(
             s,
             reverse_last(s),
             s
             )
             ))
       f(t,n-1);
 
seed=design[d];
peri=repeat(lr_to_peri(f(seed,k)),4);

 peri_report(peri);
tile=peri_to_tile(peri);
scale(width) fill_tile(inset_tile(tile,inset));
