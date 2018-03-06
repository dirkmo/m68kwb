`include "../rtl/timescale.v"

module bench();

reg clk_50mhz = 0;
reg reset = 1;

reg bootswitch = 1;

wire [7:0] gpio;
wire uart_tx;

wire [31:0] dat_sram_to_cpu;
wire sram_oen;
wire sram_wen;
wire [17:0] sram_addr;
wire [15:0] sram0_data;
wire [15:0] sram1_data;

assign sram0_data[15:0] = sram_wen ? dat_sram_to_cpu[15:0] : 16'bZ;
assign sram1_data[15:0] = sram_wen ? dat_sram_to_cpu[31:16] : 16'bZ;

always #10 clk_50mhz = ~clk_50mhz;

sram256_16 sram0 (
    .clk_i(clk_50mhz),
    .sram_dat_i(sram0_data), 
    .sram_dat_o(dat_sram_to_cpu[15:0]), 
    .sram_noe_i(sram_oen), 
    .sram_nwe_i(sram_wen), 
    .sram_ncs_i(sram0_cen), 
    .sram_addr_i(sram_addr), 
    .sram_bsel_i( {~sram0_ubn, ~sram0_lbn})
);

sram256_16 sram1 (
    .clk_i(clk_50mhz),
    .sram_dat_i(sram1_data), 
    .sram_dat_o(dat_sram_to_cpu[31:16]), 
    .sram_noe_i(sram_oen), 
    .sram_nwe_i(sram_wen), 
    .sram_ncs_i(sram1_cen), 
    .sram_addr_i(sram_addr), 
    .sram_bsel_i( {~sram1_ubn, ~sram1_lbn})
);


spartan3_top uut(
    .clk_50mhz(clk_50mhz),
    .reset(reset),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    
    .leds(gpio[7:0]),
    .bootswitch(bootswitch),
    
    .sram_addr(sram_addr),
    
    .sram0_data(sram0_data),
    .sram0_cen(sram0_cen),
    .sram0_ubn(sram0_ubn),
    .sram0_lbn(sram0_lbn),

    .sram1_data(sram1_data),
    .sram1_cen(sram1_cen),
    .sram1_ubn(sram1_ubn),
    .sram1_lbn(sram1_lbn),    
    
    .sram_oen(sram_oen),
    .sram_wen(sram_wen),
    
    .sdspi_cs_n(sdspi_cs_n),
    .sdspi_sck(sdspi_sck),
    .sdspi_mosi(sdspi_mosi),
    .sdspi_miso(sdspi_miso)
);

initial begin
	reset = 1;
	#100;
	reset = 0;
	#4000;
	$stop;
end


endmodule
