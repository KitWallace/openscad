e = 2.718281828;
pi = 3.14159265;
rad = 2 * pi / 360;


function sinh(x) = (1 - pow(e, -2 * x)) / (2 * pow(e, -x));
function cosh(x) = (1 + pow(e, -2 * x)) / (2 * pow(e, -x));
function tanh(x) = sinh(x) / cosh(x);
function cot(x) = 1 / tan(x);

function  m(beta,t,long0) = cot(beta) * (t - long0) * rad;

function lox (t,beta,long0) =
    [  cos(t) / cosh(m(beta,t,long0)),
       sin(t) / cosh(m(beta,t,long0)),
       tanh(m(beta,t,long0))
    ];


module loxodrome(long0, beta, r, step) {
  for ( k=[-Limit: step: Limit])
//       echo(long,lox(long,r,beta,long0));
        hull() {
             translate(r * lox(pow(k,3),beta,long0))  sphere(delta);
             translate(r * lox(pow(k+step,3),beta,long0))  sphere(delta);
        }
}

$fn=4;
delta=0.5;
beta =75;
r = 10;
step=0.1;
Limit = 12;

translate ([0,0,r+ delta/2])
   for (long0 = [10:90:280])
      loxodrome(long0,beta,r,step);
