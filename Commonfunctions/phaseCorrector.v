//======================================================
//  PhaseIncCorrection:
//  	A phase-incrementor shift of s=6001 over a f=858993459 frequency specification
//    (70Hz off of 10MHz) NCO error requires general shifting.
//
//    s/f = 6.98608346446093E-06. Log(s/f, 2) = 17.127
//		In terms of being able to represent this with bit shifting,
//    the closest sum approximation that I can find is:
//
//    -6.98864459991455E-06 =-1/POWER(2,17)+1/POWER(2,21)+1/POWER(2,22)-1/POWER(2,23)+1/POWER(2,24)-1/POWER(2,25)+1/POWER(2,26)
//		Compared to: -6.98608346446093E-06
//=======================================================

module phaseCorrector (
	input [31:0] phaseInc,
	input CLK,
	output [31:0] phaseIncCorr
);
/*addsub a1(
	.add_sub(1'b1), //1 to add, 0 to subtract
	.clock(CLK),
	.dataa(phaseInc),
	.datab((phaseInc>>17)-(phaseInc>>21)+(phaseInc>>22)+(phaseInc>>23)+(phaseInc>>24)-(phaseInc>>25)-(phaseInc>>26) + (phaseInc>>28) + (phaseInc>>29) -(phaseInc>>30) + (phaseInc>>31)),
	.result(phaseIncCorr)
);*/

assign phaseIncCorr[31:0] = phaseInc[31:0] + (phaseInc[31:0]>>17)-(phaseInc[31:0]>>21)+(phaseInc[31:0]>>22)+(phaseInc[31:0]>>23)+(phaseInc[31:0]>>24)-(phaseInc[31:0]>>25)-(phaseInc[31:0]>>26) + (phaseInc[31:0]>>28) + (phaseInc[31:0]>>29) -(phaseInc[31:0]>>30) + (phaseInc[31:0]>>31);

endmodule

