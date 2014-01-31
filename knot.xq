declare variable $local:db := concat("/db/",substring-after(system:get-module-load-path(),"/db/"),"/");
declare variable $local:knot-server := "http://www.colab.sfu.ca/KnotPlot/KnotServer/";
declare variable $local:knot-page := "http://newweb.cecm.sfu.ca/cgi-bin/KnotPlot/KnotServer/kserver?knot_type=";
declare variable $local:knot-server-full := "http://www.colab.sfu.ca/KnotPlot/KnotServer/coord/%type.html";
declare variable $local:knot-server-ms := "http://www.colab.sfu.ca/KnotPlot/KnotServer/ms-coord/%type.html";
declare variable $local:knot-server-mseq :=  "http://www.colab.sfu.ca/KnotPlot/KnotServer/mseq-coord/%type.html";
declare variable $local:full-scad := concat($local:db,"full_model.txt");
declare variable $local:stick-scad := concat($local:db,"stick_model.txt");

declare function local:get-knot($type, $kind) {
  let $url := 
       if ($kind="full") then $local:knot-server-full
       else if ($kind="minimal_stick") then $local:knot-server-ms
       else if ($kind="equilateral_stick") then $local:knot-server-mseq
       else ()
  let $url := replace($url,"%type",$type)
  let $doc := httpclient:get(xs:anyURI($url),false(),())/httpclient:body/html
  let $name := normalize-space($doc/head/title)
  let $points := $doc/body/p/pre
  let $path-points := tokenize($points,"&#10;&#10;")
  let $paths := 
     for $path in $path-points
     return 
       <path>
         {for $pline in tokenize($path,"&#10;")
          let $coords := tokenize($pline," ")
          where $pline ne ""
          return 
             <point>{string-join($coords,",")}</point>
         }
       </path>
    
  return
     <knot>
       <source>{$url}</source>
       <knot-type>{$type}</knot-type>
       <name>{$name}</name>
       {$paths}
     </knot>
};

declare function local:knot-to-openscad($knot) {
  concat(
    concat('Knot_name = "',$knot/name,'";&#10;'),
    concat('Knot_type = "',$knot/knot-type,'";&#10;'),
    concat("Paths = [&#10;",
      string-join(
          for $path in $knot/path
          return 
             concat("[&#10;",
                 string-join(
                     for $point in $path/point 
                     return 
                      concat("[", $point/string(),"]")
                     ,",&#10;"
                 ),
             "&#10;]&#10;")
         ,",&#10;")
      ,"];&#10;")
      )
};


let $knot-type := request:get-parameter("knot-type",())
let $render-type:= request:get-parameter("render-type","full")
let $action:= request:get-parameter("action","Inline")
let $knot := if ($knot-type) then local:get-knot($knot-type, $render-type)  else ()
let $scad_path := if ($render-type = "full") then $local:full-scad else $local:stick-scad
let $openscad := if($knot) 
                 then
                    (local:knot-to-openscad($knot),
                     util:binary-to-string(util:binary-doc($scad_path))
                    )
                 else ()
return
if ($action = "Inline")
then 
let $serialize := util:declare-option("exist:serialize", "format=xhtml media-type=text/html")
return
<html>
   <head>
      <title>Knots to openscad</title>
   </head>
   <body>
   <h1><a href="http://kitwallace.co.uk/3d/knot.xq">Knots to openscad</a></h1>
   <div>
      Here you can generate Openscad code to render any knot in the <a href="{$local:knot-server}">Knot Server</a> .  
      <ul>      
      <li>Look up the knot in the Knot Server index </li>
      <li>Note the knot-type value (at the end of the URL)</li>
      <li>In the form below, enter that value as the knot type and choose how the knot is to be rendered 
      <ul>
      <li>full : as a smoothish tube</li>
      <li>minimal stick</li>
      <li>equilateral stick</li>
      </ul>
      </li>
      <li>Click Inline to show the Openscad code on the web page, or Download to save as an Openscad file.</li>
      <li>The preview model is colored to distinguish multiple paths if present.</li>
      <li>You make have to adjust the parameters to get the model to look right.</li>
      <li>Stick models are generated as hulled pairs of spheres, whilst the full coordinates uses oriented cyclinders.</li>
      </ul>
   </div>
   <div style="font-size: 11pt"> A <a href="http://kitwallace.co.uk">Kit Wallace</a> production.</div>
   <hr/>
     <form method="get"  action="?">
     {if ($knot-type) then  <a href="{$local:knot-page}{$knot-type}">Knot Type </a> else "Knot Type" }
     <input type="text" name="knot-type"  length="5" value="{$knot-type}"/>
     Render type
         <select name="render-type" >
          {for $option in ("full", "minimal_stick", "equilateral_stick")
           return element option { 
                      attribute value {$option}, 
                      if ($option=$render-type) then attribute  selected {"selected"} else (),
                      replace($option,"_"," ")
                  }
          }
          </select>
          
          <input type="submit" name="action" value="Inline"/>
          <input type="submit" name="action" value="Download"/>
     </form>
     <div>
 
     </div>
     <pre>
       {$openscad}
       </pre>
 
   </body>
</html>
else 
let $serialize := util:declare-option("exist:serialize", "format=text media-type=text/text")
let $header := response:set-header('content-disposition', concat("attachment; filename=","knot-",$knot-type,"-",$render-type,".scad")) 
return
  $openscad
