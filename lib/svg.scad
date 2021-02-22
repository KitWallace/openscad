/*  functions to generate svg


text on displayed faces is  mirrored
*/

function rstr(list,i=0) =
   i < len(list)
      ? str(list[i],rstr(list,i+1))
      : "";

function text_to_svg(t,p,font="Verdana",color="#00ff00", text_size=3) =
    str("&lt;text x='",p.x,"' y='",p.y,"' font-family='",font, "' fill='",color,"' font-size='",text_size,"'&gt;",t,"&lt;/text&gt;");

function line_to_svg(line) =
    str(" M ", line[0].x,",",line[0].y," L ",  line[1].x,",",line[1].y);

function lines_to_svg(path,color,width) =
    path_to_svg(path,color,width);

function path_to_svg(path,color,width) =
    str("&lt;path d='",rstr([for (line  = path) line_to_svg(line)]) ," ' ",
           "style='fill:#ffffff;stroke:",color,";stroke-width:",width,"'"
           ," /&gt;");

function paths_to_svg(paths) = 
   rstr(
     [for (path=paths)
         path_to_svg(path)
     ]);

function polygon_to_svg(polygon,color,stroke="black",stroke_width=0) =
    str("&lt;polygon points='",
         rstr([for (point  = polygon) str(point[0],",",point[1]," ")]),
           " ' ",
           "style='fill:",color,";stroke:",stroke,";stroke-width:",stroke_width,";stroke-linejoin:round'",
           " /&gt;");
     
function polygons_to_svg(polygons,colors) = 
   rstr(
     [for (i=[0:len(polygons)-1])
         let (polygon = polygons[i])
         let (col = colors[i % len(colors)]) 
         polygon_to_svg(polygon,col)
     ]);

function polygons_to_svg_by_order(polygons,colors,stroke="black",stroke_width=0) = 
   rstr(
     [for (i=[0:len(polygons)-1])
         let (polygon = polygons[i])
         let (col = colors[len(polygon)]) 
         polygon_to_svg(polygon,col,stroke,stroke_width)
     ]);
     
function circle_to_svg(centre, radius,style="fill:black") =
    str("&lt;circle cx='",centre.x,"' cy='",centre.y,"' r='",radius,"' style='",style,"'/&gt;");
    
function dash_line(line,dash_length) =
    let (v = line[1]- line[0])
    let(line_length=norm(v))
    let(n =  floor(line_length/dash_length))
    [for (i=[0:n-1])
      let(a = v *  i / n)
      let(b = v *(i + 0.5) /n)
      [line[0]+a,line[0]+b]
    ];
    
function dash_lines(lines, dash_length) =
     flatten( [for (l = lines)
           dash_line(l,dash_length)
      ]);

function start_svg(box, name,padding=10) =
    let (bx =  ceil(2*box[1].x-box[0].x)+padding)
    let (by =  ceil(2*box[1].y-box[0].y)+padding)

    str("\n\n&lt;svg  xmlns='http://www.w3.org/2000/svg' version='1.1' ",
      " width='",bx,"mm'", " height='",by, "mm' ",
      " viewBox='", floor(box[0].x-padding)," ",floor(box[0].y-padding)," ", bx, " ",by,"'", "&gt;",
    "&lt;title&gt;",name,"&lt;/title&gt;","&lt;g&gt;")  
 ;    
 
function end_svg() = "&lt;/g&gt;&lt;/svg&gt;\n\n";



