use <tile_fns.scad>

// http://archive.bridgesmathart.org/2009/bridges2009-243.pdf
hex_peri = [120,60,240,60,120,120];
peri_report(hex_peri);

hex_tile = peri_to_tile(hex_peri);
// scale(20) fill_tile(peri_to_tile(hex_tile));

// make unit of 4 tiles
m = m_edge_to_edge(edge(hex_tile,1), edge(hex_tile,2));
hex_unit = rcopy_tile(hex_tile,m,5);
/*
scale(20) {
   fill_group(hex_unit,["red","yellow","skyblue"]);
   number_tiles(hex_unit);
}
*/
tx=offset_group(hex_unit,[0,5,2,4]);
ty=offset_group(hex_unit,[0,4,4,5]);
echo(tx,ty);


scale(20) repeat_tile(15,15,tx,ty)
    fill_group(hex_unit,["red","orange","orange","blue","red","orange"]);
