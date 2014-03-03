"""
   generate ASCII STL  for a rectangular surface with heights spaced over a grid.
   
   todo 
        facet direction is correct but that's not obvious from the code -needs clarification    
       
   Chris Wallace kitwallace.co.uk
   March 2014

"""

from numpy import *

def vertex (p) :
    return "vertex " + str(p[0]) + " " + str(p[1]) + " " + str(p[2]) + "\n"
 
def tri (p0,p1,p2) :
    return "outer loop\n" + vertex(p0)  + vertex(p1) + vertex(p2)  + "endloop\n"
       
def square(p0,p1,p2,p3) :  
    if abs(p0[2] - p2[2]) < abs(p1[2] - p3[2]) : # chose lesser gradient diagonal 
       return "facet normal 0 0 0 \n" + tri(p0,p2,p1) +  "endfacet\n" + "facet normal 0 0 0 \n" + tri(p2,p0,p3) +  "endfacet\n"
    else :
       return "facet normal 0 0 0 \n" + tri(p0,p3,p1) +  "endfacet\n" + "facet normal 0 0 0 \n" + tri(p3,p2,p1) +  "endfacet\n"
    
def surface_to_STL (surface, spacing, base, name, f) :
    sx = spacing[0]
    sy = spacing[1]
    maxi = surface.shape[1]-1
    maxj = surface.shape[0]-1
    f.write( "solid " + name   + "\n")
# top surface
    for i in range(0, maxi) :
     for j in range(0, maxj) :
       p0 = [i*sx,j*sy,surface[j][i]]
       p1 = [i*sx,(j+1)*sy,surface[j+1][i]]
       p2 = [(i+1)*sx,(j+1)*sy,surface[j+1][i+1]]
       p3 = [(i+1)*sx,j*sy,surface[j][i+1]]
       f.write( square(p0,p1,p2,p3))
# base        
    for i in range(0, maxi) :
      for j in range(0, maxj) :
       p0 = [i*sx,j*sy,base]
       p1 = [(i+1)*sx,j*sy,base]
       p2 = [(i+1)*sx,(j+1)*sy,base]
       p3 = [i*sx,(j+1)*sy,base]
       f.write( square(p0,p1,p2,p3))
#  south side      
    for i in range(0, maxi) :
       p0 = [i*sx,0,surface[0][i]]
       p1 = [(i+1)*sx,0,surface[0][i+1]]
       p2 = [(i+1)*sx,0,base]
       p3 = [i*sx,0,base]
       f.write( square(p0,p1,p2,p3))
 # north side      
    for i in range(0, maxi) :
       p0 = [i*sx,maxj*sy,surface[maxj][i]]
       p1 = [i*sx,maxj*sy,base]
       p2 = [(i+1)*sx,maxj*sy,base]
       p3 = [(i+1)*sx,maxj*sy,surface[maxj][i+1]]
       f.write( square(p0,p1,p2,p3))
# west side
    for j in range(0,maxj) :
       p0 = [0,j*sy,surface[j][0]]
       p1 = [0,j*sy,base]
       p2 = [0,(j+1)*sy,base]
       p3 = [0,(j+1)*sy,surface[j+1][0]]
       f.write( square(p0,p1,p2,p3))
 # east side      
    for j in range(0,maxj) :
       p0 = [maxi*sx,j*sy,surface[j][maxi]]
       p1 = [maxi*sx,(j+1)*sy,surface[j+1][maxi]]
       p2 = [maxi*sx,(j+1)*sy,base]
       p3 = [maxi*sx,j*sy,base]
       f.write( square(p0,p1,p2,p3))
  
    f.write("endsolid "+name + "\n")
