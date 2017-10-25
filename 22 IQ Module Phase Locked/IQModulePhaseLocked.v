// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005 
// Note that the above command is required to run system verilog. This is essential for being able to use ARRAYs of ARRAYs, such as the HEX module.

/*	Author:		Matthew Gebert
*	  Name:		IQModulePhaseLocked.v
*	  Purpose: 	Use readin on AD-A or AD-B to mix with input signal.
					Write out I or Q channel, as well as sync to a waveform generator.
					
					CONTROLS: SW[9:1] - Sets the Phase Incrementor for the Mixing NCO.
								Frequency of NCO is displayed on board HEX displays.
								Input is mixed with cos and sin phases, keeping orthogonality.
								
								SW[0] - High sets the cos multiplier to output, low sets the sin multiplier.
								
					DA-A: Writes out a 10MHz clock reference used to sync an Waveform Generator
					DA-B: Output IQ Waveform, filtered.
					
               Filter Properties located in "filterDesignCoefficients.m"
               Coefficients stored in "firCoefs_SmplFreq65MHz_PassBndEdge0.5MHz34dB_Attstop.txt"
*/

module IQModulePhaseLocked(
inout              ADC_CS_N,
output             ADC_DIN,
input              ADC_DOUT,
output             ADC_SCLK,
///////// AUD /////////
input              AUD_ADCDAT,AUD_ADCLRCK,
inout              AUD_BCLK,AUD_DACLRCK,
output             AUD_DACDAT,AUD_XCK,
///////// CLOCKS /////////
input              CLOCK2_50,CLOCK3_50,CLOCK4_50,CLOCK_50,
///////// HEX /////////
output      [6:0]  HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
///////// KEY /////////
input       [3:0]  KEY,
///////// LEDR /////////
output      [9:0]  LEDR,
///////// SW /////////
input       [9:0]  SW,
//////////////////////////// GPIO ///////////////////////
output		       ADC_CLK_A,ADC_CLK_B,
input		  [13:0]  ADC_DA,ADC_DB,
output		       ADC_OEB_A,ADC_OEB_B,
input		          ADC_OTR_A,ADC_OTR_B,
output		       DAC_CLK_A,DAC_CLK_B,
output	  [13:0]	 DAC_DA,DAC_DB,
output		       DAC_MODE,
output		       DAC_WRT_A,DAC_WRT_B,
output		       POWER_ON,OSC_SMA_ADC4,SMA_DAC4
);
//=======================================================
//  Parameters:
//=======================================================
wire [17:0] sampleFreq = 18'd12500;
wire [31:0] phaseInc0 = 32'd343597384; //343597383.68 * 12.5MHz /2^32 = 1MHz
wire [31:0] phaseInc1 = 32'd1030792151; // 1030792151.04 * 12.5MHz / 2^32 = 3Mhz;
wire [31:0] phaseInc2 = 32'd103079215; // 103079215.104 * 12.5Mhz / 2^32 = 0.3MHz;
//=======================================================
//  Generate 12.5MHz Clock Frequency
//=======================================================
reg [1:0] counter = 2'b0;
always @(posedge CLOCK_50)
begin
	counter <= counter + 2'b01;
end
wire CLOCK_12 = (counter==2'b11);

//=======================================================
//  Device Setup
//=======================================================
assign	POWER_ON  = 1;            //Disable OSC_SMA
//AD Channels
assign	ADC_OEB_A = 0; 		  	    //ADC_OEA Output Enables Inverted
assign	ADC_OEB_B = 0; 			    //ADC_OEB
assign	ADC_CLK_A = CLOCK_50;  	    //PLL Clock to ADC_A
assign	ADC_CLK_B = CLOCK_50;  	    //PLL Clock to ADC_B
//DA Channels
assign	DAC_WRT_A = CLOCK_50;      //Input write signal for PORT A
assign	DAC_WRT_B = CLOCK_50;      //Input write signal for PORT B
assign	DAC_CLK_B = CLOCK_50; 	    //PLL Clock to DAC_B
assign	DAC_CLK_A = CLOCK_50; 	    //PLL Clock to DAC_A
assign	DAC_MODE = 1; 		       //Mode Select. 1 = dual port, 0 = interleaved.

//=======================================================
//  Driving PLLS & NCO's
//=======================================================
//10MHz Locking Generator ===============================
/*wire	signed	[13:0] sin_out_sync_MHz10;
NCO nco1 (
  .phi_inc_i(32'd858999460), //Note, increased from default value of 858993459, which corresponds to a 70Hz correction to hit 10MHz.
  .clk	    (CLOCK_50),
  .reset_n  (!reset),
  .clken	 (1'b1),
  .fsin_o	 (sin_out_sync_MHz10),
  .fcos_o   (),
  .out_valid()
);*/

//=======================================================
//  IQ Modules
//=======================================================
//wire [6:0] m0hex0, m0hex1, m0hex2,m0hex3,m0hex4,m0hex5;
//wire [6:0] hexM0 [5:0];
wire signed [13:0] m0Q, m0I;
wire [7:0] m0status;
IQModule iq0(
	.CLK(CLOCK_12),
	.phaseInc(phaseInc0), //343597383.68 * 12.5MHz /2^32 = 1MHz
	.sampleFreq(sampleFreq), //In kHz specification. [17:0] 
	.reset(reset),
	.signal(inputB),
//	.HEX(hexM0),
	.Q(m0Q), //[13:0] 
	.I(m0I), 
	.filtValid(m0status[7:6]), //[3:0] 
	.filtError(m0status[5:2]),
	.ncoValid(m0status[1])//,
	//.displayStatus(m0status[0])
);

//wire [6:0] hexM1 [5:0];
wire signed [13:0] m1Q, m1I;
wire [7:0] m1status;
IQModule iq1(
	.CLK(CLOCK_12),
	.phaseInc(phaseInc1), // 1030792151.04 * 12.5MHz / 2^32 = 3Mhz
	.sampleFreq(sampleFreq), //In kHz specification. [17:0] 
	.reset(reset),
	.signal(inputB),
//	.HEX(hexM1),
	.Q(m1Q), //[13:0] 
	.I(m1I), 
	.filtValid(m1status[7:6]), //[3:0] 
	.filtError(m1status[5:2]),
	.ncoValid(m1status[1])//,
	//.displayStatus(m1status[0])
);

//wire [6:0] hexM2 [5:0];
wire signed [13:0] m2Q, m2I;
wire [7:0] m2status;
IQModule iq2(
	.CLK(CLOCK_12),
	.phaseInc(phaseInc2), // 103079215.104 * 12.5Mhz / 2^32 = 0.3MHz
	.sampleFreq(sampleFreq), //In kHz specification. [17:0] 
	.reset(reset),
	.signal(inputB),
//	.HEX(hexM2),
	.Q(m2Q), //[13:0] 
	.I(m2I), 
	.filtValid(m2status[7:6]), //[3:0] 
	.filtError(m2status[5:2]),
	.ncoValid(m2status[1])//,
	//.displayStatus(m2status[0])
);

//=======================================================
//  IQ Modules MUXING
//=======================================================
//Create Select Signal from SW Input:
reg [1:0] IQSel;
always @(posedge CLOCK_12)
begin
	casex(IQSW)
		4'b0001: IQSel <= 2'b00;
		4'b001x:	IQSel <= 2'b01;
		4'b01xx:	IQSel <= 2'b10;
		4'b1xxx: IQSel <= 2'b11;
		default:	IQSel <= 2'b00;
	endcase
end

//Choose which IQ Module to use:
wire [27:0] QIdata [0:0];// = '{QInot ? m0Q[13:0] : m0I[13:0]};
defparam m2.M = 1; //1Set
defparam m2.N = 28; //28 Bits per set.
MNMUX4to1 m2(
	.sel(IQSel),
	.dataa('{{m0I, m0Q}}),
	.datab('{{m1I, m1Q}}),
	.datac('{{m2I, m2Q}}),//not used 		'{{m2I, m2Q}}
	.datad(),//not used
	.result(QIdata)
);
/*
//Displaying I or Q Channel
wire [13:0] QorI [0:0];// = '{QInot ? m0Q[13:0] : m0I[13:0]};
defparam m3.M = 1; //1Set
defparam m3.N = 14; //14 Bits per set.
MNMUX4to1 m3(
	.sel({1'b0,QInot}),
	.dataa('{QIdata[0][27:14]}),
	.datab('{QIdata[0][13:0]}),
	.datac(),//not used
	.datad(),//not used
	.result(QorI)
);
*/

/*
//Displying to HEX
wire [6:0] hexDisplay [5:0];
wire [6:0] empty [5:0];
assign empty = '{6{7'b0}};
defparam m1.M = 6; //6 Sets - 6 Displays
defparam m1.N = 7; //7 Bits per set - 7 Lights Per Display
MNMUX4to1 m1(
	.sel(IQSel),
	.dataa(hexM0),
	.datab(hexM1),
	.datac(hexM2),//hexM2),
	.datad(empty),//empty
	.result(hexDisplay)
);
*/

//=======================================================
//  Device Output Drivers
//=======================================================
//assign	DAC_DA = {14{sin_out_sync_MHz10[13]}}; //Operates as a Square wave on the DC Analog output.
//assign	DAC_DB = outputB; //connected to QInotm0
assign	DAC_DA = outputA;	//I channel
assign	DAC_DB = outputB;	//Q channel
//assign	HEX0 = hexDisplay[0], HEX1 = hexDisplay[1], HEX2 = hexDisplay[2], HEX3 = hexDisplay[3], HEX4 = hexDisplay[4], HEX5 = hexDisplay[5];
assign	LEDR[7:0] = m0status;
//=======================================================
//  Physical Controls
//=======================================================
wire reset = ~KEY[0];
wire QInot = SW[0];
wire [3:0] IQSW = SW[9:6];

//=======================================================
// Phase Correction Specification
//=======================================================
/*wire [31:0] phaseIncCorr; //10MHz Correction
phaseCorrector p1(
	.phaseInc(32'd858993459), //50MHz * 858993459 / 2^32 = 9.999999998MHz
	.phaseIncCorr(phaseIncCorr)
);
*/



//=======================================================
// NCO|DDS Mixer Frequency Display
//=======================================================
//Displaying HEX Signal using a single kHzDisplay Module.
wire [31:0] phaseDisplay [0:0];
wire [31:0] empty [0:0];
assign empty = '{1{32'b0}};
defparam m5.M = 1; //6 Sets - 6 Displays
defparam m5.N = 32; //7 Bits per set - 7 Lights Per Display
MNMUX4to1 m5(
	.sel(IQSel),
	.dataa('{phaseInc0}),
	.datab('{phaseInc1}),
	.datac('{phaseInc2}),//hexM2),
	.datad(empty),//empty
	.result(phaseDisplay)
);

//Display
kHzDisplay k1 (
	// Inputs
	.clk_clk(CLOCK_12),
	.reset(reset),
	.sampleFreq(sampleFreq), //18bits are kHz
	.phaseInc(phaseDisplay[0]), //32 bits //phaseIncCorr

	// Outputs
	.seven_segment_display_0(HEX0),
	.seven_segment_display_1(HEX1),
	.seven_segment_display_2(HEX2),
	.seven_segment_display_3(HEX3),
	.seven_segment_display_4(HEX4),
	.seven_segment_display_5(HEX5),
	.valid(m0status[0])
);

//=======================================================
//  Signed Unsigned Conversion Modules
//=======================================================
//Unsigned to Signed Converters:
wire signed [13:0] inputB, inputA; //Converts ADC inputs from unsigned values to a signed representation.
defparam c3.N=14;
conv_unsign_to_sign c3 (
  .int_unsigned(ADC_DA),
  .int_signed(inputA)
);
defparam c4.N=14;
conv_unsign_to_sign c4 (
  .int_unsigned(ADC_DB),
  .int_signed(inputB)
);

//Signed to Unsigned Converters:
wire[13:0] outputA, outputB;
defparam c1.N = 14;
conv_sign_to_unsign c1 (
//.int_signed(14'd0),
.int_signed(QIdata[0][27:14]), //I channel
.int_unsigned(outputA)
);

defparam c2.N = 14;
conv_sign_to_unsign c2 (
//.int_signed(QorI[0]),
.int_signed(QIdata[0][13:0]), //Q channel
.int_unsigned(outputB)
);

endmodule 
