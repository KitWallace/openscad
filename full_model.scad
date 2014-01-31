// Sides of the tube
Sides = 20;
// Radius of tube
Radius = 0.5;
//Scale of knot
Scale= 5;

Colors = [[1,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1]];
 
module disc_p2p(p1, p2, r) {
      assign(p = p2 - p1)
      translate(p1 + p/2)
      rotate([0, 0, atan2(p[1], p[0])])
      rotate([0, atan2(sqrt(pow(p[0], 2)+pow(p[1], 2)),p[2]), 0])
      render() cylinder(h = 0.1, r1 = r, r2 = 0);
};

module knot_path(path,r) {
    for (t = [0: 1: len(path)-1 ])
       assign (p0 = path[t], 
               p1 = path[(t + 1) % len(path)],
               p2 = path[(t + 2) % len(path)] )
        hull() {
          disc_p2p (p0,p1,r);
          disc_p2p (p1,p2,r);   
        }
};

module knot(paths,r) 
  for (i = [0:1:len(paths)-1]) 
    color(Colors[i]) 
       knot_path(paths[i],r); 

$fn=Sides;
scale(Scale)
   knot(Paths,Radius);
  
