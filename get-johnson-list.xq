declare variable $local:site := "http://www.georgehart.com/virtual-polyhedra/";

declare function local:capitalize( $string as xs:string?)  as xs:string {
     let $s := normalize-space(lower-case($string))
     return
        string-join(
           for $word in tokenize($s," ")
           return concat(upper-case(substring($word,1,1)), substring($word,2))
           ," ")
};
 
let $doc := httpclient:get(xs:anyURI(concat($local:site,"johnson-index.html")),false(),())/httpclient:body
return
<group>
  <name>Johnson Solids</name>
 {for $solid in $doc//li
  let $url := concat($local:site,$solid/a/@href)
  let $name := local:capitalize(substring-before($solid,"("))
  let $no := substring-before(substring-after( $solid,"("),")")
  return
    <solid>
       <id>{$no}</id>
       <url>{$url}</url>
       <name>{$name}({$no})</name>
    </solid>
  }
</group>
