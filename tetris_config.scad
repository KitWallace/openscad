//CUSTOMIZER VARIABLES

// Tetris shape
letter = 5;  // [0:I,1:J,2:L,3:O,4:S,5:T,6:Z]
// size of a unit square 
base=10;
// height 
height=10;
// thickness of sizes and base for outline and box
thickness=2;
// type of object to be generated
type = 2;  // [1:solid,2:box,3:outline]

//CUSTOMIZER VARIABLES END

module solid(shape,base,height) {
        linear_extrude(height=height) 
           for (i = [0:3 ]) 
               assign(sq= shape[i] )
                   translate([base*sq[0] ,  base * sq[1]] ) square(base);
}

module outline(shape,base,height,thickness)  {
        intersection() {
                solid(shape,base,height);
                minkowski() {
                difference () {
                   translate ([0,0,height/2]) cube([200,200,height] ,center=true);
                   translate([0,0,-eps]) solid(shape,base,height+ 2 * eps);
               }
               cylinder(r=thickness);
            }
        }
}

module box(shape,base,height,thickness) {
     union () {
        solid(shape,base,thickness);
        translate ([0,0,thickness]) outline(shape,base,height,thickness);
     }
}

module solids (base,height) {
for (j = [0:6]){
      translate ([0,j*3*base,0])
      assign (piece = tetris[j])   assign (shape = piece[2] )
      color (piece[1]) solid(shape,base,height);
    }
};

module outlines(base,height,thickness) {
  for (j = [0:6]) {
      translate ([0,j*3*base,0])
      assign (piece = tetris [j])  assign (shape = piece[2] )
      outline(shape,base,height,thickness);
    }
}

module boxes(base,height,thickness) {
  for (j = [0:6]) {
      translate ([0,j*3*base,0])
      assign (piece = tetris [j])  assign (shape = piece[2] )
      box(shape,base,height,thickness);
    }
}

tetris =[
              ["I" , "cyan",  [[0,0],[1,0],[2,0],[3,0]] ],
              ["J" , "blue",  [[0,0],[1,0],[2,0],[0,1]] ],
              ["L" ,"orange",  [[0,0],[1,0],[2,0],[2,1]] ],
              ["O", "yellow", [[0,0],[1,0],[1,1],[0,1]] ],
              ["S" ,"green", [[0,0],[1,0],[1,1],[2,1]] ],
              ["T" , "purple", [[0,0],[1,0],[2,0],[1,1]] ],
              ["Z" , "red", [[0,1],[1,1],[1,0],[2,0]] ]
           ] ;

//solids(10,5);
//outlines(10,5,2);
//boxes(10,5,2);

$fn=20;
eps=1;

piece= tetris[letter];
shape  =piece[2];
if (type == 1)  solid(shape,base,height);
else if (type==2) box(shape,base,height,thickness);
else if (type== 3) outline(shape,base,height,thickness);
