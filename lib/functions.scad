
/*  

some useful functions 

*/

// built-in fns min and max do not tale a vector argument so these versions do

function max_r(v, i, max) =
     i == len(v) ?  max  : ( v[i] >max ?  max_r(v, i+1, v[i] ) : max_r(v, i+1, max) );

function max(v) = max_r(v,0,-99999999999);


function min_r(v, i, min) =
     i == len(v) ?  min  : ( v[i] < min ?  min_r(v, i+1, v[i] ) : min_r(v, i+1, min) );

function min(v) = min_r(v,0,99999999999);

// sum n values of a vector

function v_sum_r(v,n,k) =
      k > n ? 0 : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

function sign(x) =  x > 0 ? +1 : -1;   // now builtin

function radians(d) = d * 2 * PI / 360;

function interpolate(a, b, ratio) = a + (b - a) * ratio;

// vector functions
function length(p)  = sqrt(pow(p[0],2) + pow(p[1],2));
function unit(p) = p / length(p);
function normal (p1,p2) = [ p1[1] - p2[1], p2[0] - p1[0] ] ;
function unit_normal(p1,p2) = normal(p1,p2) / length(normal(p1,p2));


// like search which  isnt in the Lucid version 
function find(key,array) = 
        findx(key,array,0);

function findx(key,array,i) =
        i == len(array)
           ? 0
           :  array[i][0] == key 
                 ?  array[i]
                 : findx(key,array,i+1) 
       ;



x = max([1,2,3,4]);
echo(x);

y = min([1,2,3,4]);
echo(y);

//  ---- tests
