# -*- coding: utf-8 -*-
"""
Created on Tue Apr 20 14:42:16 2021

@author: dyakov
"""

import gzip
import pickle
import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

with gzip.open('mnist.pkl.gz', 'rb') as f:
    #train_set, valid_set, test_set = pickle.load(f)
    train_set, valid_set, test_set = pickle.load(f, encoding='latin1')
    
train_x, train_y = train_set

width  = 640
height = 480

nSmplInWidth   = math.ceil(640/28)
nSmplInHeight = math.ceil(480/28)

data = train_x[0].reshape((28, 28))
data = data.reshape((28, 28))
#print(data.shape) 

for i in range(0, nSmplInHeight):
    for j in range(0, nSmplInWidth):
        if(j == 0): data = train_x[i + j*nSmplInWidth].reshape((28, 28))
        else      : data = np.append(data, train_x[i + j*nSmplInWidth].reshape((28, 28)), axis=1)
    if(i == 0): 
        res = data
    else      :
        res = np.append(res, data, axis=0)

res = res[0:480,0:640]

#plt.imshow(res[2*28:(3*28),2*28:(3*28)].reshape((28, 28)), cmap=cm.Greys_r)
#plt.show()

#print(res.shape) 
#print(res[15])

bit = 10  
scale = 2**bit

#scale 0-1 range mnist data to 10bit raw data 
Scaled_res = res * scale
Scaled_res = np.round_(Scaled_res)   

#to 10 bit raw rgb(data haven't color and write in gray palitre)  
rgb10 = []

for i in Scaled_res:
    col = []
    for j in i:
        pix = int(j) # >> 2
        #add = (int(j) & 0x3) << 6 | (int(j) & 0x3) << 4 | (int(j) & 0x3) << 2 | int(j) & 0x3
        col.append([pix,pix,pix])
    rgb10.append(col)

#print(rgb10)    
rgb10 = np.array(rgb10) 
#print(rgb10.shape)   
        
plt.imshow((rgb10).astype(np.uint16))
plt.show()

#rgb10 to raw  rgbg 4 pixel / 5 byte 
bayer = 'grbg' # 'gbrg'    
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
#print(mask)

#Bayer filtre
pr = 0
raw = []
for i in range(height):
    col = []
    for j in range(0,width,4):
        quart = []
        for y in range(4): #get 4 pixel
            CellColor = mask[i%2][(j + y)%2] #get pixel color
            if  (CellColor == 'r'): quart.append(int(rgb10[(i), (j + y), (0)])) 
            elif(CellColor == 'g'): quart.append(int(rgb10[(i), (j + y), (1)])) 
            elif(CellColor == 'b'): quart.append(int(rgb10[(i), (j + y), (2)]))
        col.append(quart[0] >> 2)
        col.append(quart[1] >> 2)
        col.append(quart[2] >> 2)
        col.append(quart[3] >> 2)
        
        #add 5'bt lbs
        add = (quart[3] & 0x3) << 6 | (quart[2] & 0x3) << 4 | (quart[1] & 0x3) << 2 | quart[0] & 0x3
        col.append(add)
        
    raw.append(col)

#print('raw',raw)
#raw = np.array(raw)        
#print(raw.shape)


#save raw10 to verilog mememory initialization file
fw= open("../output_files/raw10.hex","w")         
fw.write("@00000000\n")

for i in raw:
    for j in i:
        fw.write((j).to_bytes(1, byteorder='big').hex() + "\n")
fw.close()

fw= open("../output_files/raw10.raw","wb")  
for i in raw:
    for j in i:
        fw.write((j).to_bytes(1, byteorder='big'))
fw.close()
