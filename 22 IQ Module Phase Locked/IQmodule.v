// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005 

module IQModule(
	input CLK,
	input [31:0] phaseInc,
	input [17:0] sampleFreq, //In kHz specification.
	input reset,
	input signed [13:0] signal,
	output [6:0] HEX [5:0],
	//output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	output signed [13:0] Q, I,
	output [1:0] filtValid,
	output [3:0] filtError,
	output ncoValid, displayStatus
);
//=======================================================
//  Output Assignments
//=======================================================

//=======================================================
//  Driving PLLS & NCO's
//=======================================================
wire	signed	[13:0]	sin_out1, cos_out1;
NCO sin1         (
  .phi_inc_i(phaseIncCorr),
  .clk	    (CLK),
  .reset_n  (!reset),
  .clken	 (1'b1),
  .fsin_o	 (sin_out1),
  .fcos_o   (cos_out1),
  .out_valid(ncoValid)
);

//=======================================================
//  Modules
//=======================================================
//Mixer:
wire signed [27:0] mixed1, mixed2;
lpm_mult_14bit l1(//Mixes data from ADC-DA with NCO SW Freq
	.aclr(reset),
	.clken(1'b1),
	.clock(CLK),
	.dataa(signal),
	.datab(sin_out1),
	.result(mixed1)
 );
lpm_mult_14bit l2(//Mixes data from ADC-DB with NCO SW Freq
	.aclr(reset),
	.clken(1'b1),
	.clock(CLK),
	.dataa(signal),
	.datab(cos_out1),
	.result(mixed2)
  );
  
//Filter: Filters mixed signals from above.
wire [32:0] filtered1, filtered2;
fir_filter f1 (
	.clk(CLK),              //Input data is 50MHz, and we'll filter it at 1MHz.
	.reset_n(~reset),
	.ast_sink_data(mixed1[26:13]),
	.ast_sink_valid(1'b1),
	.ast_sink_error(2'b00),
	.ast_source_data(filtered1),
	.ast_source_valid(filtValid[1]),
	.ast_source_error(filtError[3:2])
);
fir_filter f2 (
	.clk(CLK),
	.reset_n(~reset),
	.ast_sink_data(mixed2[26:13]),
	.ast_sink_valid(2'b1),
	.ast_sink_error(2'b00),
	.ast_source_data(filtered2),
	.ast_source_valid(filtValid[0]),
	.ast_source_error(filtError[1:0])
);
assign I = filtered1[29:16];
assign Q = filtered2[29:16];

//=======================================================
// Phase Correction Specification
//=======================================================
wire [31:0] phaseIncCorr;
phaseCorrector p1(
	.phaseInc(phaseInc),
	.CLK(CLK),
	.phaseIncCorr(phaseIncCorr)
);

//=======================================================
// NCO|DDS Mixer Frequency Display
//=======================================================
wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
assign HEX = '{HEX5, HEX4, HEX3, HEX2, HEX1, HEX0};
kHzDisplay k1 (
	// Inputs
	.clk_clk(CLK),
	.reset(reset),
	.sampleFreq(sampleFreq), //18bits are kHz
	.phaseInc(phaseIncCorr), //32 bits //phaseIncCorr

	// Outputs
	.seven_segment_display_0(HEX0),
	.seven_segment_display_1(HEX1),
	.seven_segment_display_2(HEX2),
	.seven_segment_display_3(HEX3),
	.seven_segment_display_4(HEX4),
	.seven_segment_display_5(HEX5),
	.valid(displayStatus)
);
endmodule 