# -*- coding: utf-8 -*-
"""
Created on Fri Apr 16 11:56:25 2021

@author: dyakov
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image  as img

class RawImageBase(object):
    def __init__(self, path, width, height, usize=None, offset=0, dtype=np.uint8):
        self.path = path
        self.width = width
        self.height = height
        self.usize = usize
        self.offset = offset
        self.dtype = dtype
        self.raw = None
        self.rgb = None
        pass

    def load(self):
        # 1. open file
        with open(self.path, 'rb') as infile:
            # 2. skip offset
            infile.read(self.offset)
            # 3. load date from file
            self.raw = np.fromfile(infile, self.dtype)

        # 4. force resize
        #if self.width is not None and self.usize is not None:
        #raw10 5 byte on 4 pixel to np. size of number pixels   
        a =[]
        for n in range(0, int(self.width * self.height * 1.25),5): 
            a.append((self.raw[n] << 2)     | (self.raw[n + 4] & 0x3))
            a.append((self.raw[n + 1] << 2) | ((self.raw[n + 4] >> 2) & 0x3)) 
            a.append((self.raw[n + 2] << 2) | ((self.raw[n + 4] >> 4) & 0x3)) 
            a.append((self.raw[n + 3] << 2) | ((self.raw[n + 4] >> 6) & 0x3))
            
        #print('a = ',a)    
        self.raw = np.array(a)    
        self.raw.resize(self.height, self.width)

        pass

    def getRGB(self, bayer='gbrg'):#gbrg
        bayer = list(bayer)
        rows, cols = (2, 2)
        k = 0
        mask = [] # mask of pixels Bayer pattern (rggb) 
        for i in range(rows):
            col = []
            for j in range(cols):
                col.append(bayer[k])
                k = k + 1
            mask.append(col)  
        print(mask)

        #Bayer filtre
        self.rgb = []
        for i in range(self.height):
            col = []
            for j in range(self.width):
                r = 0
                g = 0
                b = 0
                CellColor = mask[i%2][j%2] #get pixel color
                
                if(CellColor == 'r'): r = self.raw[i, j]
                else:
                    r = 0
                    c = 0
                    for k in range(3):
                        for m in range(3):
                            # scan nerlest pixels with requer color
                            if(i - 1 + k < 0 or j - 1  + m < 0 or i - 1 + k >= self.height or j - 1  + m >= self.width): r = r #check bound of picture
                            elif(k == 1 and m == 1): r = r #skip scan on pixels
                            elif(mask[(i - 1 + k)%2][(j - 1  + m)%2] == 'r') : 
                                r = r + self.raw[(i - 1 + k), (j - 1  + m)]
                                c = c + 1  
                            else : r = r 
                    if(c != 0):r = r/c

                if(CellColor == 'g'): g = self.raw[i, j]
                else:
                    g = 0
                    c = 0
                    for k in range(3):
                        for m in range(3):
                            # scan nerlest pixels with requer color
                            if(i - 1 + k < 0 or j - 1  + m < 0 or i - 1 + k >= self.height or j - 1  + m >= self.width): g = g #check bound of picture
                            elif(k == 1 and m == 1): g = g #skip scan on pixels
                            elif(mask[(i - 1 + k)%2][(j - 1  + m)%2] == 'g') : 
                                g = g + self.raw[(i - 1 + k), (j - 1  + m)]
                                c = c + 1  
                            else : g = g 
                    if(c != 0):g = g/c

                if(CellColor == 'b'): b = self.raw[i, j]
                else:
                    b = 0
                    c = 0
                    for k in range(3):
                        for m in range(3):
                            # scan nerlest pixels with requer color
                            if(i - 1 + k < 0 or j - 1  + m < 0 or i - 1 + k >= self.height or j - 1  + m >= self.width): b = b #check bound of picture
                            elif(k == 1 and m == 1): b = b #skip scan on pixels
                            elif(mask[(i - 1 + k)%2][(j - 1  + m)%2] == 'b') : 
                                b = b + self.raw[(i - 1 + k), (j - 1  + m)]
                                c = c + 1  
                            else : b = b 
                    if(c != 0):b = b/c
                r = int(r) * 1 # >> 2
                g = int(g) * 1 # >> 2
                b = int(b) * 1# >> 2
                col.append([r,g,b])
            self.rgb.append(col)
            
        #print('self.rgb',self.rgb)
        fw= open("../output_files/F.DAT","w") 
        for y in self.rgb:
            for x in y:
                fw.write(hex(x[0]) + ' ' + hex(x[1]) + ' ' + hex(x[2]) + '\n')
        fw.close()
        self.rgb = np.array(self.rgb)
        self.rgb = self.rgb 
        #return self.rgb
    
    def getRAW(self, bayer='gbrg'):
        bayer = list(bayer)
        rows, cols = (2, 2)
        k = 0
        mask = [] # mask of pixels Bayer pattern (rggb) 
        for i in range(rows):
            col = []
            for j in range(cols):
                col.append(bayer[k])
                k = k + 1
            mask.append(col)  
        print(mask)

        #Bayer filtre
        pr = 0
        raw = []
        for i in range(self.height):
            col = []
            for j in range(self.width): 
                CellColor = mask[i%2][j%2] #get pixel color
                if(CellColor   == 'r'): col.append(self.rgb[(i), (j), (0)]) 
                elif(CellColor == 'g'): col.append(self.rgb[(i), (j), (1)]) 
                elif(CellColor == 'b'): col.append(self.rgb[(i), (j), (2)]) 
            raw.append(col)
        #print(raw)
        self.raw = np.array(raw)
    

ImageRaw = RawImageBase("../output_files/raw10.raw",640,480)  
ImageRaw.load()

print(ImageRaw.raw.shape) 
#print(ImageRaw.raw)  

ImageRaw.getRGB()

#print(ImageRaw.rgb.shape) 
#print(ImageRaw.rgb)  


#ImageRaw.getRAW()

#print(ImageRaw.raw.shape) 
#print(ImageRaw.raw)  


plt.imshow((ImageRaw.rgb).astype(np.uint16))
plt.show()

img.imsave('../output_files/name.png', (ImageRaw.rgb).astype(np.uint16))

#from PIL import Image
#im = Image.fromarray((ImageRaw.rgb).astype(np.uint8))
#im.show()
#im.save("your_file.jpeg")

