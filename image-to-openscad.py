""" convert from a JPEG image to an openSCAD array declaration
    for inclusion in an openSCAD script
  parameters
    1 image file name
    2  width in pixels of the scaled image
    output openscad code on stdout
  
   uses  PIL, numpy
   Chris Wallace March 2015
  
"""


from PIL import Image
import numpy,sys

def surface_to_openSCAD (surface,file_name,f) :
    f.write('image_file = "' + file_name  + '";\n')
    maxi = surface.shape[1]-1
    maxj = surface.shape[0]-1
    f.write('image_data = [ \n')
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
   
surface_to_openSCAD(pic_array2,file,sys.stdout)
