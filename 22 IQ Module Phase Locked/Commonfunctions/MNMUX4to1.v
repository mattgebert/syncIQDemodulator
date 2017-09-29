// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005 

module  MNMUX4to1(
	input [1:0] sel,
	input [N-1:0] dataa [M-1:0],
	input [N-1:0] datab [M-1:0],
	input [N-1:0] datac [M-1:0],
	input [N-1:0] datad [M-1:0],
	output [N-1:0] result [M-1:0]
);
parameter N = 7; //ie 7 bits per display module
parameter M = 6; //ie 6 Display Modules
assign result = sel[1] ? (sel[0] ? datad : datac) : (sel[0] ? datab : dataa);

endmodule 