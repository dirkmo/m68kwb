`include "timescale.v"

module interrupt_controller(
	wb_clk_i,
	wb_reset_i,
	int_i,
	ipl
);

input  wb_clk_i;
input  wb_reset_i;
input [6:0] int_i;
output [2:0] ipl;

reg [2:0] ipl_r;

reg [6:0] int_r;

wire [6:0] int_on = (~int_r) & int_i;
wire [6:0] int_of = ((int_r) & (~int_i));

wire pos_edge_trigger = int_on != 'h0;
wire neg_edge_trigger = int_of != 'h0;

initial
begin
	ipl_r = 'h0;
	int_r = 'h0;
end

always @(posedge wb_clk_i)
begin
	if( wb_reset_i )
	begin
		int_r <= 'h0;
	end else begin
		int_r <= int_i;
	end
end

always @(posedge wb_clk_i)
begin
	if( wb_reset_i )
	begin
		ipl_r = 'h0;
	end else begin
		if( int_r[6] ) begin
			ipl_r = 3'h7;
		end else if( int_r[5]) begin
			ipl_r = 3'h6;
		end else if( int_r[4]) begin
			ipl_r = 3'h5;
		end else if( int_r[3]) begin
			ipl_r = 3'h4;
		end else if( int_r[2]) begin
			ipl_r = 3'h3;
		end else if( int_r[1]) begin
			ipl_r = 3'h2;
		end else if( int_r[0]) begin
			ipl_r = 3'h1;
		end
	end
end


assign ipl = ipl_r;

endmodule
