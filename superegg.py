import math;
import sys;

/*
eg. for Piet Heins superegg 

python superegg.py 20 2.5 0.75  > egg.scad    

*/

def fx(radius,x,p,roverh) :
   t = pow(radius,p) - pow(abs(x),p)
   if t > 0 :
     return pow(roverh * t, 1.0/p)
   else : 
     return 0

def shape(radius,p,roverh,max):
   points = []
   for i in range(0,max+1) :     
       a = math.radians(180.0 * i/max)
       y = radius * math.cos(a)
       x = fx(radius,y,p,roverh)
       points.append([x,y])
   return points

def shape_openscad(radius,p,roverh,max) :
   print "module shape() { translate([0,",str(radius),",0]) polygon("
   print shape(radius,p,roverh,max)
   print ");}"

radius = float(sys.argv[1])
p = float(sys.argv[2])
roverh = float(sys.argv[3])

shape_openscad(radius,p,roverh,100)
