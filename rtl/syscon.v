// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module SYSCON(
	clk,
	reset,

	CLK_O,
	RST_O,
	ADR_I,
	STB_I,

	STB_O,
	ERR_O
);

parameter SLAVES = 7;

input clk;
input reset;

output CLK_O;
output RST_O;
input [31:0] ADR_I;
input STB_I;

output [SLAVES-1:0] STB_O;
output ERR_O;


// memory map
`define BASE_RAM        32'h0000_0000
`define  LEN_RAM          'h0010_0000
`define BASE_BOOTCTRL   32'h8000_0000
`define  LEN_BOOTCTRL     'h8
`define BASE_GPIO       32'h8000_0100
`define  LEN_GPIO         'h28
`define BASE_UART       32'h8000_0200
`define  LEN_UART         'h9
`define BASE_TIMER1     32'h8000_0300
`define  LEN_TIMER1       'h6
`define BASE_TIMER2     32'h8000_0310
`define  LEN_TIMER2       'h6
`define BASE_TIMER3     32'h8000_0320
`define  LEN_TIMER3       'h6
`define BASE_SDSPI      32'h8000_0400
`define  LEN_SDSPI        'h10



wire [6:0] stb;
assign STB_O = STB_I ? stb : 'd0;
assign ERR_O = STB_I && (stb == 'd0);

assign stb[0] = (ADR_I[31:0] >= `BASE_RAM)      && (ADR_I[31:0] < `BASE_RAM      + `LEN_RAM );
assign stb[1] = (ADR_I[31:0] >= `BASE_BOOTCTRL) && (ADR_I[31:0] < `BASE_BOOTCTRL + `LEN_BOOTCTRL );
assign stb[2] = (ADR_I[31:0] >= `BASE_GPIO)     && (ADR_I[31:0] < `BASE_GPIO     + `LEN_GPIO);
assign stb[3] = (ADR_I[31:0] >= `BASE_UART)     && (ADR_I[31:0] < `BASE_UART     + `LEN_UART);
assign stb[4] = (ADR_I[31:0] >= `BASE_TIMER1)   && (ADR_I[31:0] < `BASE_TIMER1   + `LEN_TIMER1);
assign stb[5] = (ADR_I[31:0] >= `BASE_TIMER2)   && (ADR_I[31:0] < `BASE_TIMER2   + `LEN_TIMER1 );
assign stb[6] = (ADR_I[31:0] >= `BASE_SDSPI)    && (ADR_I[31:0] < `BASE_SDSPI    + `LEN_SDSPI );

assign RST_O = reset;
assign CLK_O = clk;

endmodule
