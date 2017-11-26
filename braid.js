/*
represent fabric as an 2N +2 x  2M + 2 array
odd and even indexes represent the two kinds of rows 
each cell represents an intersection or edge 
edges have one slot for a rope
intersections have 2,  an up and a down


To do:
  if incomplete,retry with different starting points?
  braid_incomplete() doesnt know about unreachable holes
  full rewrite with classes for Grid, Rope ,  Cell types
  change direction of points around an intersection to conform with the way direction is oriented
  make scaling work
  
*/

Palettes =
   {svg: ['aqua','azure','beige','bisque','blanchedalmond','blue','blueviolet','brown','burlywood','cadetblue','chartreuse','chocolate','coral','cornflowerblue','cornsilk','crimson','cyan','darkblue','darkcyan','darkgoldenrod','darkgray','darkgreen','darkgrey','darkkhaki','darkmagenta','darkolivegreen','darkorange','darkorchid','darkred','darksalmon','darkseagreen','darkslateblue','darkslategray','darkslategrey','darkturquoise','darkviolet','deeppink','deepskyblue','dimgray','dimgrey','dodgerblue','firebrick','floralwhite','forestgreen','fuchsia','gainsboro','ghostwhite','gold','goldenrod','gray','grey','green','greenyellow','honeydew','hotpink','indianred','indigo','ivory','khaki','lavender','lavenderblush','lawngreen','lemonchiffon','lightblue','lightcoral','lightcyan','lightgoldenrodyellow','lightgray','lightgreen','lightgrey','lightpink','lightsalmon','lightseagreen','lightskyblue','lightslategray','lightslategrey','lightsteelblue','lightyellow','lime','limegreen','linen','magenta','maroon','mediumaquamarine','mediumblue','mediumorchid','mediumpurple','mediumseagreen','mediumslateblue','mediumspringgreen','mediumturquoise','mediumvioletred','midnightblue','mintcream','mistyrose','moccasin','navajowhite','navy','oldlace','olive','olivedrab','orange','orangered','orchid','palegoldenrod','palegreen','paleturquoise','palevioletred','papayawhip','peachpuff','peru','pink','plum','powderblue','purple','red','rosybrown','royalblue','saddlebrown','salmon','sandybrown','seagreen','seashell','sienna','silver','skyblue','slateblue','slategray','slategrey','snow','springgreen','steelblue','tan','teal','thistle','tomato','turquoise','violet','wheat','white','whitesmoke','yellow','yellowgreen']
   ,
   greens: ['springgreen','mediumseagreen','red','chartreuse','lawngreen','forestgreen','green','lightgreen','greenyellow','lime','limegreen','olivedrab','palegreen','seagreen']
   };

UP=1;
DOWN=-1;
EMPTY=null;

EDGE=1;
INTERIOR=2;
HOLE=3;


N=0;
M=0;
n=0;
m=0;
Grid = [];
ropes = [];
Edges = [];
next_start=0;

function Cell(edge) {
    this.edge=edge;
    if (edge) {
       this.centre=EMPTY;
       this.next = null;
       }
    else {
       this.up=EMPTY; this.up_next = null;
       this.down=EMPTY; this.down_next = null;
    }
 };

Cell.prototype.occupied = function() {
   if (this.edge)
     return this.centre != EMPTY ;
   else return this.up != EMPTY && this.down != EMPTY;
};

Cell.prototype.kind = function() {
    return this.edge
   ? "Edge"
   : "Intersection";
};


Cell.prototype.toSting = function() { 
   if(this.edge) {        
       t =  "E ";
       if (this.centre != EMPTY) t+= this.centre; 
       if (this.next)
          t+= "("+ this.next.i+","+this.next.j+" "+this.next.d+" "+this.next.pos+")";
       return  t;
       }
   else if (this.hole) { 
       t = "H ";
       if (this.centre != EMPTY) t+= this.centre; 
       if (this.next)
          t+= "("+ this.next.i+","+this.next.j+" "+this.next.d+" "+this.next.pos+")";
       return t  ;
       }
   else {
       t="X ";
       if (this.up != EMPTY) t+= this.up; 
       if (this.up_next)
          t+= "("+ this.up_next.i+","+this.up_next.j+" "+this.up_next.d+" "+this.up_next.pos+")" ;
       if (this.down != EMPTY) t+= "<br/>" + this.down; 
       if (this.down_next)
         t+= "("+ this.down_next.i+","+this.down_next.j+" "+this.down_next.d+" "+this.down_next.pos+")";
       return t;
     }
};

function next(i,j,d) {      
   if(d==0) return {i:i+1,j:j+1,d:d};  
   else if (d==1 ) return {i:i-1,j:j+1,d:d};
   else if (d==2 ) return {i:i-1,j:j-1,d:d};
   else if (d==3 ) return {i:i+1,j:j-1,d:d};
};

function turn(i,j,d) {
   var c = next(i,j,(d+1)%4);
   if (inGrid(c.i,c.j))
      return c;
   else {
       c= next(i,j,(d + 3)%4);
       if (inGrid(c.i,c.j))
       return c;
       else return false;
       }
};
 
function hole_turn(i,j,d) {
   var c = next(i,j,(d+1)%4);
   if (inGrid(c.i,c.j) && ! Grid[c.i][c.j].hole)
      return c;
   else {
       c= next(i,j,(d + 3)%4);
       if (inGrid(c.i,c.j) && ! Grid[c.i][c.j].hole)
       return c;
       else return false;
       }
};
    
function inGrid(i,j) {  /* just the basic border - not interior holes */
    return ((i+j)%2 != 0 && i>=0 && i <= n && j >= 0 && j <= m);
};
function interior(i,j) {
    return ((i+j)%2 != 0 && i>0 && i <n && j >0 && j <m);
};

function isEdge (i,j) {
    return ((i+j)%2 != 0 && (i==0 ||  i==n || j==0 || j==m));
}

// grid functions


function show_grid(inputs) {
  table = $("#grid");
  table.empty();
  for (var j =m;j>=0;j--) {
      row = "<tr>";
      for (var i=0;i<=n;i++) {   
         
         row +="<td >" 
         if ((i + j) % 2 == 0)
              row += "";
         else {  c=Grid[i][j];
                 row += c.toSting();
                 if(inputs) {
                  row+= "<input type='checkbox' id='"+i+'-'+j+"' ";
                  if(c.hole) row+="checked=checked";
                   row+="/>";
                  if (j==0 || i == 0) row+= "["+i+ ","+j+"]";

                 }
               }
         row += "</td>";
      }
      row += "</tr>";
      table.append(row);
  }
};

function doit() {
    initialize_grid();
    make_braid();
    make_svg();
    page_svg();
}
function addit() {

    make_braid();
    make_svg();
    page_svg();
}

/*  grid initialisation */
function clear_page(){
     $('#grid').empty();
     $('#scad').empty();
     $('#info').empty();
     $('#canvas').empty();
   }

/* setup braid base */
function initialize_grid() {
   clear_page();
   N=$("#n").val();
   M=$("#m").val();
   
   n=2*N;
   m=2*M;
//   alert("N="+N+" M="+M);
   $('#info').append ("Grid dimensions are "+(n+1)+" by "+(m+1)+"<br/>");
Grid= new Array();

for (var i = 0; i<= n; i++) {
   Grid[i] = new Array();
   for (var j =0; j<=m; j++) {
      edge = (i==0 || i==n || j==0 || j==m);
      Grid[i][j] =  new Cell(edge);
   }
  }
  mark_grid();
  make_holes();
  show_grid(true);
};

function make_holes() {
    for (var i =0;i<4;i++) {
    var pre = "#hole-"+i+"-";
    hole_size_x = $(pre+'size-x').val();
    hole_size_y = $(pre+'size-y').val();
    if (hole_size_x >0 || hole_size_y >0) {
      hole_x = parseInt($(pre+'x').val());
      hole_y = parseInt($(pre+'y').val());
      for (var i= -hole_size_x ;i <= hole_size_x ;i++)
      for (var j= -hole_size_y;j <= hole_size_y ;j++) {
        hi=i + hole_x;
        hj=j + hole_y;
        if (inGrid(hi,hj)) {
            c=Grid[hi][hj];
            c.hole=true; c.edge=false;
            c.centre=0;
            c.next=null; 
         }
      }
      }
   }
};





function mark_grid() {
   for (var i = 1; i< n; i++) {
   for (var j = 1; j< m; j++) 
   if((i+j)%2 ==1){
      id=i+"-"+j;
      if($('#'+id).is(":checked")) {  // make hole
            c=Grid[i][j];
            c.hole=true; c.edge=false;
            c.centre=EMPTY;
            c.next=null; 
          }
      else {  // make normal
         c=Grid[i][j];
         c.hole=false; c.edge=false;
         c.up=EMPTY;c.up_next=null;
         c.down=EMPTY;c.down_next=null;
      }
      }
   }
}  

function clear_braid() {
   for (var i = 0; i<= n; i++) 
   for (var j = 0; j<= m; j++) 
       if((i+j)%2 ==1){
          var c=Grid[i][j];
          if (c.hole || c.edge) {
               c.centre=EMPTY;c.next=EMPTY;
               }
          else {c.up=EMPTY;c.up_next=EMPTY;
                c.down=EMPTY; c.down_next=EMPTY;
                }
          }
   $('#info').empty();
   $('#canvas').empty();
   show_grid(true);
}

// braiding
//  starting points for braiding
function get_starts() {
    Edges = new Array();
    for (var i=0;i<=n;i++)
      for (var j=0;j<=m;j++)
        if(isEdge(i,j)) {        
           Edges.push({i:i,j:j});       
        }
    next_start=0;
}

function find_start() {
    while (next_start < Edges.length) {
      var edge=Edges[next_start]; 
      var e=Grid[edge.i][edge.j];
      if (e.centre!=EMPTY) {next_start++; continue;}
      // cell empty
      // find adjacent interior
      // and reverse the direction
      var p = new Array();
      for (var d=0;d<=3;d++) {
          var ne = next(edge.i,edge.j,d);
          if (interior(ne.i,ne.j)) {
              var cn = Grid[ne.i][ne.j];
              if (! cn.edge && !cn.hole) {
                 gaps = 0;
                 if (cn.up==EMPTY) gaps++;
                 if (cn.down==EMPTY) gaps++;
                 if (gaps >=0) 
                      p.push({c:cn,next:ne,d:d,gaps:gaps});
             }  
          }
      }
      if (p.length ==0) next_start++;
      else if (p.length ==1) {
               cn= p[0].c;
               d = p[0].d;
               if (cn.up ==EMPTY)
                    {next_start++; return {i:edge.i,j:edge.j,d:(d+2)%4,pos:DOWN};}
               else if (cn.down==EMPTY)
                    {next_start++; return {i:edge.i,j:edge.j,d:(d+2)%4,pos:UP};}
               }
      else if (p.length == 2) { 
           if (p[0].gaps==2  && p[1].gaps ==2)  // both free - chose either
                {next_start++; return {i:edge.i,j:edge.j,d:(p[0].d+2)%4,pos:UP};}
           else if (p[0].gaps==1) {
                if (p[0].c.up ==EMPTY)
                    {next_start++; return {i:edge.i,j:edge.j,d:(p[0].d+2)%4,pos:DOWN};}
                else if (p[0].c.down==EMPTY)
                    {next_start++; return {i:edge.i,j:edge.j,d:(p[0].d+2)%4,pos:UP};} 
                }
           else if (p[1].gaps==1) {
                if (p[1].c.up ==EMPTY)
                    {next_start++; return {i:edge.i,j:edge.j,d:(p[1].d+2)%4,pos:DOWN};}
                else if (p[0].c.down==EMPTY)
                    {next_start++; return {i:edge.i,j:edge.j,d:(p[1].d+2)%4,pos:UP};} 
                }
           else alert ("logic failure");
      }
      next_start++;         
    }
    return false;
};

function step(r,i,j,d,pos,k) {
 //   alert("Step " + i+","+j+" d= "+d+" pos= "+pos);
    var cell = Grid[i][j];
    if (cell.edge) 
       if (cell.centre == r) 
           return {i:i,j:j,d:d,pos:pos,length:k};
       else if (cell.centre !=EMPTY)
           return false;
       else  {     
           var c= turn(i,j,d);  
           if (!c) return false;
           cell.centre=r;
           cell.next={i:c.i,j:c.j,d:c.d,pos:pos};
           return step(r,c.i,c.j,c.d,pos,k+1);
           }
    else if (cell.hole)
       if (cell.centre == r) 
           return {i:i,j:j,d:d,pos:pos,length:k};
       else if (cell.centre !=EMPTY)
           return false;
       else  {
           var c= hole_turn(i,j,d);  
           if (!c) return false;
           cell.centre=r;
           cell.next={i:c.i,j:c.j,d:c.d,pos:pos};
           return step(r,c.i,c.j,c.d,pos,k+1);
           }  
    else   /* intersection */
        if (pos == UP)
            if (cell.up==r)
              return {i:i,j:j,d:d,pos:pos,length:k};
            else if (cell.up != EMPTY)
              return -1;
            else {
              var c = next(i,j,d);
              if (!c) return false;
              cell.up=r;
              cell.up_next = {i:c.i,j:c.j,d:c.d,pos:DOWN};
              return step(r,c.i,c.j,c.d,DOWN,k+1);
              }
        else if (pos==DOWN)
            if (cell.down ==r)
                  return {i:i,j:j,d:d,pos:pos,length:k};
            else if (cell.down != EMPTY)
                  return false;
            else {
                c= next(i,j,d);
                if (!c) return -1;
                cell.down = r;
                cell.down_next = {i:c.i,j:c.j,d:c.d,pos:UP};;
                return step(r,c.i,c.j,c.d,UP,k+1);
                }
     
};

function show_rope(r) {
   var start=ropes[r];
   var here = start;
   steps="";
   for (var i=0;i<start.length;i++) {
        if (! here) return false;
        else
        c = Grid[here.i][here.j];
        if (c.edge || c.hole){
            steps+="("+here.i+","+here.j+")"+here.d+" "+here.pos+":";
            here=c.next;
            }
       else if (here.pos ==UP){
            steps+="("+here.i+","+here.j+")"+here.d+" "+here.pos+":";
            here = c.up_next;
            }
       else if (here.pos ==DOWN) {
            steps+="("+here.i+","+here.j+")"+here.d+" "+here.pos+":";
            here = c.down_next;
            }
       else steps+="bad"
   };
   return steps;
};   

function offsets(i,j,step,width) {
    a= width / Math.sqrt(2);
    return [{x:i*step-a,y:j*step},{x:i*step,y:j*step+a},{x:i*step+a,y:j*step},{x:i*step,y:j*step-a}]; 
 }

function svg_grid(n,m,step,style) {
    svg ="";
    for (var j =0;j<=m;j++)
      svg += "<line x1='0' y1='"+ (j*step) + "' x2='" + (n*step) + "' y2='"+(j*step)+"' style='"+style+";'/>";
     for (var i =0;i<=n;i++)
      svg += "<line x1='"+(i*step)+"' y1='0' x2='" + (i*step) + "' y2='"+(m*step)+"' style='"+style+";'/>";
    return svg;
}

function point(p) {
     return " "+p.x+" "+p.y+" ";
}

function shift(d,k) {
    return (4 + k - d) %4;
}


function make_box_outline(i,j,d,step,width,style) {
    svg="";
    off = next(i,j,d);
    p1=offsets(off.i,off.j,step,width);
    off = next(i,j,(d+2)%4);
    p2=offsets(off.i,off.j,step,width); 
    svg += "<path d='"+ "M "+ point(p1[shift(d,3)]) + " L "+  point(p2[shift(d,2)]) 
         + " M " + point(p2[shift(d,1)]) + " L "+  point(p1[shift(d,0)]);
    svg +="' style='"+style +"' />";
    return svg;  
}

function make_box_interior(i,j,d,step,width,style) {
    svg="<polyline points='";
    off = next(i,j,d);
    p1=offsets(off.i,off.j,step,width);
    off = next(i,j,(d+2)%4);
    p2=offsets(off.i,off.j,step,width); 
    svg += point(p1[shift(d,3)]) + point(p2[shift(d,2)]) + point(p2[shift(d,1)])+ point(p1[shift(d,0)]);
    svg +="' style='"+style +"' />";
    return svg;  
}
function make_under_box_outline(i,j,d,step,width,style) {
    p1=offsets(i,j,step,width);
    off = next(i,j,d);
    p2=offsets(off.i,off.j,step,width); 
    svg += "<path d='"+ "M "+ point(p1[shift(d,1)]) + " L "+ point(p2[shift(d,0)]) + " M "+ point(p2[shift(d,3)])+" L "+ point(p1[shift(d,2)]) ;
    svg +="' style='"+style +"' />";
    return svg;  
}
function make_under_box_interior(i,j,d,step,width,style) {
    svg="<polyline points='";
    p1=offsets(i,j,step,width);
    off = next(i,j,d);
    p2=offsets(off.i,off.j,step,width); 
    svg += point(p1[shift(d,1)]) + point(p2[shift(d,0)]) + point(p2[shift(d,3)])+ point(p1[shift(d,2)]);
    svg +="' style='"+style +"' />";
    return svg;  
}
function make_corner_outline(i,j,d,turn,step,width,style) {
    radius=width* Math.sqrt(2);
    svg= "<path d='";
    p1=offsets(i,j,step,width);

       if (turn=="R") {
           off = next(i,j,(d+3)%4);
           p2=offsets(off.i,off.j,step,width);
           svg += ["M ",point(p1[shift(d,0)]),"A", radius,",",radius," 0 0 0 ",point(p1[shift(d,2)]),
               "L",point(p2[shift(d,1)]),
               "M",point(p2[shift(d,0)]),
               "L",point(p1[shift(d,3)])
               ].join(" ");
           }
       else if(turn=="L") {
           off = next(i,j,(d+1)%4);
           p2=offsets(off.i,off.j,step,width);
           svg += ["M ",point(p1[shift(d,3)]),"A", radius,",",radius," 0 0 1 ",point(p1[shift(d,1)]),
               "L",point(p2[shift(d,2)]),
               "M",point(p2[shift(d,3)]),
               "L",point(p1[shift(d,0)])
               ].join(" ");
           }
   
    svg +="' style='"+style +"' />";
    return svg;  
}
function make_corner_interior(i,j,d,turn,step,width,style) {
    radius=width* Math.sqrt(2);
    svg= "<path d='";
    p1=offsets(i,j,step,width);

       if (turn=="R") {
          off = next(i,j,(d+3)%4);
          p2=offsets(off.i,off.j,step,width);
          svg += ["M ",point(p1[shift(d,0)]),"A", radius,",",radius," 0 0 0 ",point(p1[shift(d,2)]),
               "L",point(p2[shift(d,1)]),
               "L",point(p2[shift(d,0)]),
               "L",point(p1[shift(d,3)])
               ].join(" ");
               }
       else if(turn=="L") {
           off = next(i,j,(d+1)%4);
           p2=offsets(off.i,off.j,step,width);
           svg += ["M ",point(p1[shift(d,3)]),"A", radius,",",radius," 0 0 1 ",point(p1[shift(d,1)]),
               "L",point(p2[shift(d,2)]),
               "L",point(p2[shift(d,3)]),
               "L",point(p1[shift(d,0)])
               ].join(" ");
               } 
    svg +="' style='"+style +"' />";
    return svg;  
}
function turn_lr(d0,d1) {
     x=d0-d1;
     if (x==-3  || x==1) return "R";
     else if (x==3 || x== -1) return "L";
     else return null;
}
function svg_rope(r,step_size,width,fill_style,line_style) {
   var start=ropes[r];
   var here = start;
   svg="";
   for (var i=0;i<start.length;i++) {
         c = Grid[here.i][here.j];
//         $('#info').append(JSON.stringify(here) + ":"+JSON.stringify(c.next)+"<br/>");
         if (c.edge || c.hole){
            var lr=turn_lr(here.d,c.next.d);
//            $('#info').append("turn "+lr+"<br/>");
            if (fill_style)
               canvas.append(make_corner_interior(here.i,here.j,here.d,lr,step_size,width,fill_style));
            if (line_style)
               canvas.append(make_corner_outline(here.i,here.j,here.d,lr,step_size,width,line_style));
            here=c.next;
            }
        else if (here.pos ==UP){
            if (fill_style)
                canvas.append(make_box_interior(here.i,here.j,here.d,step_size,width,fill_style))
            if (line_style)
                canvas.append(make_box_outline(here.i,here.j,here.d,step_size,width,line_style));
            here = c.up_next;
 
            }
       else if (here.pos ==DOWN) {
            cn = Grid[c.down_next.i][c.down_next.j];
            if (cn.edge || cn.hole) {// turn
                if (fill_style)
                    canvas.append(make_under_box_interior(here.i,here.j,here.d,step_size,width,fill_style));
                if (line_style)
                    canvas.append(make_under_box_outline(here.i,here.j,here.d,step_size,width,line_style));
            }
            here = c.down_next;
            }
   };
   return svg;
};   
function find_palette(name)  {
    for (var i = 0;i<Palettes.length;i++) 
        if (Palettes[i][0]==name)
            return Palettes[i][1];
    return false;
};

function make_svg() {
   step_size=$('#step').val();
   width=$('#width').val();
   line_width=$('#line_width').val();
   line_colour=$('#line_colour').val(); 
   colours = $('#colours').val().split(",");  
   if (palette[0]== "p") colours= Palettes[palette[1]];
   scale=$('#scale').val();
   grid=$('#grid').val();
   canvas=$('#canvas');
   canvas.empty();
   canvas.attr("transform", "translate(30,30) scale("+scale+","+scale+")");
   canvas.append("<title>Braid "+N+"x"+M+"</title>");
   for (var r=0;r<ropes.length;r++) {
        var fill_style=null;
        if (colours.length > 0) fill_style="fill:" + colours[r % colours.length];
        var line_style=null;
        if(line_width != 0) line_style="fill: none; stroke:"+line_colour+"; stroke-width:"+line_width;
        svg_rope(r,step_size,width,fill_style,line_style);
    }
    if (grid) canvas.append(svg_grid(n,m,step_size,"fill: none; stroke:"+line_colour+"; stroke-width:"+(line_width/2)));

    $("#svgframe").html($('#svgframe').html());  
}

function page_svg1() {
    text = '<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="900"><g id="canvas" transform="translate(50,20)">'
            +create_svg()+
             " </g>" ;   
     var w = window.open("",'_self');
     $(w.document.body).html(text);  
 };        
  
  
function page_svg(){
    var svg = document.getElementById("svgimage");
    var serializer = new XMLSerializer();
    var svg_blob = new Blob([serializer.serializeToString(svg)],
                            {'type': "image/svg+xml"});
    var url = URL.createObjectURL(svg_blob);
    window.open(url, "svg_win");
} 
    
function rope_path(r) {
   var start=ropes[r];
   var here = start;
 //  alert(here.i+" "+here.j+" "+here.d + " " +here.pos);
   var  steps = new Array();
   for (i =0;i<start.length;i++) {
        if (! here) return false;
        else
        c = Grid[here.i][here.j];
        if (c.edge || c.hole){
            steps.push({i:here.i,j:here.j,d:here.d,pos:0});
            here=c.next;
            }
       else if (here.pos ==UP){
            steps.push({i:here.i,j:here.j,d:here.d,pos:here.pos});
            here = c.up_next;
            }
       else if (here.pos ==DOWN) {
            steps.push({i:here.i,j:here.j,d:here.d,pos:here.pos});
            here = c.down_next;
            }
       else alert ("bad path");
   };
   return steps;
};

function unmark_rope(r,start) {
   here = start;
//   alert(JSON.stringify(here));
   while (here)  {
        c = Grid[here.i][here.j];
        if (c.edge || c.hole){
             if (c.centre !=r) return true;
             here=c.next;
             c.centre=0;c.next=null;
            }
       else if (here.pos ==UP){
            if (c.up !=r) return true;
            here = c.up_next;
            c.up=0;c.up_next=null;
            }
       else if (here.pos ==DOWN) {
             if (c.down !=r) return true;
             here = c.down_next;
             c.down=0;c.down_next=null;
            }
       else alert ("bad path");
   }
};

function make_braid() {
   mark_grid();
   r=0;
   ropes=new Array();
   get_starts();
   start = find_start();
   while (start) {
 //       alert("start :" + JSON.stringify(start));
        end = step(r,start.i,start.j,start.d,start.pos,0);
 //       alert("end :" + JSON.stringify(end));
        if (end.i==start.i && end.j==start.j && end.pos==start.pos && end.length>0) {
        
 //          alert("rope "+r+" length "+end.length);
           
           ropes[r]={i:start.i,j:start.j,d:start.d,pos:start.pos,length:end.length};
           $('#info').append ("Rope "+r +" : "+JSON.stringify(ropes[r])+"<br/>");
           r++;
        }
        else  {
  //      alert("Failed ");
          unmark_rope(r,start); 
       }
        start = find_start();
    }
    $('#info').append ("# ropes "+ (ropes.length));
    if (!braid_complete())  $('#info').append(": braiding incomplete");
    $('#info').append("<br/>");
    show_grid();
};


function braid_complete () {  
    for (var i=1;i<n;i++)
     for (var j=1;j<m;j++) 
      if  ((i+j)%2 ==1){
        var c= Grid[i][j];
        if (! (c.edge || c.hole)  && ((c.up!=EMPTY & c.down==EMPTY)|| (c.down!=EMPTY & c.up==EMPTY) )) return false;
     }
     return true;    
}

// Function to download openscad

function download_scad() {
    var text = $('#scad').text() + $('#base').text();
    var file = new Blob([text], {type: text/text});
    var filename="braid"+N+'x'+M+'.scad';
    if (window.navigator.msSaveOrOpenBlob) // IE10+
        window.navigator.msSaveOrOpenBlob(file, filename);
    else { // Others
        var a = document.createElement("a"),
                url = URL.createObjectURL(file);
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);  
        }, 0); 
    }
}


function make_scad() {
    text = $('#scad');
    text.empty();
    text.append("&#10;&#10;");
    text.append("// N = "+N+"&#10;"); 
    text.append("// M = "+M+"&#10;"); 
    text.append("// number of ropes " + ropes.length + "&#10;"); 
    text.append("Depth = "+$('#depth').val()+";&#10;");
     text.append("Sides = "+$('#sides').val()+";&#10;");
     text.append("R = "+$('#radius').val()+";&#10;");
     text.append("Kscale = [1,1,"+$('#vscale').val()+"];&#10;");
     text.append("Scale = "+$('#scale').val()+";&#10;");
     text.append("Phase =45;&#10;");
     text.append("scale(Scale) braid(Paths,Depth,Kscale,Phase ); &#10;");

     text.append("Paths = [  &#10;");
     for (var r=0;r<ropes.length;r++) {
       text.append("[ &#10;");
       path = rope_path(r);text.append("// Rope "+r+" length : "+ropes[r].length+"&#10;");
       for (var i = 0;i < path.length;i++)  {
          s=path[i];
          text.append ("["+s.i+","+s.j + "," + s.pos+"],&#10;");
       }
       text.append("], &#10;");
     }
     text.append("]; &#10;"); 
      $('#info').append ("OpenSCAD generated &#10;");
 };  
 
 
$(document).ready(function() {  
//  make_braid(6,6);
  });   



