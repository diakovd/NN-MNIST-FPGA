## NN MNIST FPGA 
Purpose of this progect realise simple Neural Nets on FPGA.
Progect get 640x480 image, contained ~374 28x28 pixel MNIST sample image, 
by CSI2 camera interface. At every 28 row of image, the output is set 22 reqognized digit.
Progect is run in simulation. And compiled for xc7a15ticpg236-1L device in Vivado. Not hardware tested

## Structure
------------
nn_mnist.sv
------------

                 +----------+         +----------------------+         +---------------+                                          
MIPI interface   |          |  raw10  | raw10 to RGB         |  Gray8  |               |  out digit                   
---------------->| csi2 rx  |-------->| to Gray scale        |-------->| nn_28x28_pixl |------------>                                                
                 |          |         | 640x480 pixel stream |         |               |                          
                 +----------+         +----------------------+		   +---------------+

------------
raw10toRGB.sv
------------
         +------------+      +------------+      +------------+      +------------+
raw10    |            |  	 |            |      |            |      |            |
-------->| ram line0  |----->| ram line1  |----->| ram line2  |----->| ram line3  |
         | buffer     |      | buffer     |      | buffer     |      | buffer     |    
         +------------+      +------------+      +------------+      +------------+
									|					|					|
									|					|					|
									|					|			        |    +---------------+
									|					|			        |    |               | rgb10
									+-------------------+-------------------+--->| Debaer filter |-------->
																	             | buffer        |
																	             +---------------+

------------
nn_28x28_pixl.sv
------------
         +------------+          +---------------+      +----------------+      +-------------+
rgb10    |            |  Gray8	 | ram 28 line1s |      | ram 28 line1s  |      | Neural      | out digit 
-------->| to Gray8   |--------->| rx buffer     |----->| convertion     |----->| net         |----------->
         |            |          |               |      | buffer         |      | calculation |  
         +------------+          +---------------+      +----------------+      +-------------+

## Folders
- rtl_source - fpga source  
- ms - contane .tcl scripts for modelsim simulation
- vivado_pr  - contane xc7a15t specific RAM modules
- py_source - convertion tool: minst to raw image, network learnig, network quantazation, wight and biases convertion to memory inicialization files  
- output_files - memory inicialization files for NN, and input .raw stream file		 
	 

## License

Unless otherwise noted, everything in this repository is covered by the Apache
License, Version 2.0 (see LICENSE for full text).
 
