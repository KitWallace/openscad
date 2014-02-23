"""
  parameters 
      top left lat lomg
      bottom right lat long
      name of file
      base offset
 
  extracts heights from  Terrain 50 data
  
  assumes script is in the same directory as data
  
  Chris Wallace Feb 2014
  kitwallace.co.uk
  
"""
import sys
import zipfile
import numpy as np
from scipy import *

OSletters = [
["SV","SW","SX","SY","SZ","TV"],
["","SR","SS","ST","SU","TQ","TR"],
["","SM","SN","SO","SP","TL","TM"],
["","","SH","SJ","SK","TF","TG"],
["","","SC","SD","SE","TA"],
["","NW","NX","NY","NZ","OV"],
["","NR","NS","NT","NU"],
["NL","NM","NN","NO"],
["NF","NG","NH","NJ","NK"],
["NA","NB","NC","ND"],
["","HW","HX","HY","HZ"],
["","","","HT","HU"],
["","","","","HP"]
]

def OS_to_Grid(e,n) :
     e1= e//10
     n1 =n//10
     prefix = OSletters[n1][e1]
     tile=prefix + str(e -10*e1) + str(n-10*n1)
     return tile.lower()


# Hannah Fry http://hannahfry.co.uk/2012/02/01/converting-latitude-and-longitude-to-british-national-grid/
def WGS84toOSGB36(lat, lon):
    #First convert to radians
    #These are on the wrong ellipsoid currently: GRS80. (Denoted by _1)
    lat_1 = lat*pi/180
    lon_1 = lon*pi/180

    #Want to convert to the Airy 1830 ellipsoid, which has the following:
    a_1, b_1 =6378137.000, 6356752.3141 #The GSR80 semi-major and semi-minor axes used for WGS84(m)
    e2_1 = 1- (b_1*b_1)/(a_1*a_1)   #The eccentricity of the GRS80 ellipsoid
    nu_1 = a_1/sqrt(1-e2_1*sin(lat_1)**2)

    #First convert to cartesian from spherical polar coordinates
    H = 0 #Third spherical coord.
    x_1 = (nu_1 + H)*cos(lat_1)*cos(lon_1)
    y_1 = (nu_1+ H)*cos(lat_1)*sin(lon_1)
    z_1 = ((1-e2_1)*nu_1 +H)*sin(lat_1)

    #Perform Helmut transform (to go between GRS80 (_1) and Airy 1830 (_2))
    s = 20.4894*10**-6 #The scale factor -1
    tx, ty, tz = -446.448, 125.157, -542.060 #The translations along x,y,z axes respectively
    rxs,rys,rzs = -0.1502, -0.2470, -0.8421  #The rotations along x,y,z respectively, in seconds
    rx, ry, rz = rxs*pi/(180*3600.), rys*pi/(180*3600.), rzs*pi/(180*3600.) #In radians
    x_2 = tx + (1+s)*x_1 + (-rz)*y_1 + (ry)*z_1
    y_2 = ty + (rz)*x_1  + (1+s)*y_1 + (-rx)*z_1
    z_2 = tz + (-ry)*x_1 + (rx)*y_1 +  (1+s)*z_1

    #Back to spherical polar coordinates from cartesian
    #Need some of the characteristics of the new ellipsoid
    a, b = 6377563.396, 6356256.909 #The GSR80 semi-major and semi-minor axes used for WGS84(m)
    e2 = 1- (b*b)/(a*a)   #The eccentricity of the Airy 1830 ellipsoid
    p = sqrt(x_2**2 + y_2**2)

    #Lat is obtained by an iterative proceedure:
    lat = arctan2(z_2,(p*(1-e2))) #Initial value
    latold = 2*pi
    while abs(lat - latold)>10**-16:
        lat, latold = latold, lat
        nu = a/sqrt(1-e2*sin(latold)**2)
        lat = arctan2(z_2+e2*nu*sin(latold), p)

    #Lon and height are then pretty easy
    lon = arctan2(y_2,x_2)
    H = p/cos(lat) - nu

    #E, N are the British national grid coordinates - eastings and northings
    F0 = 0.9996012717                   #scale factor on the central meridian
    lat0 = 49*pi/180                    #Latitude of true origin (radians)
    lon0 = -2*pi/180                    #Longtitude of true origin and central meridian (radians)
    N0, E0 = -100000, 400000            #Northing & easting of true origin (m)
    n = (a-b)/(a+b)

    #meridional radius of curvature
    rho = a*F0*(1-e2)*(1-e2*sin(lat)**2)**(-1.5)
    eta2 = nu*F0/rho-1

    M1 = (1 + n + (5/4)*n**2 + (5/4)*n**3) * (lat-lat0)
    M2 = (3*n + 3*n**2 + (21/8)*n**3) * sin(lat-lat0) * cos(lat+lat0)
    M3 = ((15/8)*n**2 + (15/8)*n**3) * sin(2*(lat-lat0)) * cos(2*(lat+lat0))
    M4 = (35/24)*n**3 * sin(3*(lat-lat0)) * cos(3*(lat+lat0))

    #meridional arc
    M = b * F0 * (M1 - M2 + M3 - M4)          

    I = M + N0
    II = nu*F0*sin(lat)*cos(lat)/2
    III = nu*F0*sin(lat)*cos(lat)**3*(5- tan(lat)**2 + 9*eta2)/24
    IIIA = nu*F0*sin(lat)*cos(lat)**5*(61- 58*tan(lat)**2 + tan(lat)**4)/720
    IV = nu*F0*cos(lat)
    V = nu*F0*cos(lat)**3*(nu/rho - tan(lat)**2)/6
    VI = nu*F0*cos(lat)**5*(5 - 18* tan(lat)**2 + tan(lat)**4 + 14*eta2 - 58*eta2*tan(lat)**2)/120

    N = I + II*(lon-lon0)**2 + III*(lon- lon0)**4 + IIIA*(lon-lon0)**6
    E = E0 + IV*(lon-lon0) + V*(lon- lon0)**3 + VI*(lon- lon0)**5 

    #Job's a good'n.
    return E,N
    
    
def load_tile(tile) :  #return the elevation array for this tile 
   prefix = tile[:2] 
   a = np.zeros([200,200])
   fn="data/"+prefix+"/"+tile+"_OST50GRID_20130611.zip"
   try :
      zip = zipfile.ZipFile(fn,"r")
      an= tile.upper()+".asc"
      ascii = zip.read(an)
      lines = ascii.split("\n")
      for i in range(0,200) : 
         a[i] = np.array(lines[i+5].split(" "))  
   except :
      pass
   return a  
   
nm=1850  
samples = 200
rscale = 50

lat_tl = float(sys.argv[1])
long_tl = float(sys.argv[2])
lat_br = float(sys.argv[3])
long_br= float(sys.argv[4])
name= sys.argv[5]
base= float(sys.argv[6])

lat_mid = (lat_tl + lat_br)/2

(east_tl,north_tl) = WGS84toOSGB36(lat_tl, long_tl)
(east_br,north_br) = WGS84toOSGB36(lat_br, long_br)
(east_tl,north_tl) = (int(east_tl),int(north_tl))
(east_br,north_br) = (int(east_br),int(north_br))


print (east_tl, north_tl, east_br,  north_br)

(grid_north_tl, grid_east_tl) = (int(north_tl/10000), int(east_tl/10000))
(grid_north_br, grid_east_br) = (int(north_br/10000), int(east_br/10000))

print (grid_east_tl, grid_north_tl, grid_east_br, grid_north_br)


for north in range(grid_north_br,grid_north_tl+ 1)  :
   for east in range(grid_east_tl,grid_east_br + 1)  :
       tile = OS_to_Grid(east,north)
       print ("// " + tile)
       h=load_tile(tile)
       tile_north_min = samples - int(min (10000, north_tl - north * 10000) / rscale)
       tile_north_max=  samples - int(max (0 , north_br -  north * 10000) / rscale )
       tile_east_max = int(min (10000, east_br - east * 10000)/ rscale)
       tile_east_min = int(max (0 , east_tl -  east * 10000) /rscale)
       print(tile_north_min, tile_north_max, tile_east_min, tile_east_max)
       he= h[tile_north_min: tile_north_max,tile_east_min:tile_east_max]
       if (east ==grid_east_tl) :
           strip = he 
       else :
           strip = hstack([strip,he])
   if (north == grid_north_br) :
       surface = strip
   else :
       surface = vstack([strip,surface])
surface = surface + base
surface = flipud(surface)
savetxt(name + ".txt",surface,"%d")


