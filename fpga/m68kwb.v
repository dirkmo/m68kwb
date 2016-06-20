module m68kwb(
   input clk_50mhz, 
   input reset_n, 
		
   output [7:0] leds
);


top inst(
   .clk_50mhz( clk_50mhz ),
   .reset(~reset_n), 
   .uart_tx(),
   .uart_rx(1'b1), 
		
   .leds(leds)
);


endmodule
