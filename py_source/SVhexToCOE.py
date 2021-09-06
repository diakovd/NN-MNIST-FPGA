fr=open("../output_files/RAMblock3.hex", "r")
fw= open("../output_files/RAMblock3.coe","w")
print (fr)
print (fw)

Record_type = "00"
lineWR = ""
count = 0
revers = ""
fw.write("memory_initialization_radix=16; \n")
fw.write("memory_initialization_vector=")
#line = fr.readline()
#print line

#for i in range(0,32):
#    fw.write("00000000 ")

line = fr.readline() 

lineWR = ""
for line in fr:
    print(line)
    
    lineWR = lineWR + line.rstrip() + ' '
    
fw.write(lineWR)
fw.close()
fr.close()
print(fr)
print(fw)
