# -*- coding: utf-8 -*-
"""
Created on Fri Mar 19 16:13:03 2021

@author: dyakov
"""
'''
def quantize_tensor(x, num_bits=8, min_val=None, max_val=None):
    
    if not min_val and not max_val: 
      min_val, max_val = x.min(), x.max()

    qmin = 0.
    qmax = 2.**num_bits - 1.

    scale, zero_point = calcScaleZeroPoint(min_val, max_val, num_bits)
    q_x = zero_point + x / scale
    q_x.clamp_(qmin, qmax).round_()
    q_x = q_x.round().byte()
    
    return QTensor(tensor=q_x, scale=scale, zero_point=zero_point)
'''

def calcScaleZeroPoint(min_val, max_val,num_bits=8):
  # Calc Scale and zero point of next 
  qmin = 0.
  qmax = 2.**num_bits - 1.

  scale = (max_val - min_val) / (qmax - qmin)

  initial_zero_point = qmin - min_val / scale
  
  zero_point = 0
  if initial_zero_point < qmin:
      zero_point = qmin
  elif initial_zero_point > qmax:
      zero_point = qmax
  else:
      zero_point = initial_zero_point

  zero_point = int(zero_point)

  return scale, zero_point

def quantization(x, s, z, alpha_q, beta_q):

    x_q = np.round(1 / s * x + z, decimals=0)
    x_q = np.clip(x_q, a_min=alpha_q, a_max=beta_q)

    return x_q

def quantization_int8(x, s, z):

    x_q = quantization(x, s, z, alpha_q=-128, beta_q=127)
    x_q = x_q.astype(np.int8)

    return x_q

def generate_quantization_constants(alpha, beta, alpha_q, beta_q):

    # Affine quantization mapping
    s = (beta - alpha) / (beta_q - alpha_q)
    z = (beta * alpha_q - alpha * beta_q) / (beta - alpha)
    print(z)
    z = int(z)

    return s, z

def generate_quantization_int8_constants(alpha, beta):

    b = 8
    alpha_q = -2 ** (b-1)
    beta_q = 2 ** (b-1) - 1
    
    print(alpha_q, beta_q)
    print(alpha, beta)

    s, z = generate_quantization_constants(alpha=alpha, beta=beta, alpha_q=alpha_q, beta_q=beta_q)

    return s, z

# ----------------------
#load network
import json
import numpy as np

def weightsQuant():
    num_bits=8
    
    f = open("net_data.json", "r")
    data = json.load(f)
    f.close()
    
    weights = [np.array(w) for w in data["weights"]]
    biases  = [np.array(b) for b in data["biases"]]
    #print('weights',weights)
    
    #weights biases
    a = list(np.reshape(weights[0], (30*784,1)))
    b = list(np.reshape(weights[1], (30*10,1)))
    
    x1 = np.array(a+b)
    
    minval = -10 # np.amin(x1)
    maxval = 10 # np.amax(x1)
    
    #print('weights minval',minval)
    #print('weights maxval',maxval)
    
    qmin = -127
    qmax = 127
    #print('qmin',qmin) 
    #print('qmax',qmax)     
    
    scale, zero_point = generate_quantization_int8_constants(minval, maxval)
    Scaled_weights_L1 = zero_point + weights[0] / scale
    #print('Scaled_weights_L1',Scaled_weights_L1)     
    Scaled_weights_L1 = np.clip(Scaled_weights_L1, qmin, qmax)
    Scaled_weights_L1 = np.clip(Scaled_weights_L1, qmin, qmax)
    Scaled_weights_L1 = np.round_(Scaled_weights_L1)
    
    Scaled_weights_L2 = zero_point + weights[1] / scale
    Scaled_weights_L2 = np.clip(Scaled_weights_L2, qmin, qmax)
    Scaled_weights_L2 = np.clip(Scaled_weights_L2, qmin, qmax)
    Scaled_weights_L2 = np.round_(Scaled_weights_L2)
    
    #print('weights scale',scale)
    #print('weights zero_point',zero_point)
    #print('Scaled_weights_L1',Scaled_weights_L1)
    #print('Scaled_weights_L2',Scaled_weights_L2)
    
    weights = [Scaled_weights_L1,Scaled_weights_L2]
    
    return weights, scale, zero_point 

def biasesQuant():
    
    num_bits=8
    
    f = open("net_data.json", "r")
    data = json.load(f)
    f.close()
    
    weights = [np.array(w) for w in data["weights"]]
    biases  = [np.array(b) for b in data["biases"]]
    #print('biases ',biases)

    #weights biases
    a = list(np.reshape(weights[0], (30*784,1)))
    b = list(np.reshape(weights[1], (30*10,1)))
    
    x1 = np.array(b)
    
    minval = abs(np.amin(x1))
    maxval = abs(np.amax(x1))

    if(maxval>minval): minval = maxval
    else: maxval = minval   
    
    #minval = np.ceil(minval) * -1
    #maxval = np.ceil(maxval)
    #scale biases
    #print('minval',minval)
    #print('maxval',maxval)
    
    a = list(biases[0])
    b = list(biases[1])
    
    x1 = np.array(a+b)
    
    #minval = np.amin(x1)
    #maxval = np.amax(x1)
    minval = -10 # np.amin(x1)
    maxval = 10 # np.amax(x1)    
    
    
    #print('biases minval',minval)
    #print('biases maxval',maxval)
    
    qmin = -127
    qmax =  127
    
    scale, zero_point = generate_quantization_int8_constants(minval, maxval)
    #print('scale',scale)
    #print('zero_point',zero_point)

    Scaled_biases_L1 = quantization_int8(biases[0], scale, zero_point)
    #print('biases quantization_int8',Scaled_biases_L1)
 
    scale, zero_point = calcScaleZeroPoint(minval, maxval, num_bits)
    Scaled_biases_L1 = zero_point + biases[0] / scale
    Scaled_biases_L1 = np.clip(Scaled_biases_L1, qmin, qmax)
    Scaled_biases_L1 = np.clip(Scaled_biases_L1, qmin, qmax)
    Scaled_biases_L1 = np.round_(Scaled_biases_L1)
    
    Scaled_biases_L2 = zero_point + biases[1] / scale
    Scaled_biases_L2 = np.clip(Scaled_biases_L2, qmin, qmax)
    Scaled_biases_L2 = np.clip(Scaled_biases_L2, qmin, qmax)
    Scaled_biases_L2 = np.round_(Scaled_biases_L2)
    
    #print('biases scale',scale)
    #print('biases zero_point',zero_point)
    #print('biases Scaled_weights_L1',Scaled_biases_L1)
    #print('biases Scaled_weights_L2',Scaled_biases_L2)
    
    biases = [Scaled_biases_L1,Scaled_biases_L2]
    return biases

def saveQuntWBtoSVhex(weights,biases):
    #Save quantazed weights and biases to verilog memory initialization file
    # In FPGA nn clculated parallel in size of fist layer ( 30 )
    # So smultaniosly need 30 weights or biases
    
    # Weights and Biases save to RAM in format:
    # 4 block of RAM with data 64 bit, addr 10 bit
    # Memory Map 
    # | addr 0 -> 1023                                                                  |  
    # | lier1                                | lier2                                    |
    # | weights 1 -> 30*784 | biases 1 -> 30 | for 1 -> 10: (weights 1 -> 30 | biases 1)|
    
    # Format word's of 4 block RAM
    #              data  63 - 0
    #
    # block RAM(0) word 0: w(0) w(0) w(0) w(0) w(0) w(0) w(0) w(0) first weight's for 30 nerons 
    # block RAM(1) word 0: w(0) w(0) w(0) w(0) w(0) w(0) w(0) w(0) 
    # block RAM(2) word 0: w(0) w(0) w(0) w(0) w(0) w(0) w(0) w(0) 
    # block RAM(4) word 0: 0x0  0x0  w(0) w(0) w(0) w(0) w(0) w(0) 
    #
    # block RAM(0) word 1: w(1) w(1) w(1) w(1) w(1) w(1) w(1) w(1) second weight's for 30 nerons
    # block RAM(1) word 1: w(1) w(1) w(1) w(1) w(1) w(1) w(1) w(1) 
    # block RAM(2) word 1: w(1) w(1) w(1) w(1) w(1) w(1) w(1) w(1) 
    # block RAM(4) word 1: 0x0  0x0  w(1) w(1) w(1) w(1) w(1) w(1) 
    # ................
    # block RAM(0) word 783: w(783) w(783) w(783) w(783) w(783) w(783) w(783) w(783) 784' weight's for 30 nerons
    # block RAM(1) word 783: w(783) w(783) w(783) w(783) w(783) w(783) w(783) w(783) 
    # block RAM(2) word 783: w(783) w(783) w(783) w(783) w(783) w(783) w(783) w(783) 
    # block RAM(4) word 783: 0x0    0x0    w(783) w(783) w(783) w(783) w(783) w(783) 
    # ................
    # block RAM(0) word 784: b(0) b(0) b(0) b(0) b(0) b(0) b(0) b(0) 
    # block RAM(1) word 784: b(0) b(0) b(0) b(0) b(0) b(0) b(0) b(0) 
    # block RAM(2) word 784: b(0) b(0) b(0) b(0) b(0) b(0) b(0) b(0) 
    # block RAM(4) word 784: 0x0  0x0  b(0) b(0) b(0) b(0) b(0) b(0) 
    # laer 2
    # block RAM(0) word 785: w(0)  w(0)  w(0)  w(0)  w(0)  w(0)  w(0)  w(0)  first weight's of 10 neron 
    # block RAM(1) word 785: 0x0   0x0   0x0   0x0   0x0   0x0   w(0)  w(0) 
    # block RAM(2) word 785: 0x0   0x0   0x0   0x0   0x0   0x0   0x0   0x0 
    # block RAM(4) word 785: 0x0   0x0   0x0   0x0   0x0   0x0   0x0   0x0 
    # ................
    # block RAM(0) word 815: w(29) w(29) w(29) w(29) w(29) w(29) w(29) w(29) 30'st weight's of 10 neron 
    # block RAM(1) word 815: 0x0   0x0   0x0   0x0   0x0   0x0   w(29) w(29) 
    # block RAM(2) word 815: 0x0   0x0   0x0   0x0   0x0   0x0   0x0   0x0 
    # block RAM(4) word 815: 0x0   0x0   0x0   0x0   0x0   0x0   0x0   0x0 
    # ................
    # block RAM(0) word 816: b(0) b(0) b(0) b(0) b(0) b(0) b(0) b(0) 
    # block RAM(1) word 816: 0x0  0x0  0x0  0x0  0x0  0x0  b(0) b(0) 
    # block RAM(2) word 816: 0x0  0x0  0x0  0x0  0x0  0x0  0x0  0x0 
    # block RAM(4) word 816: 0x0  0x0  0x0  0x0  0x0  0x0  0x0  0x0 
    
    weights, scale, zero_point = weights

    fw0= open("../output_files/RAMblock0.hex","w")         
    fw1= open("../output_files/RAMblock1.hex","w")         
    fw2= open("../output_files/RAMblock2.hex","w")         
    fw3= open("../output_files/RAMblock3.hex","w")         

    fw0.write("@0000000000000000\n")
    fw1.write("@0000000000000000\n")
    fw2.write("@0000000000000000\n")
    fw3.write("@0000000000000000\n")

    #write weights laer1
    for i in range(0,784):
        word = []
        for j in range(0,30):
            word.append(weights[0][j][i])
            
        word.append(0x0)
        word.append(0x0)
        
        #print(word)
        for k in range(0,8): 
            fw0.write((int(word[7 - k])).to_bytes(1,      byteorder='big', signed=True).hex())
        fw0.write("\n")
        for k in range(0,8): 
            fw1.write((int(word[7 - k + 8])).to_bytes(1,  byteorder='big', signed=True).hex())
        fw1.write("\n")
        for k in range(0,8): 
            fw2.write((int(word[7 - k + 16])).to_bytes(1, byteorder='big', signed=True).hex())
        fw2.write("\n")
        for k in range(0,8): 
            fw3.write((int(word[7 - k + 24])).to_bytes(1, byteorder='big', signed=True).hex())
        fw3.write("\n")

    #write biases laer1
    word = []
    for j in range(0,30):
        word.append(biases[0][j])
        
    word.append(0x0)
    word.append(0x0)
    
    for k in range(0,8): 
        fw0.write((int(word[7 - k])).to_bytes(1,      byteorder='big', signed=True).hex())
    fw0.write("\n")
    for k in range(0,8): 
        fw1.write((int(word[7 - k + 8])).to_bytes(1,  byteorder='big', signed=True).hex())
    fw1.write("\n")
    for k in range(0,8): 
        fw2.write((int(word[7 - k + 16])).to_bytes(1, byteorder='big', signed=True).hex())
    fw2.write("\n")
    for k in range(0,8): 
        fw3.write((int(word[7 - k + 24])).to_bytes(1, byteorder='big', signed=True).hex())
    fw3.write("\n")

    #write weights laer2
    for i in range(0,30):
        word = []
        for j in range(0,10):
            word.append(weights[1][j][i])
            
        for j in range(0,22): word.append(0x0)
        
        for k in range(0,8): 
            fw0.write((int(word[7 - k])).to_bytes(1,      byteorder='big', signed=True).hex())
        fw0.write("\n")
        for k in range(0,8): 
            fw1.write((int(word[7 - k + 8])).to_bytes(1,  byteorder='big', signed=True).hex())
        fw1.write("\n")
        for k in range(0,8): 
            fw2.write((int(word[7 - k + 16])).to_bytes(1, byteorder='big', signed=True).hex())
        fw2.write("\n")
        for k in range(0,8): 
            fw3.write((int(word[7 - k + 24])).to_bytes(1, byteorder='big', signed=True).hex())
        fw3.write("\n")
    print(word)
    
    #write biases laer2
    word = []
    for j in range(0,10):
        word.append(biases[1][j])
        
    for j in range(0,22): word.append(0x0)
    
    for k in range(0,8): 
        fw0.write((int(word[7 - k])).to_bytes(1,      byteorder='big', signed=True).hex())
    fw0.write("\n")
    for k in range(0,8): 
        fw1.write((int(word[7 - k + 8])).to_bytes(1,  byteorder='big', signed=True).hex())
    fw1.write("\n")
    for k in range(0,8): 
        fw2.write((int(word[7 - k + 16])).to_bytes(1, byteorder='big', signed=True).hex())
    fw2.write("\n")
    for k in range(0,8): 
        fw3.write((int(word[7 - k + 24])).to_bytes(1, byteorder='big', signed=True).hex())
    fw3.write("\n")



    fw0.close()
    fw1.close()
    fw2.close()
    fw3.close()

'''    
    fw= open("../output_files/weightsQuant.hex","w")         
    fw.write("@00000000\n")
    weights, scale, zero_point = weights
    l1 = weights[0].tolist()
    for i in l1:
        for j in i:
            fw.write((int(j)).to_bytes(1, byteorder='big', signed=True).hex() + "\n")

    l2 = weights[1].tolist()
    for i in l2:
        for j in i:
            fw.write((int(j)).to_bytes(1, byteorder='big', signed=True).hex() + "\n")
    fw.close()
'''

'''
    fw = open("../output_files/biasesQuant.hex","w")         
    fw.write("@00000000\n")
    biases = biases
    l1 = biases[0].tolist()
    for i in l1:
        for j in i:
            fw.write((int(j)).to_bytes(1, byteorder='big', signed=True).hex() + "\n")
            
    l2 = biases[1].tolist()
    for i in l2:
        for j in i:
            fw.write((int(j)).to_bytes(1, byteorder='big', signed=True).hex() + "\n")            
    fw.close()
'''

def inputQuant(inputs):
    
    minval = -1
    maxval =  1   
    
    qmin = -127
    qmax =  127

    scale, zero_point = generate_quantization_int8_constants(minval, maxval)
    #print('input scale',scale)
    #print('input zero_point',zero_point)

    Scaled_input = zero_point + inputs / scale
    Scaled_input = np.clip(Scaled_input, qmin, qmax)
    Scaled_input = np.clip(Scaled_input, qmin, qmax)
    Scaled_input = np.round_(Scaled_input)
    
    return Scaled_input, scale, zero_point 

if __name__ == "__main__":
    weights = weightsQuant()
    biases = biasesQuant()

    #print('weights',weights)
    #print('biases' ,biases)
    
    saveQuntWBtoSVhex(weights,biases)
    
    #l = M(w*x) + M(w*x) + M(w*x) ... b