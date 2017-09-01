/*	Author:	Matthew Gebert
 *	Name:		kHzDisplay.v
 *	Purpose: Display a frequency, based on some clock frequency.
		Inputs:	- sampleFreq:
							This is a 18 bit number, which can range from 0 to 262,143.
						- phaseInc:
							This is a 32 bit number, which represents a percentage of
							the sampleFrequency. Similar to phaseInc of an NCO.
 */

module kHzDisplay (
	// Inputs
	clk_clk,
	reset,
	sampleFreq,
	phaseInc,

	// Outputs
	seven_segment_display_0,
	seven_segment_display_1,
	seven_segment_display_2,
	seven_segment_display_3,
	seven_segment_display_4,
	seven_segment_display_5,

	valid
);


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input			clk_clk;
input			reset;
input		[31:0] phaseInc; //Percentage of the given input
input		[17:0] sampleFreq; //Given in kHz gives a range from 0 to 262,143kHz

// Outputs
output	[6:0]	seven_segment_display_0;
output	[6:0]	seven_segment_display_1;
output	[6:0]	seven_segment_display_2;
output	[6:0]	seven_segment_display_3;
output	[6:0]	seven_segment_display_4;
output	[6:0]	seven_segment_display_5;
output			valid;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
reg [49:0] mult = 50'b0;
wire [17:0] percentFreq;
 /*****************************************************************************
  *                       Logic to compute frequency                          *
  *****************************************************************************/
	//16bit representation of 5MHz (ie, 5000): 0001001110001000
	//If we multiply it by an incrementor that represents 10%?
	//32bit representation of 429496730: 00011001100110011001100110011010.
	//32bit representation of 4294967296: 11111111111111111111111111111111.
	//Multiplying 10% value by 5MHz value: 2147483650000
	//32 * 16 bit Value in binrary: 000000011111010000000000000000000000011111010000
	//Rightshift this value by 32 bits? 0000000111110100
	//This value is == 500. Perfect!!

always @(clk_clk)
begin
	mult <= sampleFreq*phaseInc;
end

assign percentFreq = mult[49:32]; //16 bit value.

/*****************************************************************************
 *                     Logic to convert Bin to Dec                           *
 *****************************************************************************/
wire [3:0] ones, tens, hundreds, thousands, tenthousands, hundredthousands;
decParts dec1 (
	.clk(clk_clk),
	.data18bit(percentFreq),
	.ones(ones),
	.tens(tens),
	.hundreds(hundreds),
	.thousands(thousands),
	.tenthousands(tenthousands),
	.hundredthousands(hundredthousands),
	.valid(valid),
	.reset(reset)
);

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

 display segA (
		.data4bit(ones),
		.sevenSegReg(seven_segment_display_0),
		.blank(~valid),
	);

	display segB (
		.data4bit(tens),
		.sevenSegReg(seven_segment_display_1),
		.blank(~valid)
	);

	display segC (
		.data4bit(hundreds),
		.sevenSegReg(seven_segment_display_2),
		.blank(~valid)
	);
	display segD (
		.data4bit(thousands),
		.sevenSegReg(seven_segment_display_3),
		.blank(~valid)
	);
	display segE (
		.data4bit(tenthousands),
		.sevenSegReg(seven_segment_display_4),
		.blank(~valid)
	);
	display segF (
		.data4bit(hundredthousands),
		.sevenSegReg(seven_segment_display_5),
		.blank(~valid)
	);


endmodule
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

module display (data4bit, sevenSegReg, blank);
	input[3:0] data4bit;
	input blank;
	output reg [6:0] sevenSegReg;
	always @(blank, data4bit)
	begin
		case({blank,data4bit})
			5'b00000: sevenSegReg = 7'b1000000;//0
			5'b00001: sevenSegReg = 7'b1111001;//1
			5'b00010: sevenSegReg = 7'b0100100;//2
			5'b00011: sevenSegReg = 7'b0110000;//3
			5'b00100: sevenSegReg = 7'b0011001;//4
			5'b00101: sevenSegReg = 7'b0010010;//5
			5'b00110: sevenSegReg = 7'b0000011;//6
			5'b00111: sevenSegReg = 7'b1111000;//7
			5'b01000: sevenSegReg = 7'b0000000;//8
			5'b01001: sevenSegReg = 7'b0011000;//9
			5'b01010: sevenSegReg = 7'b0001000;//A		//7'b1110111
			5'b01011: sevenSegReg = 7'b0000011;//B		//7'b0011111
			5'b01100: sevenSegReg = 7'b1000110;//C		//7'b1001110
			5'b01101: sevenSegReg = 7'b0100001;//D		//7'b0111101
			5'b01110: sevenSegReg = 7'b0000110;//E		//7'b1001111
			5'b01111: sevenSegReg = 7'b0001110;//F		//7'b1000111
			default: sevenSegReg = 7'b1111111;//Blank
		endcase
	end
endmodule


module decParts(clk, data18bit, ones, tens, hundreds, thousands, tenthousands, hundredthousands, valid, reset);
	input clk, reset;
	input [17:0] data18bit;
	output [3:0] ones, tens, hundreds, thousands, tenthousands, hundredthousands;
	output valid;
	wire blk1, blk2, blk3, blk4;

	wire [17:0] r1;
	defparam gHTh.DECVAL = 100000;
	defparam gHTh.BITSIZE = 18; // 262144
	getElementAmnt gHTh ( //HundredThousands
	//In
		.clk	(clk),
		.reset(reset),
		.enable(1'b1),
		.dataIn(data18bit),
	//Out
		.valid(blk1),
		.value(hundredthousands),
		.dataOut(r1),
	);

	wire [17:0] r2;
	defparam gTTh.DECVAL = 10000;
	defparam gTTh.BITSIZE = 17; //131072
	getElementAmnt gTTh ( //TensThousands
	//In
		.clk	(clk),
		.reset(reset),
		.enable(blk1),
		.dataIn(r1[17:0]),
	//Out
		.valid(blk2),
		.value(tenthousands),
		.dataOut(r2),
	);

	wire [13:0] r3;
	defparam gTh.DECVAL = 1000;
	defparam gTh.BITSIZE = 14;
	getElementAmnt gTh ( //Thousands
	//In
		.clk	(clk),
		.reset(reset),
		.enable(blk2),
		.dataIn(r2[13:0]),
	//Out
		.valid(blk3),
		.value(thousands),
		.dataOut(r3),
	);

	wire [9:0] r4;
	defparam gH.DECVAL = 100;
	defparam gH.BITSIZE = 10;
	getElementAmnt gH ( //Hundreds
	//In
		.clk	(clk),
		.reset(reset),
		.enable(blk3),
		.dataIn(r3[9:0]),
	//Out
		.valid(blk4),
		.value(hundreds),
		.dataOut(r4),
	);

	wire [6:0] r5;
	defparam gT.DECVAL = 10;
	defparam gT.BITSIZE = 7;
	getElementAmnt gT ( //Tens
	//In
		.clk	(clk),
		.reset(reset),
		.enable(blk4),
		.dataIn(r4[6:0]),
	//Out
		.valid(valid),
		.value(tens),
		.dataOut(r5), //Ones are the remainder output of Tens.
	);

	assign ones[3:0] = r5[3:0];

endmodule


module getElementAmnt(clk, enable, dataIn, valid, value, dataOut, reset);
parameter DECVAL = 10;
parameter BITSIZE = 18;

input clk, enable, reset;
input [BITSIZE-1:0] dataIn;
output reg valid;
output reg [BITSIZE-1:0] dataOut;
output reg [3:0] value;

reg [BITSIZE-1:0] originalValue;

always @(posedge clk)
begin
	if (reset==1)
	begin
		dataOut <= dataIn;
		originalValue <= dataIn;
		value <= 4'b0;
		valid <= 1'b0;
	end
	else if (enable == 1)
	begin
		if (originalValue != dataIn) //Original Datavalue has changed. Requires reprocessing.
		begin
			originalValue <= dataIn;
			dataOut <= dataIn;
			value <= 4'b0;
			valid <= 1'b0;
		end
		else if (dataOut > DECVAL - 1) //Remove some value.
		begin
			originalValue <= originalValue;
			dataOut <= dataOut - DECVAL;
			value <= value + 1'b1;
			valid <= 1'b0;
		end
		else if (value > 9) //ERROR STATE, perform reset
		begin
			originalValue <= dataIn;
			dataOut <= dataIn;
			value <= 4'b0;
			valid <= 1'b0;
		end
		else //Data is in a valid output state!
		begin
			originalValue <= originalValue;
			dataOut <= dataOut;
			value <= value;
			valid <= 1'b1;
		end
	end
	else //Not enabled, keep re-writing data.
	begin
		originalValue <= dataIn;
		dataOut <= dataIn;
		value <= 4'b0;
		valid <= 1'b0;
	end
end

endmodule
