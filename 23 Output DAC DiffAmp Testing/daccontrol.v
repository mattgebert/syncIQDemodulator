// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005 
// Note that the above command is required to run system verilog. This is essential for being able to use ARRAYs of ARRAYs, such as the HEX module.

/*	Author:		Matthew Gebert
*	  Name:		DACControl.v
*	  Purpose: 	
*/

module daccontrol(

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

//--------------------------------------------------------
wire [31:0] phaseIncCorr;
phaseCorrector p1(
	.phaseInc(phaseInc0),
	.CLK(CLOCK_12),
	.phaseIncCorr(phaseIncCorr)
);

wire	signed	[13:0]	sin_out1, cos_out1;
NCO sin1         (
  .phi_inc_i(phaseIncCorr),
  .clk	    (CLOCK_12), 
  .reset_n  (!reset),
  .clken	 (1'b1),
  .fsin_o	 (sin_out1),
  .fcos_o   (cos_out1),
  .out_valid(ncoValid)
);

//=======================================================
//  Device Output Drivers
//=======================================================
assign	DAC_DA = outputA;	
assign	DAC_DB = outputB;
//=======================================================
//  Physical Controls
//=======================================================
wire reset = ~KEY[0];
wire [9:0] VoltStep = SW[9:0];

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
.int_signed(sin_out1),
.int_unsigned(outputA)
);

defparam c2.N = 14;
conv_sign_to_unsign c2 (
.int_signed({4'b0000, VoltStep}),
.int_unsigned(outputB)
);
endmodule
