use <tile_fns.scad>

r1= 2 * cos(72);
r2 = 1/3;
r3 = 4 * cos(54) /3;

p_kite = [[r1,144],[r1,72],[1,72],[1,72]];
t_kite=peri_to_tile(p_kite);
p_dart = [[r1,216],[r1,36],[1,72],[1,36]];
t_dart=peri_to_tile(p_dart);

Tab=false;      
function tab(step,parity,a,l,td) =
     let (d=(step.x-l)/2)
     let (dl=l+td*2*cos(180-a))
     parity ==0 
         ? [[d,180+a],[td,180-a],[dl,180-a],[td,180+a],[d,step.y]] 
         : [[d,180-a],[td,180+a],[dl,180+a],[td,180-a],[d,step.y]] ;

function tab_peri(peri,start,a=110,l,td) =
   flatten([for(i=[0:len(peri)-1])
       let(p=peri[i])
       tab(p,(start+i)%2,a,l,td)
    ]);
  
tab_angle=110;
tab_width=0.15;
tab_depth=0.07;
inset_d=0;  
p_tab_kite = tab_peri(p_kite,0,tab_angle,tab_width,tab_depth);
    peri_report(p_tab_kite,"kite tabbed");
t_tab_kite=  peri_to_tile(p_tab_kite);
p_tab_dart=  tab_peri(p_dart,1,tab_angle,tab_width,tab_depth);
   peri_report(p_tab_dart,"dart tabbed");
t_tab_dart=peri_to_tile(p_tab_dart);
//scale(20) { color("red") fill_tile(t_dart); number_edges(t_dart); translate([1.5,0,0])  { color("green") fill_tile(t_kite);number_edges(t_kite);}}  

colors= ["red","green","blue","pink","yellow","orange"];
k=0;d=1;
pairings = 
    [[[k,2],[k,3]],[[k,0],[k,1]],[[d,2],[d,3]],[[k,0],[d,0]],[[k,1],[d,1]],[[k,2],[d,2]],[[k,3],[d,3]]];

//should be ableto compute these allowable assemblies of tiles 
assemblies = [
    [[d],[d,2,0,3],[d,2,1,3],[d,2,2,3],[d,2,3,3]],
    [[k],[k,2,0,3],[d,0,0,0]],
    [[k],[k,2,0,3],[k,2,1,3],[k,2,2,3],[k,2,3,3]],
    [[d],[d,2,0,3],[d,2,1,3],[k,3,2,3],[k,2,0,2]],
    [[k],[k,1,0,0],[d,0,1,0],[d,1,0,1]],
    [[k],[k,1,0,0],[d,2,1,2],[k,3,2,3],[k,2,0,3]],
    [[k],[d,1,0,1],[k,2,1,2],[k,2,2,3],[d,0,0,0]]
];
b_transforms = group_multiple_transforms([t_kite,t_dart],assemblies[6]);
// echo("transforms",b_transforms);

u_base = apply_group_transforms([t_kite,t_dart],b_transforms);
echo(u_base);
// scale(20) fill_group(u_base,["red","green"]);

u_tab = apply_group_transforms([t_tab_kite,t_tab_dart],b_transforms);
// scale(20) translate([0,2,0])  fill_group(u_tab,colors);


g_inset=0.01;
scale(20) 
   for (fig=[0:6]) {
       i=fig%4;
       j=floor(fig/4);
       echo(fig,i,j);
       translate([3*i,3*j,0]) {
          b_transforms = group_multiple_transforms([t_kite,t_dart],assemblies[fig]);
          u_base = apply_group_transforms([t_kite,t_dart],b_transforms);
          u_tab = apply_group_transforms([t_tab_kite,t_tab_dart],b_transforms);
          fill_group(inset_group(u_tab,g_inset),colors);
           
       }
   }

