`include "../rtl/timescale.v"

module bench();

reg clk50mhz = 0;
reg reset = 0;

wire [7:0] gpio;
wire uart_tx;

wire [31:0] dat_cpu_to_sram;
wire [31:0] dat_sram_to_cpu;
wire sram_noe_o;
wire sram_nwe_o;
wire sram_ncs_o;
wire [17:0] sram_addr;
wire [3:0] sram_bsel;

always #10 clk50mhz = ~clk50mhz;

sram256_32 sram (
    .clk_i(clk50mhz),
    .sram_dat_i(dat_cpu_to_sram), 
    .sram_dat_o(dat_sram_to_cpu), 
    .sram_noe_i(sram_noe), 
    .sram_nwe_i(sram_nwe), 
    .sram_ncs_i(sram_ncs), 
    .sram_addr_i(sram_addr), 
    .sram_bsel_i(sram_bsel)
    );

top uut(
    .clk_50mhz(clk50mhz),
    .reset(reset),
    .sram_dat_i(dat_sram_to_cpu),
	.sram_dat_o(dat_cpu_to_sram),
	.sram_noe_o(sram_noe),
	.sram_nwe_o(sram_nwe),
	.sram_ncs_o(sram_ncs),
	.sram_addr_o(sram_addr),
	.sram_bsel_o(sram_bsel),
    
   .uart_tx(uart_tx),
   .uart_rx(uart_tx),

   .leds(gpio[7:0])
);

initial begin
	reset = 1;
	#100;
	reset = 0;
	#2000;
	
	//uut.test_int = 1;

	#2000;
	$stop;
end


endmodule
