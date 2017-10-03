// megafunction wizard: %LPM_MULT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: lpm_mult 

// ============================================================
// File Name: lpm_mult_14bit.v
// Megafunction Name(s):
// 			lpm_mult
//
// Simulation Library Files(s):
// 			
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.1.0 Build 162 10/23/2013 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


//lpm_mult DEVICE_FAMILY="Cyclone V" LPM_PIPELINE=8 LPM_REPRESENTATION="SIGNED" LPM_WIDTHA=14 LPM_WIDTHB=14 LPM_WIDTHP=28 MAXIMIZE_SPEED=9 aclr clken clock dataa datab result
//VERSION_BEGIN 13.1 cbx_cycloneii 2013:10:17:04:07:49:SJ cbx_lpm_add_sub 2013:10:17:04:07:49:SJ cbx_lpm_mult 2013:10:17:04:07:49:SJ cbx_mgl 2013:10:17:04:34:36:SJ cbx_padd 2013:10:17:04:07:49:SJ cbx_stratix 2013:10:17:04:07:49:SJ cbx_stratixii 2013:10:17:04:07:49:SJ cbx_util_mgl 2013:10:17:04:07:49:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lpm_mult_14bit_mult
	( 
	aclr,
	clken,
	clock,
	dataa,
	datab,
	result) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clken;
	input   clock;
	input   [13:0]  dataa;
	input   [13:0]  datab;
	output   [27:0]  result;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
	tri1   clken;
	tri0   clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[13:0]	dataa_input_reg;
	reg	[13:0]	datab_input_reg;
	reg	[27:0]	result_output_reg;
	reg	[27:0]	result_extra0_reg;
	reg	[27:0]	result_extra1_reg;
	reg	[27:0]	result_extra2_reg;
	reg	[27:0]	result_extra3_reg;
	reg	[27:0]	result_extra4_reg;
	reg	[27:0]	result_extra5_reg;
	wire	signed	[13:0]	dataa_wire;
	wire	signed	[13:0]	datab_wire;
	wire	signed	[27:0]	result_wire;


	// synopsys translate_off
	initial
		dataa_input_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	dataa_input_reg <= 14'b0;
		else if (clken == 1'b1)	dataa_input_reg <= dataa;
	// synopsys translate_off
	initial
		datab_input_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	datab_input_reg <= 14'b0;
		else if (clken == 1'b1)	datab_input_reg <= datab;
	// synopsys translate_off
	initial
		result_output_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_output_reg <= 28'b0;
		else if (clken == 1'b1)	result_output_reg <= result_extra5_reg;
	// synopsys translate_off
	initial
		result_extra0_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_extra0_reg <= 28'b0;
		else if (clken == 1'b1)	result_extra0_reg <= result_wire[27:0];
	// synopsys translate_off
	initial
		result_extra1_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_extra1_reg <= 28'b0;
		else if (clken == 1'b1)	result_extra1_reg <= result_extra0_reg;
	// synopsys translate_off
	initial
		result_extra2_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_extra2_reg <= 28'b0;
		else if (clken == 1'b1)	result_extra2_reg <= result_extra1_reg;
	// synopsys translate_off
	initial
		result_extra3_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_extra3_reg <= 28'b0;
		else if (clken == 1'b1)	result_extra3_reg <= result_extra2_reg;
	// synopsys translate_off
	initial
		result_extra4_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_extra4_reg <= 28'b0;
		else if (clken == 1'b1)	result_extra4_reg <= result_extra3_reg;
	// synopsys translate_off
	initial
		result_extra5_reg = 0;
	// synopsys translate_on
	always @(posedge clock or posedge aclr)
		if (aclr == 1'b1)	result_extra5_reg <= 28'b0;
		else if (clken == 1'b1)	result_extra5_reg <= result_extra4_reg;

	assign dataa_wire = dataa_input_reg;
	assign datab_wire = datab_input_reg;
	assign result_wire = dataa_wire * datab_wire;
	assign result = ({result_output_reg});

endmodule //lpm_mult_14bit_mult
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module lpm_mult_14bit (
	aclr,
	clken,
	clock,
	dataa,
	datab,
	result)/* synthesis synthesis_clearbox = 1 */;

	input	  aclr;
	input	  clken;
	input	  clock;
	input	[13:0]  dataa;
	input	[13:0]  datab;
	output	[27:0]  result;

	wire [27:0] sub_wire0;
	wire [27:0] result = sub_wire0[27:0];

	lpm_mult_14bit_mult	lpm_mult_14bit_mult_component (
				.aclr (aclr),
				.clock (clock),
				.datab (datab),
				.clken (clken),
				.dataa (dataa),
				.result (sub_wire0));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: AutoSizeResult NUMERIC "1"
// Retrieval info: PRIVATE: B_isConstant NUMERIC "0"
// Retrieval info: PRIVATE: ConstantB NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "8"
// Retrieval info: PRIVATE: Latency NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: PRIVATE: SignedMult NUMERIC "1"
// Retrieval info: PRIVATE: USE_MULT NUMERIC "1"
// Retrieval info: PRIVATE: ValidConstant NUMERIC "0"
// Retrieval info: PRIVATE: WidthA NUMERIC "14"
// Retrieval info: PRIVATE: WidthB NUMERIC "14"
// Retrieval info: PRIVATE: WidthP NUMERIC "28"
// Retrieval info: PRIVATE: aclr NUMERIC "1"
// Retrieval info: PRIVATE: clken NUMERIC "1"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: PRIVATE: optimize NUMERIC "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_HINT STRING "MAXIMIZE_SPEED=9"
// Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "8"
// Retrieval info: CONSTANT: LPM_REPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MULT"
// Retrieval info: CONSTANT: LPM_WIDTHA NUMERIC "14"
// Retrieval info: CONSTANT: LPM_WIDTHB NUMERIC "14"
// Retrieval info: CONSTANT: LPM_WIDTHP NUMERIC "28"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL "aclr"
// Retrieval info: USED_PORT: clken 0 0 0 0 INPUT NODEFVAL "clken"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: dataa 0 0 14 0 INPUT NODEFVAL "dataa[13..0]"
// Retrieval info: USED_PORT: datab 0 0 14 0 INPUT NODEFVAL "datab[13..0]"
// Retrieval info: USED_PORT: result 0 0 28 0 OUTPUT NODEFVAL "result[27..0]"
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @clken 0 0 0 0 clken 0 0 0 0
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @dataa 0 0 14 0 dataa 0 0 14 0
// Retrieval info: CONNECT: @datab 0 0 14 0 datab 0 0 14 0
// Retrieval info: CONNECT: result 0 0 28 0 @result 0 0 28 0
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit.bsf TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_14bit_syn.v TRUE