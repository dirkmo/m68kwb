`include "../rtl/timescale.v"

module bench();

reg clk50mhz = 0;
reg reset = 0;

wire [7:0] leds;
wire uart_tx;

always #10 clk50mhz = ~clk50mhz;

top uut(
   .clk_50mhz(clk50mhz),
   .reset(reset),

   .uart_tx(uart_tx),
   .uart_rx(uart_tx),

   .leds(leds)
);

initial begin
	reset = 1;
	#100;
	reset = 0;

	#5000;
	$stop;
end


endmodule
