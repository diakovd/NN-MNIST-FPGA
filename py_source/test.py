"""
    Testing code for different neural network configurations.
    Adapted for Python 3.5.2

    Usage in shell:
        python3.5 test.py

    Network (network.py and network2.py) parameters:
        2nd param is epochs count
        3rd param is batch size
        4th param is learning rate (eta)

    Author:
        Michał Dobrzański, 2016
        dobrzanski.michal.daniel@gmail.com
"""

# ----------------------
# - read the input data:

import mnist_loader
training_data, validation_data, test_data = mnist_loader.load_data_wrapper()
training_data = list(training_data)
import math

import gzip
import pickle
with gzip.open('mnist.pkl.gz', 'rb') as f:
    #train_set, valid_set, test_set = pickle.load(f)
    train_set, valid_set, test_set = pickle.load(f, encoding='latin1')
    
train_x, train_y = train_set


# ---------------------
# - network.py example:
import network
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import numpy as np
import NetQuantisation

def net_training():
    net = network.Network([784, 30, 10])
    net.SGD(training_data, 30, 10, 3.0, test_data=test_data)
    net.save("net_data_relu.json")

def net_feedforward(n):
    net = network.load("net_data.json")
    data_in = train_x[n]
    training_inputs = np.reshape(data_in, (784, 1)) 
    a = np.argmax(net.feedforward(training_inputs))

    plt.imshow(data_in.reshape((28, 28)), cmap=cm.Greys_r)
    plt.show()
    print(' ----------------------')
    print('recognize = ',a)

def trainDat28x28toSVhex():
    data_in = train_x[7]
    training_inputs = np.reshape(data_in, (784, 1)) 
    training_inputs, scaleI, zeroI = NetQuantisation.inputQuant(training_inputs)    

    fw= open("../output_files/inputData.hex","w")         
    fw.write("@00000000\n")
    l1 = training_inputs.tolist()
    print(l1)
    for i in l1:
        for j in i:
            fw.write((int(j)).to_bytes(1, byteorder='big', signed=True).hex() + "\n")
    fw.close()      

def net_feedforward_quant(n):
    net, scaleW, zeroW = network.load_Quantisation()
    
    data_in = train_x[n]
    #print(' -----data_in-----------------')
    #print(data_in)
    training_inputs = np.reshape(data_in, (784, 1)) 
    #print(training_inputs)
    #training_inputs = 143 + training_inputs / 0.06712171452933859  
    
    training_inputs, scaleI, zeroI = NetQuantisation.inputQuant(training_inputs)
    
    #print('tr_in',training_inputs)
    #print('scaleW * scaleI',scaleW * scaleI)
    a = np.argmax(net.feedforward_quant(training_inputs, (scaleW * scaleI)))
    print('m', scaleW * scaleI)
    print(net.feedforward_quant(training_inputs, (scaleW * scaleI)))
    
    plt.imshow(data_in.reshape((28, 28)), cmap=cm.Greys_r)
    plt.show()
    print(' ----------------------')
    print('recognize = ',a)

def net_feedforward_quant_First_Line():
    nSmplInWidth   = math.ceil(640/28)
    nSmplInHeight = math.ceil(480/28) 
       
    for i in range(0, nSmplInHeight):
        for j in range(0, nSmplInWidth): 
            net_feedforward_quant(i + j*nSmplInWidth)

def compare_res():
    
    fr= open("../output_files/rx_digit.dat","r") 
    
    nSmplInWidth   = math.ceil(23)
    nSmplInHeight = math.ceil(17) 
    
    err   = 0
    right = 0
    
    for i in range(0, nSmplInHeight):
        for j in range(0, nSmplInWidth): 
            if(j == 22) :  l = 'none'
            else : 
                l = fr.readline()
                if(len(l) > 0):
                    if(int(l[1]) != int(train_y[i + j*nSmplInWidth])) : err = err + 1;
                    else : right = right + 1 
            #print(train_y[i + j*nSmplInWidth], l)
    x = (err * 100) / (err + right)    
    print('err =', err)
    print('right =', right)
    print('accurate =',(100 - x),'%')
        
def check_net_with_dat_from_nn_fpga():
    net, scaleW, zeroW = network.load_Quantisation()
    #print(training_inputs)
    #training_inputs = 143 + training_inputs / 0.06712171452933859  
    
       
    fr= open("../output_files/x.dat","r") 
    
    i = 0
    dat = []
    data = []
    for x in fr:
        if(x != '--------\n'):
            dat.append(int(x))
            i = i + 1
        else:
            data.append(dat)
            dat = []
            i = 0
            
    #print(data)
    
    data = np.array(data) 
    
    for x in data:
        training_inputs = np.reshape(x, (784, 1))
        #a = np.argmax(net.feedforward_quant(training_inputs,0.0006151480199923106))
        a = np.argmax(net.feedforward(training_inputs*0.0078740))
        #print(net.feedforward_quant(x, 1))
        plt.imshow(x.reshape((28, 28)), cmap=cm.Greys_r)
        plt.show()
        print(' ----------------------')
        print('recognize = ',a)
 
compare_res()    
