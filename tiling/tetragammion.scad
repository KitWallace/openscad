use <tile_fns.scad>

p_tetragammion= repeat([[2,270],[3,90],[2,90],[ 1,90],[1,270]],4);
p_tx=[4,-1,0];
p_ty=[-p_tx[1],p_tx[0],0];

module tetragammion() {
   fill_tile(inset_tile(centre_tile(peri_to_tile(p_tetragammion)),0.03));
}

//   scale(10) linear_extrude(height=1) tetragammion();


scale(20) repeat_tile(10,10,p_tx,p_ty) tetragammion();
