`include "../rtl/timescale.v"

module memory(
    wb_clk_i,
    wb_dat_i,
    wb_dat_o,
    wb_addr_i,
    wb_sel_i,
    wb_ack_o,
    wb_cyc_i,
    wb_stb_i,
    wb_rst_i,
    wb_we_i,
    
    sram_dat_i,
	sram_dat_o,
	sram_oe_o,
	sram_we_o,
	sram_cs_o,
	sram_addr_o,
	sram_bsel_o,
    
    mode
);

input wb_clk_i;
input [31:0] wb_dat_i;
output [31:0] wb_dat_o;
input [31:0] wb_addr_i;
input [3:0] wb_sel_i;
output wb_ack_o;
input wb_cyc_i;
input wb_stb_i;
input wb_rst_i;
input wb_we_i;

input [31:0] sram_dat_i;
output [31:0] sram_dat_o;
output sram_oe_o;
output sram_we_o;
output sram_cs_o;
output [17:0] sram_addr_o;
output [3:0] sram_bsel_o;

input [1:0] mode;

reg bootstrap_addr_valid;
reg bootloader_addr_valid;

reg  [31:0] bootstrap_data_o;
reg  [31:0] bootloader_data_o;
wire [31:0] ram_data_o;

wire sram_ack;
assign wb_ack_o = (mode == `MODE_RAM) ? sram_ack : 1'b1; // TODO: schreiben berücksichtigen

assign wb_dat_o =
             (mode == `MODE_BOOTSTRAP)  &&  bootstrap_addr_valid ? bootstrap_data_o :
             (mode == `MODE_BOOTLOADER) && bootloader_addr_valid ? bootloader_data_o :
                                                                   ram_data_o;

always @(*) begin
    bootstrap_addr_valid = 1'b1;
    bootstrap_data_o[31:0] = 32'hX;
    case( { wb_addr_i[31:0] }  )
`include "src/bootstrap.v"
        default: begin
            bootstrap_data_o[31:0] = 32'hX;
            bootstrap_addr_valid = 1'b0;
        end
    endcase
end

always @(*) begin
    bootloader_addr_valid = 1'b1;
    bootloader_data_o[31:0] = 32'hX;
    case( { wb_addr_i[31:0] }  )
`include "src/bootloader.v"
        default: begin
            bootloader_data_o[31:0] = 32'hX;
            bootloader_addr_valid = 1'b0;
        end
    endcase
end

sram_if ram(
    .wb_clk_i( wb_clk_i ),
    .wb_dat_i( wb_dat_i ),
    .wb_dat_o( ram_data_o ),
    .wb_addr_i( wb_addr_i[19:0] ),
    .wb_ack_o( sram_ack ),
    .wb_sel_i( wb_sel_i) ,
    .wb_cyc_i( wb_cyc_i ),
    .wb_stb_i( wb_stb_i ),
    .wb_rst_i( wb_rst_i ),
    .wb_we_i( wb_we_i ),
    
	//.sram_clk(), hier noch clk für sram Zugriffe
    .sram_dat_i( sram_dat_i ),
    .sram_dat_o( sram_dat_o ),
    .sram_oe_o( sram_oe_o ),
    .sram_we_o( sram_we_o ),
    .sram_cs_o( sram_cs_o ),
    .sram_addr_o( sram_addr_o ),
    .sram_bsel_o( sram_bsel_o )
);

endmodule
