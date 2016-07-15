module m68kwb(
   input clk_50mhz, 
   input reset_n, 
		
   output uart_tx,
	input uart_rx
);


top inst(
   .clk_50mhz( clk_50mhz ),
   .reset(~reset_n), 
   .uart_tx(uart_tx),
   .uart_rx(uart_rx), 
		
   .leds()
);


endmodule
