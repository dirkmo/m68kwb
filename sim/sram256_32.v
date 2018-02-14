`include "../rtl/timescale.v"

// sram simulation module, 256k x 32bit
module sram256_32(
    input clk_i,
    input  [31:0] sram_dat_i,
    output [31:0] sram_dat_o,
    input sram_noe_i,
    input sram_nwe_i,
    input sram_ncs_i,
    input [AB_WIDTH-1:0] sram_addr_i,
    input [3:0] sram_bsel_i
);

    parameter AB_WIDTH = 18;
    
    localparam DWIDTH = 32;

    wire sram_cs = ~sram_ncs_i;
    wire sram_we = sram_cs && ~sram_nwe_i;
    wire sram_oe = sram_cs && ~sram_noe_i;

    wire [AB_WIDTH-1:0] mem_addr = sram_addr_i[AB_WIDTH-1:0];

    reg [7:0] memb0[2**AB_WIDTH-1:0];
    reg [7:0] memb1[2**AB_WIDTH-1:0];
    reg [7:0] memb2[2**AB_WIDTH-1:0];
    reg [7:0] memb3[2**AB_WIDTH-1:0];
    
    assign sram_dat_o[31:24] = (sram_oe && sram_bsel_i[3]) ? memb3[mem_addr] : 8'hX;
	assign sram_dat_o[23:16] = (sram_oe && sram_bsel_i[2]) ? memb2[mem_addr] : 8'hX;
	assign sram_dat_o[15:8]  = (sram_oe && sram_bsel_i[1]) ? memb1[mem_addr] : 8'hX;
	assign sram_dat_o[7:0]   = (sram_oe && sram_bsel_i[0]) ? memb0[mem_addr] : 8'hX;

	wire addr_valid = mem_addr < 2**AB_WIDTH;

	assign ACK_O = addr_valid && sram_cs;
	
	assign ERR_O = ~addr_valid && sram_cs;
	
	always @(ERR_O) begin
		if( ERR_O ) $stop; // Bus error!
	end


	wire do_write = addr_valid && sram_cs && sram_we;

	always @(posedge clk_i) begin
		if( do_write && sram_bsel_i[3] ) begin
			memb3[ mem_addr ] <= sram_dat_i[31:24];
			$display("memb3[%X] <= %02X", mem_addr, sram_dat_i[31:24]);
		end
	end
	always @(posedge clk_i) begin
		if( do_write && sram_bsel_i[2] ) begin
			memb2[ mem_addr ] <= sram_dat_i[23:16];
			$display("memb2[%X] <= %02X", mem_addr, sram_dat_i[23:16]);
		end
	end
	always @(posedge clk_i) begin
		if( do_write && sram_bsel_i[1] ) begin
			memb1[ mem_addr ] <= sram_dat_i[15:8];
			$display("memb1[%X] <= %02X", mem_addr, sram_dat_i[15:8]);
		end
	end
	always @(posedge clk_i) begin
		if( do_write && sram_bsel_i[0] ) begin
			memb0[ mem_addr ] <= sram_dat_i[7:0];
			$display("memb0[%X] <= %02X", mem_addr, sram_dat_i[7:0]);
		end
	end

endmodule
