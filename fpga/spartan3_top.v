`timescale 1ns / 10ps

module spartan3_top(
    clk_50mhz,
    reset,
    uart_rx, uart_tx,
    leds, bootswitch,
    
    sram_addr,
    sram0_data, sram0_cen, sram0_ubn, sram0_lbn,
    sram1_data, sram1_cen, sram1_ubn, sram1_lbn,    
    sram_oen, sram_wen,
    
    sdspi_cs_n, sdspi_sck, sdspi_mosi, sdspi_miso
);

input clk_50mhz;
input reset;
input uart_rx;
output uart_tx;
output [7:0] leds;
input bootswitch;

output [17:0] sram_addr;
inout [15:0] sram0_data;
output sram0_cen;
output sram0_ubn;
output sram0_lbn;

inout [15:0] sram1_data;
output sram1_cen;
output sram1_ubn;
output sram1_lbn;    

output sram_oen;
output sram_wen;

output sdspi_cs_n;
output sdspi_sck;
output sdspi_mosi;
input sdspi_miso;

wire [31:0] sram_dat_o;
wire sram_oe;
wire sram_we;
wire sram_cs;
wire [3:0] sram_bsel;

assign sram0_cen = ~(sram_cs && (sram_bsel[1:0] != 2'b00));
assign sram1_cen = ~(sram_cs && (sram_bsel[3:2] != 2'b00));

// SRAM1 15:8   B3  upper word upper byte
// SRAM1  7:0   B2  upper word lower byte
// SRAM0 15:8   B1  lower word upper byte
// SRAM0  7:0   B0  lower word lower byte

assign sram1_ubn = ~(sram_bsel[3] && sram_cs);
assign sram1_lbn = ~(sram_bsel[2] && sram_cs);
assign sram0_ubn = ~(sram_bsel[1] && sram_cs);
assign sram0_lbn = ~(sram_bsel[0] && sram_cs);

wire sram1_ub_we = sram_bsel[3] && sram_we;
wire sram1_lb_we = sram_bsel[2] && sram_we;
wire sram0_ub_we = sram_bsel[1] && sram_we;
wire sram0_lb_we = sram_bsel[0] && sram_we;

assign sram1_data[15:8] = sram1_ub_we ? sram_dat_o[31:24] : 8'bz;
assign sram1_data[ 7:0] = sram1_lb_we ? sram_dat_o[23:16] : 8'bz;
assign sram0_data[15:8] = sram0_ub_we ? sram_dat_o[15: 8] : 8'bz;
assign sram0_data[ 7:0] = sram0_lb_we ? sram_dat_o[ 7: 0] : 8'bz;

assign sram_oen = ~sram_oe;
assign sram_wen = ~sram_we;


m68k_computer m68kcomputer(
    .clk_50mhz(clk_50mhz),
	.reset(reset),

	.sram_dat_i( { sram1_data[15:0], sram0_data[15:0] } ),
	.sram_dat_o(sram_dat_o),
	.sram_oe_o(sram_oe),
	.sram_we_o(sram_we),
	.sram_cs_o(sram_cs),
	.sram_addr_o(sram_addr),
	.sram_bsel_o(sram_bsel),

	.uart_tx(uart_tx), 
	.uart_rx(uart_rx), 

	.leds(leds),
    .bootswitch(bootswitch),
    
    .sdspi_cs_n(sdspi_cs_n),
    .sdspi_sck(sdspi_sck),
    .sdspi_mosi(sdspi_mosi),
    .sdspi_miso(sdspi_miso)
);


endmodule
