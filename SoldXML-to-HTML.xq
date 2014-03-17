declare option exist:serialize "method=xhtml media-type=text/html";

let $solids := doc("/db/apps/3d/grouped-solids.xml")/solids
let $models := xmldb:get-child-resources("/db/apps/3d/models")
return
<html>
    <head>
        <title>Polyhedra in OpenSCAD</title>
    </head>
    <body>
        <h1>Polyhedra in OpenSCAD</h1>
        <div>Based on this <a href="http://dmccooey.com/polyhedra/">Polyhedra site </a> 
        by David McCooey from where the coordinates are obtained to generate OpenSCAD scripts.  S
        ome polyhedra have accompanying 3-D models using generated STL.</div>
        <hr/>
        <div>
         {for $group in $solids/group
          return
           <div> 
             <h2>{$group/name/string()}</h2> 
              {for $solid in $group/solid
               return
                  <div>
                   {$solid/name/string()}&#160;
                    <a href="http://dmccooey.com/polyhedra/{$solid/id}.html">Java Applet</a>&#160;
                    <a href="solid.xq?id={$solid/id}">OpenSCAD</a>&#160;
                    { if ($models = concat($solid/id,".stl")) 
                      then <a href="view_model.xq?model={$solid/id}&amp;title={$solid/name}">3-D</a> 
                      else ()
                    }
                  </div>
              }  
           </div>
         }
         </div>
    </body>
</html>
