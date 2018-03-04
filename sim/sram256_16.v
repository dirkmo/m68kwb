`include "../rtl/timescale.v"

// sram simulation module, 256k x 16bit
module sram256_16(
    input clk_i,
    input  [15:0] sram_dat_i,
    output [15:0] sram_dat_o,
    input sram_noe_i,
    input sram_nwe_i,
    input sram_ncs_i,
    input [AB_WIDTH-1:0] sram_addr_i,
    input [1:0] sram_bsel_i
);

    parameter AB_WIDTH = 18;
    
    wire sram_cs = ~sram_ncs_i;
    wire sram_we = sram_cs && ~sram_nwe_i;
    wire sram_oe = sram_cs && ~sram_noe_i;

    reg [7:0] memb0[2**AB_WIDTH-1:0];
    reg [7:0] memb1[2**AB_WIDTH-1:0];

	assign sram_dat_o[15:8]  = (sram_oe && sram_bsel_i[1]) ? memb1[sram_addr_i] : 8'hX;
	assign sram_dat_o[7:0]   = (sram_oe && sram_bsel_i[0]) ? memb0[sram_addr_i] : 8'hX;

	wire addr_valid = sram_addr_i < 2**AB_WIDTH;

	assign ACK_O = addr_valid && sram_cs;
	assign ERR_O = ~addr_valid && sram_cs;
	
	always @(ERR_O) begin
		if( ERR_O ) $stop; // Bus error!
	end

	wire do_write = addr_valid && sram_cs && sram_we;

	always @(posedge clk_i) begin
		if( do_write && sram_bsel_i[1] ) begin
			memb1[ sram_addr_i ] <= sram_dat_i[15:8];
			$display("memb1[%X] <= %02X", sram_addr_i, sram_dat_i[15:8]);
		end
	end
	always @(posedge clk_i) begin
		if( do_write && sram_bsel_i[0] ) begin
			memb0[ sram_addr_i ] <= sram_dat_i[7:0];
			$display("memb0[%X] <= %02X", sram_addr_i, sram_dat_i[7:0]);
		end
	end

endmodule
