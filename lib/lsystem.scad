/*
  L-system (Lindenmayer) 
    symbols  
       F (or user defined characters) forward step
       + turn right angle
       - turn left angle
       other symbols are ignored when rendering path
       
  see http://paulbourke.net/fractals/lsys/ 
    for a plethora of examples
  
  kit wallace Nov 2019 
  with thanks to Ronaldo and the Openscad Forum
  
  Todo:
  add scaling factors
  reverse()
  mirror()
  pop/push
  move
*/


function find(key, list) =
      list[search([key],list)[0]]  ;

function is_key(key,list)= search([key],list) != undef;

function join(l,s="",i=0) =
   i <len(l) 
      ? join(l,str(s,l[i]),i+1)
      : s;
      
function replace(s,rules) =
   join([for (c = s)
      let(r=find(c,rules)[1])
      r==undef ? c : r
   ]);
      
function gen(s,rules,k) =
    k==0? s : gen(replace(s,rules),rules,k-1);

function string_to_points(s,step=1,angle=90,pos=[0,0,0],dir=0,forward) =
  let(fchars = forward==undef ? ["F"] : forward)
  [for( i  = 0,
        ps = [pos];

        i <= len(s);

        c   = s[i],
        pos = is_key(c,fchars)
               ? pos + step*[cos(dir), sin(dir),0]
               : pos,
        dir = c=="+"  
              ? dir + angle
              : c=="-"
                ? dir - angle
                : dir,
        ps  = is_key(c,fchars) 
               ? concat([pos], ps) : ps,
        i   = i+1 )
  
        if(i==len(s)) each ps ];


// workaround to avoid range limit         
function to_n(n) = [for (i=0;i<=n;i=i+1) i];
    
module path(points,width,closed=false) {
   r=width/2;
   for (i=to_n(len(points)-2)) {
      hull() {    
          translate(points[i]) circle(r);
          translate(points[i+1]) circle(r);
      }    
    }
    if (closed) {
      hull() {    
          translate(points[len(points)-1]) 
              circle(r);
          translate(points[0])
              circle(r);
      } 
    }
};

module tile(points) {
    polygon(points);    
} 

/* curve directory entry structure
   0 - name
   1 - axiom
   2 - rules
   3 - angle in degrees
   4 - forward characters - default F
*/
curves =

 [
   ["Dragon",
   "FX",
   [
     ["X","X+YF+"],
     ["Y","-FX-Y"]
   ],
   90],

   ["Dragon curve -simpler form",
     "F",
    [["F", "F-A"],["A","F+A"]],
     90,
     ["F","A"]
   ],
             
   ["Twin Dragon",
   "FX+FX+",
   [
     ["X","X+YF"],
     ["Y","FX-Y"]
   ],
   90],
   
   ["Terdragon",
   "F",
   [
     ["F","F+F-F"]
   ],
   120],
   
   ["Terdragon boundary",
    "A-B--A-B--",
    [["A","A+B"],
     ["B","A-B"]
     ],
     60,
     ["A","B"]
     ],
     
   ["McWorter's Pentigree",
    "F",
    [["F","+F++F----F--F++F++F-"]],
     36
     ],

    ["Fudgeflake",
     "FX++++FX++++FX",
    [["X","-FY++FX-"],
     ["Y","+FY--FX+"]
    ],
     30],
   
   ["Moore",
    "LFL+F+LFL",
    [
     ["L","-RF+LFL+FR-"],
     ["R","+LF-RFR-FL+"]
    ],
    90],
        
   ["Hilbert",
     "X",
     [
       ["X","-YF+XFX+FY-"],
       ["Y","+XF-YFY-FX+"]
     ],
     90,
     3],
     
   ["Peano-Gosper;FlowSnake",
      "A",
     [
       ["A","A-B--B+A++AA+B-"],
       ["B","+A-BB--B-A++A+B"]
      ],
     60,
     ["A","B"]
    ],
        
   ["Peano",
       "X",
       [
        ["X","XFYFX+F+YFXFY-F-XFYFX"],
        ["Y","YFXFY-F-XFYFX+F+YFXFY"]
       ],
       90],
              
   ["Sierpinski curve",
         "F--XF--F--XF",
         [["X", "XF+F+XF--F--XF+F+X"]],
         45],
         
   ["Sierpinski Arrowhead, Sierpinksi Gasket",
     "A",
     [
       ["A", "B-A-B"],
       ["B","A+B+A"]
     ],
    60,
     ["A","B"]],
        
   ["Sierpinski triangle",
      "A-B-B",
      [
        ["A","A-B+A+B-A"],
        ["B","BB"]
      ],
    120,
     ["A","B"]],

   ["Square Sierpinski", 
        "F+XF+F+XF",
        [["X","XF-F+F-XF+F+XF-F+F-X"]],
       90],
       
   ["Levy Curve",
         "F",
         [["F","-F++F-"]],
         45],
 
   ["Cesaro fractal",
       "F",
       [["F","F+F--F+F"]],
       85],
       
   ["Paul Bourke 1",
       "F+F+F+F+",
       [["F","F+F-F-FF+F+F-F"]],
       90],
       
   ["Paul Bourke Triangle",
        "F+F+F",
        [["F","F-F+F"]],
        120],
 
   ["Koch snowflake",
       "F++F++F",
       [["F","F-F++F-F"]],
       60],
       
   ["Koch anti snowflake",
       "F++F++F",
       [["F","F+F--F+F"]],
       60],
       
   ["Quadratic Koch Island",
      "F-F-F-F-",
      [["F","F-F+F+FF-F-F+F"]],
    90
    ],
      
    ["Square Koch",
       "F--F--F--F--",
       [["F","F+F--F+F"]],
       45],
       
    ["Anti Square Koch",
       "F--F--F--F--",
       [["F","F-F++F-F"]],
       45],

   ["ABP Koch a",
         "F+F+F+F",
         [["F","FF+F+F+F+F+F-F"]],
        90],
 
   ["ABP Koch b",
         "F+F+F+F",
         [["F","FF+F+F+F+FF"]],
        90],
        
   ["ABP Koch c",
         "F+F+F+F",
         [["F","FF+F-F+F+FF"]],
        90],
  
   ["ABP Koch d",
         "F+F+F+F",
         [["F","FF+F++F+F"]],
        90],
 
   ["ABP Koch e",
         "F+F+F+F",
         [["F","F+FF++F+F"]],
        90],
        
   ["ABP Koch f",
         "F+F+F+F",
         [["F","F+F-F+F+F"]],
        90],
    
    ["Mandle6",
     "F+F+F+F+F+F+",
     [["F","F-F+F-F+F"]],
     60
     ],
         
   ["5-rep-tile, Gosper Island",
      "F-F-F-F-",
      [["F","F+F-F"]],
      90
    ],
   
   ["7-rep-tile",
      "F-F-F-F-F-F-",
      [["F","F+F-F"]],
      60
    ],
    ["Quadratic Gosper",
       "-YF",
       [["Y","+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"],
       ["X","XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-"]],
       
       90],
     
    ["Anklets of Krishna, Anticross-stitch curve",
        "-X--X",
        [["X","XFX--XFX"]],
        45   //45.02 splits it down a diagonal
     ],
     
     ["Bourke Kolem",
       "--D--D",
        [["X","F++FFFF--F--FFFF++F++FFFF--F"],
        ["Y","F--FFFF++F++FFFF--F--FFFF++F"],
        ["C","YFX--YFX"],
        ["D","CFC--CFC"]],
        45
      ],
     ["Greek Cross fractal",
         "F",
         [["F", "FF+F+F+FF+F+F-F"]],
         90]

   ];
   
function curves(i) = curves[i];
 
module index() { 
  for (i=[0:len( curves)-1])
    echo(i,curves[i][0]); 
};

module frame(x,y,r) {
   hull() {
       translate([-x/2+r,-y/2+r]) circle(r);
       translate([x/2-r,-y/2+r]) circle(r);
       translate([x/2-r,y/2-r]) circle(r);
       translate([-x/2+r,y/2-r]) circle(r);       
   }
}
