`include "../rtl/timescale.v"

module bootctrl(
    input wb_clk_i,
    input [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    input [3:0] wb_sel_i,
    output wb_ack_o,
    input wb_cyc_i,
    input wb_stb_i,
    input wb_rst_i,
    input wb_we_i,
    
    output cpu_reset_o,
    output [1:0] mode_o,
    input switch_i
);

// byte addr 0: ctrl reg
// bitfields
// bit 0: writing a 1 will reset the cpu, reads always as 0
// bit 1: RAM_ENABLE. If 0: RAM is masked by ROM. 1: RAM is visible
// bit 2: BOOT_SEL. If 0: ROM is bootstrap code. 1: ROM is bootloader code.
`define RESET 0
`define RAM_ENABLE 1
`define BOOT_SEL 2

reg [2:1] ctrl;
reg reset;
assign cpu_reset_o = wb_rst_i || reset;


always @(posedge wb_clk_i)
begin
	 reset <= 1'b0;
    if( wb_rst_i ) begin
        ctrl[`BOOT_SEL] <= switch_i;
        ctrl[`RAM_ENABLE] <= 1'b0;
    end else begin
        if(wb_stb_i && wb_we_i) begin
            if( wb_sel_i == 4'b1000 ) begin
                ctrl <= wb_dat_i[26:25];
                reset <= wb_dat_i[24];
            end
        end
    end
end

assign mode_o[1:0] = ctrl[`RAM_ENABLE] ? `MODE_RAM :
                     ctrl[`BOOT_SEL]   ? `MODE_BOOTLOADER :
                                         `MODE_BOOTSTRAP;

assign wb_dat_o[23:0]  = 16'h0;
assign wb_dat_o[31:24] = { 5'b0, ctrl[2:1], 1'b0 };
assign wb_ack_o = 1'b1;

endmodule
