/*
  Knight's tour using Warnsdorf's rule
 
   move is [+-1, +-2] in any order ( 8 possible moves)
   
*/

// board X size
N=8;
// board Y size
M=8;
// start X
i=6;
// start Y
j=2;
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

function slice(list,n)=
    [for (item=list)
        item[n]
    ];

function matrix_to_tour(matrix) =
   let (n=len(matrix))
   let (m=len(matrix[0]))
   let(list=flatten(
          [for (i=[0:n-1])
              [for (j=[0:m-1])
                 [matrix[i][j],[i,j]]
              ]
            ]))
   [n,m,slice(quicksort1(list),1)];

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
         [for (j=[0:len(board[0])-1])
           len(pos_moves([i,j],board))
          ]
    ];
         
function make_move(m,board) =
     [for (i=[0:len(board)-1])
         [for (j=[0:len(board[0])-1])
             (i==m.x && j==m.y) ? 1 : board[i][j]
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

function wall_height(i) = start_height + i * (end_height-start_height);

module all_tours() {
for (i=[0:N-1]) 
   for (j=[0:M-1]) {      
      initial_board= zero_board(N,M);
      kt=tour([i,j],initial_board);
      echo(i,j,"length",len(kt),"closed", is_closed(kt));
   }
};

module tour_2D(kt,closed) {
 final= closed ? 1 : 0;
 for (i=[0:len(kt)-2+final]) {
    m=kt[i];
    n=kt[(i+1)%len(kt)];
    hull() {
        translate([m.x,m.y,0]) cylinder(h=wall_height(i/len(kt)),d=thickness);
        translate([n.x,n.y,0]) cylinder(h=wall_height((i+1)/len(kt)),d=thickness);
    }
 }
};

module matrix_tour() {
t1=[
[1,4,63,28,31,26,19,22],
[62,29,2,5,20,23,32,25],
[3,64,39,30,27,56,21,18],
[38,61,6,53,40,33,24,55],
[7,52,41,34,57,54,17,46],
[60,37,8,49,44,47,14,11],
[51,42,35,58,9,12,45,16],
[36,59,50,43,48,15,10,13]
];
         
tour = matrix_to_tour(t1);
n=tour[0];
m=tour[1];
kt=tour[2];
echo("length",len(kt),"complete", len(kt)==n*m,"closed",is_closed(kt));
echo(kt);
scale(scale) tour_2D(kt,true);
};

Increments =increments();
echo(Increments);
// echo( board_moves(zero_board(N,M)));           
echo("Tour Possible",tour_possible(N,M));    

$fn=fn;

// main 

m=[i,j];
      initial_board= zero_board(N,M);
      kt=tour(m,initial_board);
      closed=is_closed(kt);
      echo(m,"length",len(kt),"complete", len(kt)==N*M,"closed",closed);
      echo(kt);
      scale(scale) tour_2D(kt,closed);


