
 module rgb10toGray8(
	input [29:0] rgb10,
	output [7:0] gray8
 );
 
 logic [11:0] sum;
 logic [9:0] del_by_8;  
 logic [9:0] take_3;  
 logic [9:0] scale_to8;  

 assign sum = rgb10[29:20] + rgb10[19:10] + rgb10[9:0];
 assign del_by_8  = sum >> 3;
 assign take_3    = del_by_8 + del_by_8 + del_by_8;
 assign scale_to8 = take_3 >> 1;
 assign gray8     = (scale_to8 > 255)? 255 : scale_to8;
 
 endmodule