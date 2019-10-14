
/*
  L-system (Lindenmayer) 
    symbols  
       F,A,B forward step
       + turn right angle
       - turn left angle
       other symbols are ignored
       
  see http://paulbourke.net/fractals/lsys/ 
  for a plethora of examples
  
  todo 
    push and pop - but how to generate the path?
  
*/

function find(key, list) =
      list[search([key],list)[0]]  ;

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
 
function string_to_points(s,step=1,angle=90,pos=[0,0],dir=0,i=0,ps=[[0,0]]) =
    i == len(s)
      ? ps
      : let(c=s[i])
        let(newpos =
          c=="F" ||c=="A" || c=="B"
          ? pos + step*[cos(dir), sin(dir)]
          : pos)
        let(newdir =
            c=="+" ? dir + angle
          : c=="-" ? dir - angle
          : dir)
        let(newps =
           newpos == pos ? ps  :concat([newpos],ps)) 
        string_to_points(s,step,angle,newpos,newdir,i+1,newps)
     ; 

module path(points,r,closed=false) {
   for (i=[0:len(points)-2]) {
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
/* curve directory entry structure
   0 - name
   1 - axiom
   2 - rules
   3 - angle in degrees
*/
curves =[
   ["Dragon",
   "FX",
   [
     ["X","X+YF+"],
     ["Y","-FX-Y"]
   ],
   90],

   ["Moore",
    "LFL+F+LFL",
    [
     ["L","-RF+LFL+FR-"],
     ["R","+LF-RFR-FL+"]
    ],
    90],
    
    ["Sierpinski Arrowhead",
     "A",
     [
       ["A", "B-A-B"],
       ["B","A+B+A"]
     ],
    60],
    
    ["Hilbert",
     "X",
     [
       ["X","-YF+XFX+FY-"],
       ["Y","+XF-YFY-FX+"]
     ],
     90],
     
     ["Peano-Gosper",
      "A",
     [
       ["A","A-B--B+A++AA+B-"],
       ["B","+A-BB--B-A++A+B"]
      ],
     60],
    
     ["Sierpinski triangle",
      "A-B-B",
      [
        ["A","A-B+A+B-A"],
        ["B","BB"]
      ],
      120],
      
      ["Peano",
       "X",
       [
        ["X","XFYFX+F+YFXFY-F-XFYFX"],
        ["Y","YFXFY-F-XFYFX+F+YFXFY"]
       ],
       90],
 
      ["Koch snowflake",
       "F++F++F",
       [["F","F-F++F-F"]],
       60],

       ["Square Sierpinski", 
        "F+XF+F+XF",
        [["X","XF-F+F-XF+F+XF-F+F-X"]],
       90],

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
        
        ["Paul Bourke Crystal",
         "F+F+F+F",
         [["F","FF+F++F+F"]],
        90]
   ];

for (i=[0:len( curves)-1])
    echo(i,curves[i][0]); 

ci=0;
k=9;
curve=curves[ci];
echo(curve);
sentence =gen(curve[1],curve[2],k);
angle =curve[3];
//echo(sentence);
echo("k",k);
echo("sentence length",len(sentence));
$fn=12;
width=0.1;
scale= 100;
points = string_to_points(sentence,step=1,angle=angle);
//echo(points);
echo("curve length", len(points)-1);
scale(scale) path(points,r=2*width);
