use <tile_fns.scad>

p_tri= repeat( [[1,120], [1,90],[1,120],[1,270]],3);
t_tri=peri_to_tile(p_tri);
peri_report(p_tri);
module tri() {
    fill_tile(inset_tile(t_tri,0.02));
}

// scale(20)  tri();

dy=group_offset([t_tri],[0,1,0,4]);
dx=-group_offset([t_tri],[0,1,0,8]);
echo(dx,dy);
scale(20) repeat_tile(10,10,dx,dy) tri();
