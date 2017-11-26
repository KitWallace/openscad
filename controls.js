ntabs=4;
function tab(n) {
  $('#tab'+n).show();
  $('#but'+n).css("background-color","lightgreen");
  for (var i=0;i<ntabs;i++)
     if (i != n) {
       $('#tab'+i).hide(); 
       $('#but'+i).css("background-color","white");
         
     }
};
