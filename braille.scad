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

/* Joe Fields - Feb. 2020
   Fixed some warnings and deprecations.
   Added support for numbers (added the octothorpe (#) for the Braille number sign, underscore (_) for the decimal point 
    and also the digits which are just repeats of a--j.
   Added a caret "^" for the Braille capitalization symbol.
   Added a flag to allow for left-justified text as well as centered (the default).
*/

$fa = 0.01; $fs = 0.5; 

// global dimensions from http://www.brailleauthority.org/sizespacingofbraille/sizespacingofbraille.pdf

$dotHeight = 0.48;
$dotBase = 1.44;
$dotRadius = $dotBase /2;
$dotWidth= 2.34;
$charWidth = 6.2;
$lineHeight = 10; 

// compute the sphere to make the raised dot
$dotSphereRadius  =  chord_radius($dotBase,$dotHeight);
$dotSphereOffset = $dotSphereRadius - $dotHeight;

function max_length_r(v, i, max) =
     i == len(v) ? max : max_length_r(v, i+1, len(v[i]) > max ? len(v[i]) : max);

function max_length(v) = max_length_r(v,0,0);

// dot is not a hemisphere 

function chord_radius(length,height) = ( length * length /(4 * height) + height)/2;

$charKeys = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G", "h", "H", "i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N", "o", "O", "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T", "u", "U", "v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z", ",", ";", ":", ".", "!", "(", ")", "?", "\"", "*", "'", "-", "#", "1", "2","3","4","5","6","7","8","9","0","_", "^"];

/*Note the Braille dots in the 3 by 2 grid are numbered thusly:

    1  4
    2  5
    3  6
*/

$charValues = [[1], [1], [1, 2], [1, 2], [1, 4], [1, 4], [1, 4, 5], [1, 4, 5], [1, 5], [1, 5], [1, 2, 4], [1, 2, 4], [1, 2, 4, 5], [1, 2, 4, 5], [1, 2, 5], [1, 2, 5], [2, 4], [2, 4], [2, 4, 5], [2, 4, 5], [1, 3], [1, 3], [1, 2, 3], [1, 2, 3], [1, 3, 4], [1, 3, 4], [1, 3, 4, 5], [1, 3, 4, 5], [1, 3, 5], [1, 3, 5], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 5], [1, 2, 3, 5], [2, 3, 4], [2, 3, 4], [2, 3, 4, 5], [2, 3, 4, 5], [1, 3, 6], [1, 3, 6], [1, 2, 3, 6], [1, 2, 3, 6], [2, 4, 5, 6], [2, 4, 5, 6], [1, 3, 4, 6], [1, 3, 4, 6], [1, 3, 4, 5, 6], [1, 3, 4, 5, 6], [1, 3, 5, 6], [1, 3, 5, 6], [2], [2, 3], [2, 5], [2, 5, 6], [2, 3, 5], [2, 3, 5, 6], [2, 3, 5, 6], [2, 3, 6], [2, 3, 6], [3, 5], [3], [3, 6], [3,4,5,6], [1], [1, 2], [1, 4], [1, 4, 5], [1, 5], [1, 2, 4], [1, 2, 4, 5], [1, 2, 5], [2, 4], [2, 4, 5], [4,6], [6]
];


module drawDot(location) {
    translate(location) translate ([0,0, -$dotSphereOffset ]) sphere($dotSphereRadius);
}

module drawCharacter(charMap) {
     for(i = [0: len(charMap)-1]) {
         dot = charMap[i] - 1;
         drawDot(   [floor(dot / 3) * $dotWidth,  -((1+(dot % 3)) * $dotWidth),   0] );
     }
}


module drawLine(line) {
    for(i = [0: len(line)-1]) { 
        translate([$charWidth*i, 0, 0]) {
            for(j = [0:len($charKeys)]) {
                if($charKeys[j] == line[i]) {
                    drawCharacter($charValues[j]);
                }
            }
        }
    }      
}

module drawText(text, just=1) {
    totalHeight = len(text) * $lineHeight;
    mx = max_length(text);
    //echo(mx, $charWidth);
    
    hz = -1 * mx * $charWidth / 2;
    
    translate([0, 0, 1]) {
        for(i = [0: len(text)-1]) {
            vrt = totalHeight-$lineHeight*(i);
            if (just==1) {
                hz = -len(text[i])*$charWidth/2;
                translate([hz, vrt, 0]) {
                    drawLine(text[i]);
                }
            } else {
                hz = -1 * mx * $charWidth / 2;
                translate([hz, vrt, 0]) {
                    drawLine(text[i]);
                }
            }
        }
    }
}

module label(text, depth=2, just=1) {
     width = (max_length(text) + 2)  * $charWidth;
     height = len(text) * $lineHeight;
        union() {
            translate([0, height/2, 0]) {
                cube([width, height, depth], true);
            }
            drawText(text, just);
       }
}


//text = ["^Hello"]; 

text = ["^All human beings are born", "free and equal in dignity and", "rights. ^They are endowed with", "reason and conscience and", "should act towards one another", "in a spirit of brotherhood."]; 

//Test case for numbers:
//text = ["^The first #10 digits of pi", "are #3_141592654"];

label(text);

//translate([0,80,0]) label(text, just=0); //Test case for left-alignment