/*
  Knight's tour using Warnsdorff's rule
 
   move is [0, +-1, +-2]  in any order  ie knights move on a plane
*/

// board X size
N=8;
// board Y size
M=8;
// board Z size
P=8;
// start X
i=4;
// start Y
j=5;
//start k
k=5;

//wall thickness
thickness=0.2;
//scale
scale=20;
// fn -increase for smoother slower object
fn=12;
// functions 
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function quicksort1(arr,col=0) = 
  !(len(arr)>0) ? [] : 
      let(  pivot   = arr[floor(len(arr)/2)][col], 
            lesser  = [ for (y = arr) if (y[col]  < pivot) y ], 
            equal   = [ for (y = arr) if (y[col] == pivot) y ], 
            greater = [ for (y = arr) if (y[col]  > pivot) y ] 
      ) 
      concat( quicksort1(lesser), equal, quicksort1(greater) ); 
        
function increments () =
     flatten([for (i=[-1,+1])
        flatten([for (j=[-2,+2])  
           [[i,j,0],
            [j,i,0],
            [0,i,j],
            [0,j,i],
            [i,0,j],
            [j,0,i]
           ]
        ])
       ]);
        
function km(m) =
   [for (inc = Increments) 
      m+inc
   ];
   
function bound_moves(moves,N,M,P) =
  [for (m=moves) 
       if (m.x >=0 && m.x<N && m.y>=0 && m.y <M && m.z>=0 && m.z <P)
   m];

function allowed_moves(moves,board) =
  [for (m=moves)
      if( board[m.x][m.y][m.z] == 0 ) m
  ];

function pos_moves(m,board) =
  let(mk=km(m))
  let(mb=bound_moves(mk,len(board),len(board[0]),len(board[0][0])))
  allowed_moves(mb,board);
      
function next_moves(moves,board) =
   [for (m=moves)
     let(next=pos_moves(m,board) )
     [len(next),m]
   ];  
   
function zero_board(N,M,P) =
  [for (i=[0:N-1])
     [for (j=[0:M-1])
        [for (k=[0:P-1])
         0
        ]
     ]
  ]; 

function board_moves(board)=
    [for (i=[0:len(board)-1])
         [for (j=[0:len(board[i])-1])
            [for (k=[0:len(board[i][j])-1])
               len(pos_moves([i,j,k],board))
             ]
         ]
    ];
         
function make_move(m,board) =
     [for (i=[0:len(board)-1])
         [for (j=[0:len(board[i])-1])
             [for (k=[0:len(board[i][j])-1])
                (i==m.x && j==m.y && k==m.z) ? 1 : board[i][j][k]
             ]
         ]
     ];

function is_closed(kt) =
// first square is a knights move from the last square
   let(start=kt[0])
   let(end=kt[len(kt)-1])   
   let(mk=km(end))
   [for (m = mk)
      if( m==start) 1
   ][0]==1;    
      
function tour(m,board) =
   tour1(m,make_move(m,board),[m]);
     
function tour1(m,board,moves) =
    let(mp = pos_moves(m,board))
    len(mp) == 0
       ? moves
       : let(mn=next_moves(mp,board))
         let(mq=quicksort1(mn))
         let(best=mq[0][1])
         tour1(best,make_move(best,board),concat(moves,[best]));

module tour_3d(kt, closed) {
    final= closed ? 1 : 0;
    for (i=[0:len(kt)-2+final]) {
    m=kt[i];
    n=kt[(i+1)%len(kt)];
    k= i/len(kt);
    color([k,1-k,1,1])
      hull() {
        translate(m) sphere(thickness/2);
        translate(n) sphere(thickness/2);
    }
}    
};  

module all_tours(k) {
for (i=[0:N-1]) 
   for (j=[0:M-1]) 
     for (k=[0:P-1]) 
           {      
      initial_board= zero_board(N,M,P);
      m=[i,j,k];        
      kt=tour(m,initial_board);
      echo(m,"length",len(kt),"complete", len(kt)== N*M*P,"closed",is_closed(kt));

      // if (is_closed(kt) && (len(kt) == N*M*P))   echo(m);
   }
};
Increments = increments();
//echo(len(Increments));     

initial_board= zero_board(N,M,P);
// echo(board_moves(initial_board));  

mi=[i,j,k];
kt=tour(mi,initial_board);
echo(len(kt));
//echo(kt);
$fn=fn;

scale(scale) tour_3d(kt,is_closed(kt));
