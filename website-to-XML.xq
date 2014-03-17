let $url := "http://dmccooey.com/polyhedra/"
let $body := httpclient:get(xs:anyURI($url),false(),())/httpclient:body/HTML/BODY
return
<solids>
{
for $group in $body//TABLE[../A] 
let $name := normalize-space($group/../A)
return
<group>
  <name>{$name}</name>
    {for $solid in $group//TD[A]
     let $name := normalize-space($solid/A)
     let $name := normalize-space(if (contains($name,":")) then substring-after($name,":") else $name)
     let $id := substring-before($solid/A/@href,".html")
     return
     <solid>
        <id>{$id}</id>
        <name>{$name}</name>
     </solid>
   }
</group>
}
{
  for $page in $body/TABLE/TBODY/TR[empty(.//TABLE)]/TD
  let $link := $page/A
  let $page := $link/@href/string()
  let $url := concat($url,$page)
  let $body := httpclient:get(xs:anyURI($url),false(),())/httpclient:body/HTML/BODY
  return
    <group>
      <name>{normalize-space($link)}</name>
      {for $solid in $body//A
      let $name := normalize-space($solid)
      let $name := normalize-space(if (contains($name,":")) then substring-after($name,":") else $name)
      
      let $id := substring-before($solid/@href,".html")
      where $id != ""  and not (contains($id,"http"))
      return
     <solid>
        <id>{$id}</id>
        <name>{if(matches($name,"^\d+$")) then concat($id," ",$name) else $name}</name>
     </solid> 
      }
    </group>
}
</solids>
