`include "../rtl/timescale.v"

module m68k_computer(
	input clk_50mhz, 
	input reset,

	input [31:0] sram_dat_i,
	output [31:0] sram_dat_o,
	output sram_oe_o,
	output sram_we_o,
	output sram_cs_o,
	output [17:0] sram_addr_o,
	output [3:0] sram_bsel_o,

	output uart_tx, 
	input uart_rx, 

	output [7:0] leds,
    input bootswitch,
    
    output sdspi_cs_n,
    output sdspi_sck,
    output sdspi_mosi,
    input sdspi_miso
);

localparam SLAVES=7;

wire WB_CYC;
wire WB_CLK;
wire WB_RST;
wire WB_STB;
wire WB_WE;
wire WB_ERR;
wire WB_ACK;
wire [3:0] WB_SEL;

wire cpu_clk;
wire cpu_reset;
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

wire [15:0] timer1_data_o;
wire [15:0] timer2_data_o;
wire timer1_ack;
wire timer2_ack;
wire timer1_int;
wire timer2_int;
wire sdspi_int;

wire [31:0] bootctrl_data_o;
wire bootctrl_ack;

wire [31:0] mem_data_o;
wire mem_ack;

wire [31:0] sdspi_data_o;
wire sdspi_ack;

wire [SLAVES-1:0] slave_select;
wire [SLAVES-1:0] slave_ack;
assign WB_ACK = slave_ack != 'd0;
    


assign cpu_data_in[31:0] =
	slave_select == 'h1  ? mem_data_o[31:0] :
	slave_select == 'h2  ? bootctrl_data_o[31:0] :
	slave_select == 'h4  ? gpio_data_o[31:0] :
    slave_select == 'h8  ? uart_data_o[31:0] :
	slave_select == 'h10 ? { 16'h0000, timer1_data_o[15:0] } :
    slave_select == 'h20 ? { 16'h0000, timer2_data_o[15:0] } :
    slave_select == 'h40 ? sdspi_data_o[31:0] :
	'dX;

wire      mem_sel = slave_select[0];
wire bootctrl_sel = slave_select[1];
wire     gpio_sel = slave_select[2];
wire     uart_sel = slave_select[3];
wire   timer1_sel = slave_select[4];
wire   timer2_sel = slave_select[5];
wire    sdspi_sel = slave_select[6];

assign slave_ack = {
      sdspi_sel & sdspi_sel,
     timer2_sel & timer1_ack,
	 timer1_sel & timer1_ack,
	   uart_sel & uart_ack,
	   gpio_sel & gpio_ack,
   bootctrl_sel & bootctrl_ack,
	    mem_sel & mem_ack
};


TG68_wb cpu(
	.CLK_I( WB_CLK ),
	.RST_I( cpu_reset ),
	
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

SYSCON #(.SLAVES(SLAVES)) syscon(
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

interrupt_controller intctrl(
	.wb_clk_i(WB_CLK),
	.wb_reset_i(WB_RST),
	.int_i( { 3'b000, timer2_int, timer1_int, uart_int, gpio_inta }),
	.ipl(ipl[2:0])
);

//---------------------------------------
// Timers

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

pit_top timer2 (
    .wb_dat_o(timer2_data_o[15:0]),
    .wb_ack_o(timer2_ack),
    .wb_clk_i(WB_CLK),
    .wb_rst_i(WB_RST),
    .arst_i(1'b1),
    .wb_adr_i(timer_addr[2:0]),
    .wb_dat_i( timer_data_in[15:0] ),
    .wb_we_i(WB_WE),
    .wb_stb_i(timer2_sel),
    .wb_cyc_i(WB_CYC),
    .wb_sel_i(2'b11),
    .pit_o(),
    .pit_irq_o(timer2_int),
    .cnt_flag_o(),
    .cnt_sync_o(),
    .ext_sync_i(1'b0)
);

//---------------------------------------
// bootctrl

wire [1:0] mode;

bootctrl boot0(
    .wb_clk_i(WB_CLK),
    .wb_dat_i(cpu_data_out),
    .wb_dat_o(bootctrl_data_o),
    .wb_sel_i(WB_SEL),
    .wb_ack_o(bootctrl_ack),
    .wb_cyc_i(WB_CYC),
    .wb_stb_i(bootctrl_sel),
    .wb_rst_i(WB_RST),
    .wb_we_i(WB_WE),
    
    .cpu_reset_o(cpu_reset),
    .mode_o(mode),
    .switch_i(bootswitch)
);

//---------------------------------------
// Memory

memory mem0(
    .wb_clk_i(WB_CLK),
    .wb_dat_i(cpu_data_out),
    .wb_dat_o(mem_data_o),
    .wb_addr_i(cpu_addr[31:0]),
    .wb_sel_i(WB_SEL),
    .wb_ack_o(mem_ack),
    .wb_cyc_i(mem_sel),
    .wb_stb_i(mem_sel),
    .wb_rst_i(WB_RST),
    .wb_we_i(WB_WE),
    
    .sram_dat_i(sram_dat_i),
	.sram_dat_o(sram_dat_o),
	.sram_oe_o(sram_oe_o),
	.sram_we_o(sram_we_o),
	.sram_cs_o(sram_cs_o),
	.sram_addr_o(sram_addr_o),
	.sram_bsel_o(sram_bsel_o),
    
    .mode(mode)
);

//---------------------------------------
// SD SPI module

sdspi sdspi0 (
    .i_clk(WB_CLK), 
    .i_wb_cyc(sdspi_sel), 
    .i_wb_stb(sdspi_sel), 
    .i_wb_we(WB_WE), 
    .i_wb_addr(cpu_addr[3:2]), 
    .i_wb_data(cpu_data_out), 
    .o_wb_ack(sdspi_ack), 
    .o_wb_stall(), 
    .o_wb_data(sdspi_data_o), 
    .o_cs_n(sdspi_cs_n), 
    .o_sck(sdspi_sck), 
    .o_mosi(sdspi_mosi), 
    .i_miso(sdspi_miso), 
    .o_int(sdspi_int), 
    .i_bus_grant(1'b1), 
    .o_debug()
);

reg clk_25mhz = 0;
always @(posedge clk_50mhz) clk_25mhz <= ~clk_25mhz;

assign cpu_clk = clk_25mhz;

endmodule
