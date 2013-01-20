/*

  based on http://www.thingiverse.com/thing:8000
  mods : 
              default parameter values only set at top level
              modul efor printing mutliple lines -drawText() - as well as a line - drawLine() 
              resolution set globally
              length() > len()

  todo    mark so the fitter  knows which way up it goes chamfer top edge?
             allow captials using assign 


  openSCAD lacks a function to change the case of a letter. 
  the language lacks the ability to accumuklate a value, so we cant add the shift character for an oppercase letter because we would then haveto accumulate the offsetin the linerather than compute it from an index

*/

charKeys = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G", "h", "H", "i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N", "o", "O", "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T", "u", "U", "v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z", ",", ";", ":", ".", "!", "(", ")", "?", "\"", "*", "'", "-"];

charValues = [[1], [1], [1, 2], [1, 2], [1, 4], [1, 4], [1, 4, 5], [1, 4, 5], [1, 5], [1, 5], [1, 2, 4], [1, 2, 4], [1, 2, 4, 5], [1, 2, 4, 5], [1, 2, 5], [1, 2, 5], [2, 4], [2, 4], [2, 4, 5], [2, 4, 5], [1, 3], [1, 3], [1, 2, 3], [1, 2, 3], [1, 3, 4], [1, 3, 4], [1, 3, 4, 5], [1, 3, 4, 5], [1, 3, 5], [1, 3, 5], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 5], [1, 2, 3, 5], [2, 3, 4], [2, 3, 4], [2, 3, 4, 5], [2, 3, 4, 5], [1, 3, 6], [1, 3, 6], [1, 2, 3, 6], [1, 2, 3, 6], [2, 4, 5, 6], [2, 4, 5, 6], [1, 3, 4, 6], [1, 3, 4, 6], [1, 3, 4, 5, 6], [1, 3, 4, 5, 6], [1, 3, 5, 6], [1, 3, 5, 6], [2], [2, 3], [2, 5], [2, 5, 6], [2, 3, 5], [2, 3, 5, 6], [2, 3, 5, 6], [2, 3, 6], [2, 3, 6], [3, 5], [3], [3, 6]];


module drawDot(location, dotRadius) {	
    translate(location) 
	difference() {	
	   sphere(dotRadius);
	   translate([0, 0, -dotRadius])
               cube(dotRadius*2, true);
	}
}

module drawCharacter(charMap, dotRadius) {
     for(i = [0: len(charMap)-1]) 
	  drawDot([floor((charMap[i]-1)/3)*dotRadius*3, -(charMap[i]-1)%3*dotRadius*3, 0]);
}


module drawLine(line, dotRadius, charWidth) {
    for(i = [0: len(line)-1]) 	
   	translate([charWidth*i, 0, 0]) 	
	   for(j = [0:len(charKeys)]) 
		if(charKeys[j] == line[i]) 
		    drawCharacter(charValues[j], dotRadius);
			                  	
}

module drawText(text, lineHeight = 12, dotRadius = 0.5, charWidth=4.5) {
   totalHeight = len(text)*lineHeight;
   translate([0, 0, 1])	
      for(i = [0: len(text)]) 
	    translate([-len(text[i])*charWidth/2, totalHeight/2-lineHeight*i, 0])
	        drawLine(text[i], dotRadius,  charWidth);
}

// slabWidth need to accomodate the maximum line width 
// but there is no max function over
// a variable length vector to calculate this

module base(text, lineHeight = 12, slabWidth,slabDepth=2) {
   totalHeight = len(text)*lineHeight;
   translate([0, lineHeight/3, 0])
         cube([slabWidth, totalHeight, slabDepth], true);
}

$fa = 0.01; $fs = 0.5; 

text = ["Welcome aboard", "Aremiti"]; width = 70;

// text = ["All human beings are born", "free and equal in dignity and", "rights. They are endowed with", "reason and conscience and", "should act towards one another", "in a spirit of brotherhood."]; width= 110;

base(text,slabWidth=width);  drawText(text);