// stick model 


// Sides of the tube
Sides = 20;
// Radius of tube
Radius = 0.05;
//Scale of knot
Scale=20;

Colors = [[1,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1]];
 
 
module knot_path(path,r) {
    for (i = [0 : 1 : len(path) - 1 ]) {
        hull() {
            translate(path[i]) sphere(r);
            translate(path[(i + 1) % len(path)]) sphere(r);
        }
    }
};

module knot(paths,r) {
   for (p = [0 : 1 : len(paths) - 1])
     color(Colors[p]) 
        knot_path(paths[p],r);  
};

$fn=Sides;
 scale(Scale) 
   knot(Paths, Radius);
   
