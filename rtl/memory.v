`timescale 1ns / 1ps

module memory(
		CLK_I,
		RST_I,
		
		DAT_I,
		DAT_O,
		ADR_I,
		ACK_O,
		CYC_I,
		STB_I,
		SEL_I,
		ERR_O,
		WE_I
    );
	
	parameter WIDTH = 8;

	input CLK_I;
	input RST_I;

	input  [31:0] DAT_I;
	output [31:0] DAT_O;
	input [WIDTH-1:0] ADR_I;
	output ACK_O;
	input CYC_I;
	input STB_I;
	input [3:0] SEL_I;
	output ERR_O;
	input WE_I;

	wire [WIDTH-3:0] mem_addr = ADR_I[WIDTH-1:2];

	reg [7:0] memb0[2**(WIDTH-2)-1:0];
	reg [7:0] memb1[2**(WIDTH-2)-1:0];
	reg [7:0] memb2[2**(WIDTH-2)-1:0];
	reg [7:0] memb3[2**(WIDTH-2)-1:0];

	assign DAT_O[31:24] = SEL_I[3] ? memb3[mem_addr][7:0] : 8'hX;
	assign DAT_O[23:16] = SEL_I[2] ? memb2[mem_addr][7:0] : 8'hX;
	assign DAT_O[15:8]  = SEL_I[1] ? memb1[mem_addr][7:0] : 8'hX;
	assign DAT_O[7:0]   = SEL_I[0] ? memb0[mem_addr][7:0] : 8'hX;

	wire addr_valid = mem_addr < 2**(WIDTH-2);

	assign ACK_O = addr_valid && STB_I;
	
	assign ERR_O = ~addr_valid && STB_I;
	
	always @(ERR_O) begin
		if( ERR_O ) $stop; // Bus error!
	end


	wire do_write = addr_valid && STB_I && WE_I;

	always @(posedge CLK_I) begin
		if( do_write && SEL_I[3] ) begin
			memb3[ mem_addr ][7:0] <= DAT_I[31:24];
		end
	end
	always @(posedge CLK_I) begin
		if( do_write && SEL_I[2] ) begin
			memb2[ mem_addr ][7:0] <= DAT_I[23:16];
		end
	end
	always @(posedge CLK_I) begin
		if( do_write && SEL_I[1] ) begin
			memb1[ mem_addr ][7:0] <= DAT_I[15:8];
		end
	end
	always @(posedge CLK_I) begin
		if( do_write && SEL_I[0] ) begin
			memb0[ mem_addr ][7:0] <= DAT_I[7:0];
		end
	end



endmodule
