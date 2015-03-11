""" convert from a JPEG image to an openSCAD array declaration
    for inclusion in an openSCAD script
  parameters
    1 image file name
    2  width in units of the scaled image
    3  0 = normal, 1 = invented
    4  openscad name prefix
    output openscad code on stdout
  
   uses  PIL, numpy
   Chris Wallace March 2015
  
"""


from PIL import Image
import numpy,sys

def surface_to_openSCAD (surface,name,file_name,f) :
    f.write(name+'_file = "' + file_name  + '";\n')
    maxi = surface.shape[1]-1
    maxj = surface.shape[0]-1
    f.write(name +'_data = [ \n')
    for i in range(0, maxi) :
       f.write("[ \n")
       for j in range(0, maxj) :
          f.write( str(surface[j][i]) + ", ")
       f.write("],\n")
    f.write("];\n")

file = sys.argv[1]
width = float(sys.argv[2])
invert = int(sys.argv[3])
name= sys.argv[4]
pic = Image.open(file)
dim = pic.size
ratio =  width /dim[0]
dim_resize = (int(dim[0]*ratio),int(dim[1]*ratio)) 
pic_resize = pic.resize(dim_resize,Image.ANTIALIAS)
pic_greyscale = pic_resize.convert("L")
pic_array = numpy.array(pic_greyscale).reshape((dim_resize[1],dim_resize[0]))
pic_array2 = pic_array / 256.0
if invert == 1 :
   pic_array2 = 1 - pic_array2
   
surface_to_openSCAD(pic_array2,name,file,sys.stdout)
