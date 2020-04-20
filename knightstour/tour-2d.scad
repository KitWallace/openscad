/*
  Knight's tour using Warnsdorff's rule
 
   move is [+-1, +-2] in any order ( 8 possible moves)
   
*/

// board X size
N=8;
// board Y size
M=8;
// start X
i=0;
// start Y
j=0;
//wall thickness
thickness=0.15;
//height at start
start_height=1;
//height at end 
end_height=2;
//scale
scale=10;
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
           [[i,j],[j,i]]
        ])
       ]);
        
function km(m) =
  let(i=m.x,j=m.y)
   [for (inc=Increments)
     m+inc
   ];
 
function bound_moves(moves,N,M) =
  [for (m=moves) 
       if (m.x >=0 && m.x<N && m.y>=0 && m.y <M)
   m];

function allowed_moves(moves,board) =
  [for (m=moves)
      if( board[m.x][m.y] == 0 ) m
  ];

function pos_moves(m,board) =
  let(mk=km(m))
  let(mb=bound_moves(mk,len(board),len(board[0])))
  allowed_moves(mb,board);
      
function next_moves(moves,board) =
   [for (m=moves)
     let(next=pos_moves(m,board) )
     [len(next),m]
   ];  
   
function zero_board(N,M) =
  [for (i=[0:N-1])
     [for (j=[0:M-1])
        0
     ]
  ]; 

function tour_possible(N,M) =
 //Schwemnk's Theorem
    let(m=min(N,M))
    let(n=max(N,M))
    let (no = ( m%2==1 && n%2==1) 
              || m==1 || m==2 || m==4
              || m==3 && ( n==4 || n==6 || n==8))
     !no;
        
function board_moves(board)=
    [for (i=[0:len(board)-1])
         [for (j=[0:len(board[i])-1])
           len(pos_moves([i,j],board))
          ]
    ];
         
function make_move(m,board) =
     [for (i=[0:len(board)-1])
         [for (j=[0:len(board[i])-1])
             (i==m.x && j==m.y) ? 1 : board[i][j]
         ]
     ];

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
 
// main 
Increments =increments();
         
echo(tour_possible(N,M));    
         
initial_board= zero_board(N,M);
// BM= board_moves(B);
// echo(BM);  
kt=tour([i,j],initial_board);
echo(len(kt),kt);
$fn=fn;

function wall_height(i) = start_height + i * (end_height-start_height);

scale(scale)
for (i=[0:len(kt)-2]) {
    m=kt[i];
    n=kt[(i+1)%len(kt)];
    hull() {
        translate([m.x,m.y,0]) cylinder(h=wall_height(i/len(kt)),d=thickness);
        translate([n.x,n.y,0]) cylinder(h=wall_height((i+1)/len(kt)),d=thickness);
    }
}    
