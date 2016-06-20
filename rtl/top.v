// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module top(
   input clk_50mhz, 
   input reset, 
   output uart_tx, 
   input uart_rx, 
		
   output [7:0] leds
);

wire WB_CYC;
wire WB_CLK;
wire WB_RST;
wire WB_STB;
wire WB_WE;
wire WB_ERR;
wire cpu_clk;
wire gpio_ack;
wire gpio_err;
wire gpio_inta;
wire [1:0] slave_select;
wire [1:0] slave_ack;
wire [31:0] cpu_addr;
wire WB_ACK = slave_ack != 'd0;
wire [3:0] WB_SEL; // data select (uds, lds)

wire [31:0] cpu_data_out;
wire [31:0] cpu_data_in;
reg  [31:0] mem_data_o;
wire [31:0] gpio_data_o;
wire [31:0] gpio_ext_pad_output;
wire [31:0] gpio_ext_pad_oe;

assign leds[7:0] = gpio_ext_pad_output[7:0];

assign cpu_data_in[31:0] =
	slave_select == 'd1 ? mem_data_o[31:0] :
	slave_select == 'd2 ? gpio_data_o[31:0] :
	'dX;

assign slave_ack = {
	slave_select[0] /*mem always ack*/,
	slave_select[1] & gpio_ack
};

assign cpu_addr[1:0] = 2'b00;

TG68_wb cpu(
	.CLK_I( WB_CLK ),
	.RST_I( WB_RST ),
	
	.DAT_I( cpu_data_in ),
	.DAT_O( cpu_data_out ),
	.ADR_O( cpu_addr[31:2] ),
	.ACK_I( WB_ACK ),
	.CYC_O( WB_CYC ),
	.STB_O( WB_STB ),
	.SEL_O( WB_SEL ),
	.ERR_I( 1'b0 ),
	.WE_O( WB_WE ),

	.ipl_i( 3'd0 ),
	.cpu_clk(cpu_clk)
);

SYSCON syscon(
	.clk(clk_50mhz),
	.reset(reset),

	.CLK_O( WB_CLK ),
	.RST_O( WB_RST ),
	.ADR_I( cpu_addr ),
	.STB_I( WB_STB ),

	.STB_O( slave_select ),
	.ERR_O( WB_ERR )
);

gpio_top gpio(
	// WISHBONE Interface
	.wb_clk_i( WB_CLK ),
	.wb_rst_i( WB_RST ),
	.wb_cyc_i( WB_CYC ),
	.wb_adr_i( cpu_addr[7:0] ),
	.wb_dat_i( cpu_data_out ),
	.wb_sel_i( WB_SEL ),
	.wb_we_i( WB_WE ),
	.wb_stb_i( slave_select[1] ),
	.wb_dat_o( gpio_data_o ),
	.wb_ack_o( gpio_ack ),
	.wb_err_o( gpio_err ),
	.wb_inta_o( gpio_inta ),

	// External GPIO Interface
	.ext_pad_i('d0),
	.ext_pad_o(gpio_ext_pad_output),
	.ext_padoe_o(gpio_ext_pad_oe)
);

// Program memory
always @(*) begin
	case( { cpu_addr[31:0] }  )
`include "../src/gpio.v"
		default: mem_data_o[31:0] = 32'hX;
	endcase
end



reg [20:0] counter = 0;
assign cpu_clk = counter[20];
always @(posedge clk_50mhz) begin
	if( reset ) begin
		counter <= 0;
	end else begin
		counter <= counter + 'd1;
	end
end

endmodule
