
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


x = max([1,2,3,4]);
echo(x);

y = min([1,2,3,4]);
echo(y);


function sign(x) =  x > 0 ? +1 : -1;

     
function radians(d) = d * 2 * PI / 360;

