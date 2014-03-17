declare option exist:serialize "method=xhtml media-type=text/html";

let $model := request:get-parameter("model",())
let $title := request:get-parameter("title","")
let $url := request:get-parameter("url",())
return
<html>
    <head>
        <title>{$title}</title>
    </head>
    <body>
        <h1>{$title} </h1>
        <div>
            <canvas id="3d" width="640" height="480"/>
            <script type="text/javascript" src="http://kitwallace.co.uk/js/jsc3d.js"/>
            <script lang="text/javascript">
function init() {{
viewer.setParameter("InitRotationX",-45);
viewer.setParameter("InitRotationY",0);
viewer.setParameter("InitRotationZ",0);
viewer.init();
viewer.update();
}}

var canvas = document.getElementById('3d');
var viewer = new JSC3D.Viewer(canvas);
viewer.setParameter('SceneUrl', 'models/{$model}.stl');
viewer.setParameter('RenderMode', 'flat');
viewer.setParameter('ProgressBar', 'on');
viewer.setParameter("Definition","high");
viewer.setParameter("ModelColor","#B2B2CC");
viewer.setParameter("BackgroundColor1","#FFFFFF");
viewer.setParameter("BackgroundColor2","#FFFFFF");
init();

</script>
        </div>
        <div>
            {if (exists($url)) then <div>See <a href="{$url}">{$url}</a></div> else () }
            <a href="models/{$model}.stl">Download STL</a> &#160;
            <a href="http://kitwallace.co.uk">Kit Wallace</a>
        </div>
    </body>
</html>
