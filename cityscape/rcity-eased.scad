function random_binary(n,threshold) =
  [for (r = rands(0,1,n))
     r < threshold ? 0 : 1
  ];
  
function cumulative_vector(v,vc=[],i=0) =
    i <len(v)
     ? let (ns = i==0 ? v[i] : vc[i-1]+v[i])
       cumulative_vector(v,concat(vc,ns),i+1)
     : vc;
    
function add(v1,v2) = v1 + v2;
function cumulative_matrix (n,threshold,m=[],i=0) =
   i <n
      ? let (ir = random_binary(n,threshold[i]),
             cir = cumulative_vector(ir),
             mn = i==0 ? cir : m[i-1]+cir)
       cumulative_matrix(n,threshold,concat(m,[mn]),i+1)
      : m;
  
module positive (m,n,d,base,vscale) {
 for (i=[0:n-1])
    for (j=[0:n-1])
        translate([i*d,j*d,0])
           cube([d,d,base+vscale*m[i][j]]);
  
}

n=15;
//thrshold is eased so later sequeces are closer to zero - arbitrary 

threshold=[for (i=[0:n-1]) 0.85 + i/n/8]; 
echo(threshold);  
d=5; 
vscale=2; 
base=5; 

m =cumulative_matrix(n,threshold);
echo (m);
positive(m,n,d,base,vscale);
