/*  functions to generate svg

*/

function rstr(list,i=0) =
   i < len(list)
      ? str(list[i],rstr(list,i+1))
      : "";

function text_to_svg(t,p,font="Verdana",color="#00ff00", text_size=10) =
    str("&lt;text x='",p.x,"' y='",p.y,"' font-family='",font, "' fill='",color,"' font-size='",20,"'&gt;",t,"&lt;/text&gt;");

function line_to_svg(line) =
    str(" M ", line[0].x,",",line[0].y," L ",  line[1].x,",",line[1].y);

function path_to_svg(path,color,width) =
    str("&lt;path d='",rstr([for (line  = path) line_to_svg(line)]) ," ' ",
           "style='fill:#ffffff;stroke:",color,";stroke-width:",width,"'"
           ," /&gt;");

function paths_to_svg(paths) = 
   rstr(
     [for (path=paths)
         path_to_svg(path)
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

