/*
  based on http://www.thingiverse.com/thing:8000
  mods : 
              braille font parameters set as global variables (prefixed $) for clarity
              resolution set globally
              module for printing the label, multiple lines -drawText() - as well as a line - drawLine() 
              dropped the difference operation when drawing dots since embedded in slab anyway
              dot sphere offset because spec requires base which is longer than 2 times the height 
              functions added to compute the radius from a chord length and height
              length() > len()
              max line length calculated with recursive function so width of slab 
                     can be calculated

  todo       mark so the fitter  knows which way up it goes - chamfer top edge?
             allow capitials -openSCAD lacks a function to change the case of a letter, 
                    hence the duplicate entries for both forms of the letter
                    adding the shift character for an uppercase letter is tricky since cannot simply 
                    accumulate the length printed  
             use search instead of looping throught the parallel array for easier maintenance 

*/


function max_length_r(v, i, max) =
     i == len(v) ?  max  : ( len(v[i]) >max ?  max_length_r(v, i+1, len(v[i])) : max_length_r(v, i+1, max) );

function max_length(v) = max_length_r(v,0,0);

// dot is not a hemisphere 

function chord_radius(length,height) = ( length * length /(4 * height) + height)/2;

$charKeys = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G", "h", "H", "i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N", "o", "O", "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T", "u", "U", "v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z", ",", ";", ":", ".", "!", "(", ")", "?", "\"", "*", "'", "-"];

$charValues = [[1], [1], [1, 2], [1, 2], [1, 4], [1, 4], [1, 4, 5], [1, 4, 5], [1, 5], [1, 5], [1, 2, 4], [1, 2, 4], [1, 2, 4, 5], [1, 2, 4, 5], [1, 2, 5], [1, 2, 5], [2, 4], [2, 4], [2, 4, 5], [2, 4, 5], [1, 3], [1, 3], [1, 2, 3], [1, 2, 3], [1, 3, 4], [1, 3, 4], [1, 3, 4, 5], [1, 3, 4, 5], [1, 3, 5], [1, 3, 5], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 5], [1, 2, 3, 5], [2, 3, 4], [2, 3, 4], [2, 3, 4, 5], [2, 3, 4, 5], [1, 3, 6], [1, 3, 6], [1, 2, 3, 6], [1, 2, 3, 6], [2, 4, 5, 6], [2, 4, 5, 6], [1, 3, 4, 6], [1, 3, 4, 6], [1, 3, 4, 5, 6], [1, 3, 4, 5, 6], [1, 3, 5, 6], [1, 3, 5, 6], [2], [2, 3], [2, 5], [2, 5, 6], [2, 3, 5], [2, 3, 5, 6], [2, 3, 5, 6], [2, 3, 6], [2, 3, 6], [3, 5], [3], [3, 6]];


module drawDot(location) {	
    translate(location) 
	   translate ([0,0, -$dotSphereOffset ]) sphere($dotSphereRadius);
}

module drawCharacter(charMap) {
     for(i = [0: len(charMap)-1]) 
          assign(dot = charMap[i] - 1)
	     drawDot(   [floor(dot / 3) * $dotWidth,  -((dot %3) * $dotWidth),   0],  $dotRadius  );
}


module drawLine(line) {
    for(i = [0: len(line)-1]) 	
   	translate([$charWidth*i, 0, 0]) 	
	   for(j = [0:len($charKeys)]) 
		if($charKeys[j] == line[i]) 
		    drawCharacter($charValues[j]);
			                  	
}

module drawText(text) {
    assign(totalHeight = len(text) * $lineHeight)
      translate([0, 0, 1])	
        for(i = [0: len(text)]) 
	    translate([-len(text[i])*$charWidth/2, totalHeight/2-$lineHeight*i, 0])
	        drawLine(text[i]);
}

module label(text, depth=2) {
     assign(width =( max_length(text) + 2)  * $charWidth,
                 height = len(text) * $lineHeight)
        union() {
            translate([0, $lineHeight/3, 0])
                cube([width,height, depth], true);
           drawText(text);
       }
}

$fa = 0.01; $fs = 0.5; 

// global dimensions from http://www.brailleauthority.org/sizespacingofbraille/sizespacingofbraille.pdf

$dotHeight = 0.48;
$dotBase = 1.44;
$dotRadius = $dotBase /2;
$dotWidth= 2.34;
$charWidth = 6.2;
$lineHeight = 12;  // check this 

// compute the sphere to make the raised dot
$dotSphereRadius  =  chord_radius($dotBase,$dotHeight);
$dotSphereOffset =$dotSphereRadius - $dotHeight;

text = ["Hello"]; 

// text = ["All human beings are born", "free and equal in dignity and", "rights. They are endowed with", "reason and conscience and", "should act towards one another", "in a spirit of brotherhood."]; 

label(text);
