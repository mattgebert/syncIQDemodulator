/*Example kHzDisplay module instantiation in verilog.*/


//=======================================================
//	Display Module
//=======================================================
wire [17:0] sampleFreq = 18'd125000; //125MHz //
wire [31:0] phaseselect;
assign phaseselect = {SW[9:0], 22'b0};

kHzDisplay k1 (
	// Inputs
	.clk_clk(CLOCK_50),
	.reset(reset),
	.sampleFreq(sampleFreq), //bits are kHz
	.phaseInc(phaseselect),

	// Outputs
	.seven_segment_display_0(HEX0),
	.seven_segment_display_1(HEX1),
	.seven_segment_display_2(HEX2),
	.seven_segment_display_3(HEX3),
	.seven_segment_display_4(HEX4),
	.seven_segment_display_5(HEX5),
	.valid(LEDR[0])
);
