module sram_if(
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
    sram_addr_o,
    sram_bsel_o,
    sram_oe_o,
    sram_we_o,
    sram_cs_o
);

parameter AWIDTH = 20; // byte address (although the 2 lower bits are not used)
parameter WAIT_STATES = 1;

input wb_clk_i;
input [31:0] wb_dat_i;
output [31:0] wb_dat_o;
input [AWIDTH-1:0] wb_addr_i;
input [3:0] wb_sel_i;
output wb_ack_o;
input wb_cyc_i;
input wb_stb_i;
input wb_rst_i;
input wb_we_i;

input [31:0] sram_dat_i;
output [31:0] sram_dat_o;
output [AWIDTH-3:0] sram_addr_o;
output [3:0] sram_bsel_o;
output wire sram_oe_o;
output wire sram_we_o;
output wire sram_cs_o;

wire sram_cs = wb_cyc_i && wb_stb_i;
wire sram_we =  sram_cs && wb_we_i;
wire sram_oe =  sram_cs && ~wb_we_i;

assign sram_oe_o = sram_oe;
assign sram_we_o = sram_we;
assign sram_cs_o = sram_cs;
assign sram_bsel_o[3:0] = sram_cs ? wb_sel_i[3:0] : 4'b0000;
assign sram_addr_o[AWIDTH-3:0] = wb_addr_i[AWIDTH-1:2];


assign wb_dat_o[31:24] = sram_oe && wb_sel_i[3] ? sram_dat_i[31:24] : 'hX;
assign wb_dat_o[23:16] = sram_oe && wb_sel_i[2] ? sram_dat_i[23:16] : 'hX;
assign wb_dat_o[15:8]  = sram_oe && wb_sel_i[1] ? sram_dat_i[15:8] : 'hX;
assign wb_dat_o[7:0]   = sram_oe && wb_sel_i[0] ? sram_dat_i[7:0] : 'hX;

assign sram_dat_o[31:24] = sram_we && wb_sel_i[3] ? wb_dat_i[31:24] : 'hX;
assign sram_dat_o[23:16] = sram_we && wb_sel_i[2] ? wb_dat_i[23:16] : 'hX;
assign sram_dat_o[15:8]  = sram_we && wb_sel_i[1] ? wb_dat_i[15:8] : 'hX;
assign sram_dat_o[7:0]   = sram_we && wb_sel_i[0] ? wb_dat_i[7:0] : 'hX;

// wait states generator, counts up to WAIT_STATES
reg [1:0] counter;
wire wait_complete = (counter == WAIT_STATES);

always @(posedge wb_clk_i)
begin
    if( wb_rst_i ) begin
        counter <= 0;
    end else begin
        if( wb_stb_i ) begin
            if( ~wait_complete ) begin
                counter <= counter + 'b1;
            end
        end else begin
            counter <= 0;
        end
    end
end

assign wb_ack_o = wait_complete;

endmodule
