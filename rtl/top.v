// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module top(
	input clk_50mhz, 
	input reset,

	input wire [31:0] sram_dat_i,
	output wire [31:0] sram_dat_o,
	output sram_noe_o,
	output sram_nwe_o,
	output sram_ncs_o,
	output [17:0] sram_addr_o,
	output [3:0] sram_bsel_o,

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
wire WB_ACK;
wire [3:0] WB_SEL; // data selects

wire cpu_clk;
wire [31:0] cpu_addr;
wire [31:0] cpu_data_out;
wire [31:0] cpu_data_in;
wire  [2:0] ipl;

wire gpio_ack;
wire gpio_err;
wire gpio_inta;
wire [31:0] gpio_data_o;
wire [7:0] gpio_ext_pad_output;
wire [7:0] gpio_ext_pad_oe;

assign leds[7:0] = gpio_ext_pad_output[7:0];

wire [31:0] uart_data_o;
wire uart_ack;
wire uart_int;

wire [31:0] ram_data_o;
wire mem_ack;

wire [15:0] timer1_data_o;
wire timer1_ack;
wire timer1_int;

wire [4:0] slave_select;
wire [4:0] slave_ack;

reg  [31:0] rom_data_o;
wire [31:0] rom = rom_data_o[31:0];


assign WB_ACK = slave_ack != 'd0;

assign cpu_data_in[31:0] =
	slave_select == 'h1  ? rom[31:0] :
	slave_select == 'h2  ? ram_data_o[31:0] :
	slave_select == 'h4  ? gpio_data_o[31:0] :
	slave_select == 'h8  ? uart_data_o[31:0] :
	slave_select == 'h10 ? { 16'h0000, timer1_data_o[15:0] } :
	'dX;

wire     rom_sel = slave_select[0];
wire     ram_sel = slave_select[1];
wire    gpio_sel = slave_select[2];
wire    uart_sel = slave_select[3];
wire  timer1_sel = slave_select[4];

assign slave_ack = {
	 timer1_sel & timer1_ack,
	   uart_sel & uart_ack,
	   gpio_sel & gpio_ack,
	    ram_sel & mem_ack,
	    rom_sel /*rom always ack*/
};


TG68_wb cpu(
	.CLK_I( WB_CLK ),
	.RST_I( WB_RST ),
	
	.DAT_I( cpu_data_in ),
	.DAT_O( cpu_data_out ),
	.ADR_O( cpu_addr[31:0] ),
	.ACK_I( WB_ACK ),
	.CYC_O( WB_CYC ),
	.STB_O( WB_STB ),
	.SEL_O( WB_SEL ),
	.ERR_I( 1'b0 ),
	.WE_O( WB_WE ),

	.ipl_i( ipl[2:0] ),
	.cpu_clk(cpu_clk)
);

SYSCON #(.SLAVES(5)) syscon(
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
	.wb_adr_i( { cpu_addr[7:2], 2'b0 } ),
	.wb_dat_i( cpu_data_out ),
	.wb_sel_i( WB_SEL ),
	.wb_we_i( WB_WE ),
	.wb_stb_i( gpio_sel ),
	.wb_dat_o( gpio_data_o ),
	.wb_ack_o( gpio_ack ),
	.wb_err_o( gpio_err ),
	.wb_inta_o( gpio_inta ),

	// External GPIO Interface
	.ext_pad_i( 8'd0 ),
	.ext_pad_o( gpio_ext_pad_output ),
	.ext_padoe_o( gpio_ext_pad_oe )
);

uart_top uart(
	.wb_clk_i( WB_CLK ), 
	
	// Wishbone signals
	.wb_rst_i( WB_RST ),
	.wb_adr_i( cpu_addr[4:0] ),
	.wb_dat_i( cpu_data_out ),
	.wb_dat_o( uart_data_o ),
	.wb_we_i( WB_WE),
	.wb_stb_i( uart_sel ),
	.wb_cyc_i( WB_CYC ),
	.wb_ack_o( uart_ack ),
	.wb_sel_i( WB_SEL ),
	.int_o(uart_int), // interrupt request

	// UART	signals
	// serial input/output
	.stx_pad_o(uart_tx),
	.srx_pad_i(uart_rx),

	// modem signals
	.rts_pad_o(),
	.cts_pad_i(1'b0),
	.dtr_pad_o(),
	.dsr_pad_i(1'b0),
	.ri_pad_i(1'b0),
	.dcd_pad_i(1'b0)
);

/*
`define MEMORY_ADDR_WIDTH 4

memory #(.WIDTH(`MEMORY_ADDR_WIDTH)) mem0 (
	.CLK_I( WB_CLK ),
	.RST_I( WB_RST ),
	.DAT_I( cpu_data_out ),
	.DAT_O( ram_data_o ),
	.ADR_I( cpu_addr[`MEMORY_ADDR_WIDTH-1:0] ),
	.ACK_O( mem_ack ),
	.CYC_I( WB_CYC ),
	.STB_I( ram_sel ),
	.SEL_I( WB_SEL ),
	.ERR_O(),
	.WE_I( WB_WE )
);
*/

sram_if ram(
    .wb_clk_i(WB_CLK),
    .wb_dat_i(cpu_data_out),
    .wb_dat_o(ram_data_o),
    .wb_addr_i( cpu_addr[19:0] ),
    .wb_ack_o(mem_ack),
    .wb_sel_i(WB_SEL),
    .wb_cyc_i(ram_sel),
    .wb_stb_i(ram_sel),
    .wb_rst_i(WB_RST),
    .wb_we_i(WB_WE),
    
	//.sram_clk(), hier noch clk für sram Zugriffe
    .sram_dat_i(sram_dat_i),
    .sram_dat_o(sram_dat_o),
    .sram_noe_o(sram_noe_o),
    .sram_nwe_o(sram_nwe_o),
    .sram_ncs_o(sram_ncs_o),
    .sram_addr_o(sram_addr_o),
    .sram_bsel_o(sram_bsel_o)
);



interrupt_controller intctrl(
	.wb_clk_i(WB_CLK),
	.wb_reset_i(WB_RST),
	.int_i( { 4'b0000, timer1_int, uart_int, gpio_inta }),
	.ipl(ipl[2:0])
);

wire [2:0] timer_addr =
				(cpu_addr[2] == 1'b0) && WB_SEL[3] && WB_SEL[2] ? 3'b000 :
				(cpu_addr[2] == 1'b0) && WB_SEL[1] && WB_SEL[0] ? 3'b001 :
				(cpu_addr[2] == 1'b1) && WB_SEL[3] && WB_SEL[2] ? 3'b010 :
				3'b111;

wire [15:0] timer_data_in = WB_SEL[3] && WB_SEL[2] ? cpu_data_out[31:16] : cpu_data_out[15:0];

pit_top timer1 (
    .wb_dat_o(timer1_data_o[15:0]),
    .wb_ack_o(timer1_ack),
    .wb_clk_i(WB_CLK),
    .wb_rst_i(WB_RST),
    .arst_i(1'b1),
    .wb_adr_i(timer_addr[2:0]),
    .wb_dat_i( timer_data_in[15:0] ),
    .wb_we_i(WB_WE),
    .wb_stb_i(timer1_sel),
    .wb_cyc_i(WB_CYC),
    .wb_sel_i(2'b11),
    .pit_o(),
    .pit_irq_o(timer1_int),
    .cnt_flag_o(),
    .cnt_sync_o(),
    .ext_sync_i(1'b0)
);


// Program memory
always @(*) begin
	case( { cpu_addr[31:0] }  )
`include "src/timer.v"
		default: rom_data_o[31:0] = 32'h0;
	endcase
end

assign cpu_clk = clk_50mhz;

endmodule
