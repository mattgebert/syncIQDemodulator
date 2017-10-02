/*	Author:		Matthew Gebert
*	  Name:		syncIQdemod.v
*	  Purpose: 	Use readin on AD-A or AD-B to mix with input signal.
					Write out I or Q channel, as well as sync to a waveform generator.
					When sync'd from DA-A, and using SW[9,7,4] as 1's, you'll find a mixing frequency close to 1,000,969MHz.
					
					CONTROLS: SW[9:1] - Sets the Phase Incrementor for the Mixing NCO.
								Frequency of NCO is displayed on board HEX displays.
								Input is mixed with cos and sin phases, keeping orthogonality.
								
								SW[0] - High sets the cos multiplier to output, low sets the sin multiplier.
								
					DA-A: Writes out a 10MHz clock reference used to sync an Waveform Generator
					DA-B: Output IQ Waveform, filtered.
					
               Filter Properties located in "filterDesignCoefficients.m"
               Coefficients stored in "firCoefs_SmplFreq65MHz_PassBndEdge0.5MHz34dB_Attstop.txt"
*/

module syncIQdemod(
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
wire	signed	[13:0]	sin_out1, cos_out1;
wire ovalid; //TODO: CHECK IF CORRECT
NCO sin1         (
  .phi_inc_i(phaseincsw),
  .clk	    (CLOCK_50),
  .reset_n  (!reset),
  .clken	 (1'b1),
  .fsin_o	 (sin_out1),
  .fcos_o   (cos_out1),
  .out_valid(ovalid)
);

//10MHz Generator =======================================
wire	signed	[13:0] sin_out_sync_MHz10;
NCO sin2 (
  .phi_inc_i(32'd858999460), //Note, increased from default value of 858993459, which corresponds to a 70Hz correction to hit 10MHz.
  .clk	    (CLOCK_50),
  .reset_n  (!reset),
  .clken	 (1'b1),
  .fsin_o	 (sin_out_sync_MHz10),
  .fcos_o   (),
  .out_valid()
);


//=======================================================
//  Device Output Drivers
//=======================================================
assign	DAC_DA = {14{sin_out_sync_MHz10[13]}}; //Operates as a Square wave on the DC Analog output.
assign	DAC_DB = mixerSin ? unsign_out4 : (QInot ? unsign_out1[13:0] : unsign_out2[13:0]);
assign	LEDR[9] = ovalid;
assign 	LEDR[8:5] = ofvalid[3:0];
assign	LEDR[4] = displayStatus;
assign	LEDR[0] = SW[0];
//=======================================================
//  Modules
//=======================================================
//Mixer:
wire signed [27:0] mixed1, mixed2;
lpm_mult_14bit l1(//Mixes data from ADC-DA with NCO SW Freq
	.aclr(reset),
	.clken(1'b1),
	.clock(CLOCK_50),
	.dataa(inputB),
	.datab(sin_out1),
	.result(mixed1)
 );
lpm_mult_14bit l2(//Mixes data from ADC-DB with NCO SW Freq
	.aclr(reset),
	.clken(1'b1),
	.clock(CLOCK_50),
  .dataa(inputB),
  .datab(cos_out1),
  .result(mixed2)
  );

//Filter: Filters mixed signals from above.
wire [3:0] ofvalid;
wire [32:0] filtered1, filtered2;
fir_filter f1 (
	.clk(CLOCK_50),              //Input data is 50MHz, and we'll filter it at 1MHz.
	.reset_n(~reset),
	.ast_sink_data(mixed1[26:13]),
	.ast_sink_valid(2'b11),
	.ast_sink_error(2'b00),
	.ast_source_data(filtered1),
	.ast_source_valid(ofvalid[3:2]),
	.ast_source_error()
);
fir_filter f2 (
	.clk(CLOCK_50),
	.reset_n(~reset),
	.ast_sink_data(mixed2[26:13]),
	.ast_sink_valid(2'b11),
	.ast_sink_error(2'b00),
	.ast_source_data(filtered2),
	.ast_source_valid(ofvalid[1:0]),
	.ast_source_error()
);



//INPUT & OUTPUT INTERPRETATION
//Unsigned to Signed Converters:
wire signed [13:0] inputB;//inputA, //Converts ADC inputs from unsigned values to a signed representation.
/*defparam c3.N=14;
conv_unsign_to_sign c3 (
  .int_unsigned(ADC_DA),
  .int_signed(inputA)
);*/
defparam c4.N=14;
conv_unsign_to_sign c4 (
  .int_unsigned(ADC_DB),
  .int_signed(inputB)
);

//Signed to Unsigned Converters:
wire[13:0] unsign_out1, unsign_out2, unsign_out3, unsign_out4;
defparam c1.N = 14;
conv_sign_to_unsign c1 (
.int_signed(filtered1[29:16]),
.int_unsigned(unsign_out1)
);

defparam c2.N = 14;
conv_sign_to_unsign c2 (
.int_signed(filtered2[29:16]),
.int_unsigned(unsign_out2)
);


defparam c3.N = 14;
conv_sign_to_unsign c3 (
.int_signed(sin_out_sync_MHz10),
.int_unsigned(unsign_out3)
);

defparam c5.N = 14;
conv_sign_to_unsign c5 (
.int_signed(sin_out1),
.int_unsigned(unsign_out4)
);
//=======================================================
//  Physical Controls
//=======================================================
wire reset = ~KEY[0];
wire QInot = SW[0];
wire mixerSin = SW[1];
wire [31:0] phaseincsw = {4'b0, SW[9:2], 19'd0};

//=======================================================
//  PhaseIncCorrection:
//  	A shift of s=6001 over a f=858993459 frequency specification
//    (70Hz off of 10MHz) NCO error requires general shifting.
//    s/f = 6.98608346446093E-06. Log(s/f, 2) = 17.127
//		In terms of being able to represent this with bit shifting,
//    the closest sum approximation that I can find is:
//
//    -6.98864459991455E-06 =1/POWER(2,21)-1/POWER(2,17)+1/POWER(2,22)-1/POWER(2,23)+1/POWER(2,24)-1/POWER(2,25)+1/POWER(2,26)
//
//		Compared to: -6.98608346446093E-06
//=======================================================
wire [31:0] phaseincswCorr;
addsub a1(
	.add_sub(1'b0), //1 to add, 0 to subtract
	.clock(CLOCK_50),
	.dataa(phaseincsw),
	.datab((phaseincsw>>17)-(phaseincsw>>21)-(phaseincsw>>22)+(phaseincsw>>23)-(phaseincsw>>24)+(phaseincsw>>25)-(phaseincsw>>26)),
	.result(phaseincswCorr)
);

//=======================================================
// NCO|DDS Mixer Frequency Display
//=======================================================


wire [17:0] sampleFreq = 18'd50000; //50MHz
wire displayStatus;
kHzDisplay k1 (
	// Inputs
	.clk_clk(CLOCK_50),
	.reset(reset),
	.sampleFreq(sampleFreq), //18bits are kHz
	.phaseInc(phaseincsw), //32 bits //phaseincswCorr

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