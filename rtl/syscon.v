// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module SYSCON(
	input clk,
	input reset,

	output CLK_O,
	output RST_O,
	input [31:0] ADR_I,
	input STB_I,

	output [SLAVES-1:0] STB_O,
	output ERR_O
	
);

parameter SLAVES = 4;

wire [SLAVES-1:0] stb;
assign STB_O = STB_I ? stb : 'd0;
assign ERR_O = STB_I && (stb == 'd0);

assign stb[0] = ADR_I[31:0] < 32'h1000; // ROM
assign stb[1] = (ADR_I[31:0] >= 32'h100000) && (ADR_I[31:0] < 32'h200000); // RAM
assign stb[2] = (ADR_I[31:0] >= 32'h200000) && (ADR_I[31:0] < 32'h200100); // GPIO
assign stb[3] = (ADR_I[31:0] >= 32'h200100) && (ADR_I[31:0] < 32'h200200); // UART

assign RST_O = reset;
assign CLK_O = clk;

endmodule
