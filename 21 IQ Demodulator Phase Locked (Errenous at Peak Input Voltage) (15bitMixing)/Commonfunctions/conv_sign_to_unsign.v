/*	Author:	Matthew Gebert
 *	
 *	Purpose:	To upshift a signed(s) N bit number to an unsigned(u) equivalent N bit number.
 *				Works by manipulating the Nth most significant bit (MSB).
 *				Also handles edgecases of shifting s1000 to u1000 instead of s0000.
 */
module conv_sign_to_unsign(int_signed, int_unsigned);

//Adding 1 to MSB of a signed integer makes it become a linear scale
// from 0 to 2^(n)-1, rather than -2^(n-1) to 2^(n-1)-1

parameter N = 14;
input [N-1:0] int_signed;
output [N-1:0] int_unsigned;

wire [N-1:0] conv = (int_signed[N-1:0] + {1'b1, {(N-1){1'b0}}});

//Edge Case Caused by 2's compliment conversion to unsigned binary. 
//The value of (ie) signed 1000 --> unsigned 0 Rather than the midpoint which is actually unsigned 1000.
//The edgecase logic in here fixes that issue.

wire edgeCase = (int_signed == {1'b1, {(N-1){1'b0}}});
assign int_unsigned[N-1] = conv[N-1] || edgeCase;
assign int_unsigned[N-2:0] = conv[N-2:0];

endmodule
