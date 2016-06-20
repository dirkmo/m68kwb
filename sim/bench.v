`include "../rtl/timescale.v"

module bench();

reg clk = 0;
reg reset = 0;

always #5 clk = ~clk;

top uut(
   .clk_50mhz(clk), 
   .reset(reset), 
   .uart_tx(), 
   .uart_rx(), 
		
   .leds()
);

initial begin
	reset = 1;
	#20;
	reset = 0;

	#200;
	$stop;

end


endmodule
