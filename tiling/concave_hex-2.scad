use <tile_fns.scad>

// http://archive.bridgesmathart.org/2009/bridges2009-243.pdf
hex_1_peri = [120,60,240,60,120,120];

// scale(20) fill_tile(peri_to_tile(hex_1_peri));

function hex_2_peri(A) = 
    let (b=sin((180-A)/2) - sin(A/2))
    [[1,270-A/2],[b,90],[b,90+A/2],[1,180-A],[1,90+A/2],[b,90],[b,270-A/2],[1,A]];

A=30;
echo(A);
p=hex_2_peri(A);
peri_report(p);
// scale(20) {fill_tile(peri_to_tile(hex_2_peri(30))); number_edges(t);}
t=peri_to_tile(p);
echo(t);
    m= m_edge_to_edge(edge(t,0), edge(t,3));
echo(m);
hex_unit = rcopy_tile(t,m,3);
/*
 scale(20) {fill_group(hex_unit,["red","green","blue","orange"]);
            number_tiles(hex_unit);
            
 }
*/
tx_o=[0,7,1,4];
ty_o=[0,4,3,7];
tx = offset_group(hex_unit,tx_o);
ty = offset_group(hex_unit,ty_o);
a= atan2(tx[1],tx[0]);
echo(a);
echo(tx,ty);
scale(20)   scale(sin(60)/sin(90-A/2)) rotate([0,0,-A/2])
   repeat_tile(12,12,tx,ty)
     fill_group( inset_group(hex_unit,0.0),["red","purple","blue","green"]);
     
   
