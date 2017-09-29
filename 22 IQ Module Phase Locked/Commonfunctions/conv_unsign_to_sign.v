/*	Author:	Matthew Gebert
 *	
 *	Purpose:	To downshift an unsigned(u) N bit number to a signed(s) equivalent N bit number.
 *				Works by manipulating the Nth most significant bit (MSB).
 *				Also handles edgecases of shifting u0000 to s1001 instead of s1000.
 */
module conv_unsign_to_sign(int_signed, int_unsigned);

//Adding 1 to MSB of a signed integer makes it become a linear scale
// from 0 to 2^(n)-1, rather than -2^(n-1) to 2^(n-1)-1
parameter N = 14;
input [N-1:0] int_unsigned;
output [N-1:0] int_signed;

wire [N-1:0] conv = (int_unsigned - {1'b1, {(N-1){1'b0}}});

//Edge Case Caused by unsigned binary to 2's compliment conversion. 
//Consider unsigned 0000 --> signed 1000 == 0, ie not a zero middle point, rather the unsigned point is a minimum
//The edgecase logic in here fixes that issue.
wire edgecase = (int_unsigned == {(N){1'b0}});
wire min = {{1'b1},{(N-2){1'b0}},{1'b1}}; //Min Value in 2's compliment

assign int_signed[N-1:0] = edgecase ?  min : conv[N-1:0];

endmodule