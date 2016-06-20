// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module TG68_wb(
	input CLK_I,
	input RST_I,
	
	input  [31:0] DAT_I,
	output [31:0] DAT_O,
	output [31:2] ADR_O,
	input ACK_I,
	output CYC_O,
	output STB_O,
	output [3:0] SEL_O,
	input ERR_I,
	output wire WE_O,

	input [2:0] ipl_i, // high active!
	input cpu_clk
);

//address <= TG68_PC when state="00" else X"ffffffff" when state="01" else memaddr;
//LDS <= '0' WHEN (datatype/="00" OR state="00" OR memaddr(0)='1') AND state/="01" ELSE '1';
//UDS <= '0' WHEN (datatype/="00" OR state="00" OR memaddr(0)='0') AND state/="01" ELSE '1';
//state_out <= state;
//wr <= '0' WHEN state="11" ELSE '1';
//state <= "01";		--decode cycle, execute cycle

wire [31:0] cpu_addr;
wire [15:0] cpu_data_out;
wire [1:0] state_out;
wire cpu_clk_en = (state_out[1:0] == 2'b01) ? 1 : ACK_I;
wire uds_n;
wire lds_n;
wire wr_n;
assign CYC_O = SEL_O != 'd0;
assign STB_O = CYC_O;
wire decodeOPC;

// 68k Speicherorganisation:
//
// 68k-Adr		Byte				ds		WB-Adr	WB-Sel
// 0			B3 (MSB High Word)	lds		0		Sel=4'b1000
// 1			B2 (LSB High Word)	uds		0		Sel=4'b0100
// 2			B1 (MSB Low Word)	lds		0		Sel=4'b0010
// 3			B0 (LSB Low Word)	uds		0		Sel=4'b0001

assign SEL_O[3:2] = cpu_addr[1]==1'b0 ? { ~lds_n, ~uds_n } : 2'b00;
assign SEL_O[1:0] = cpu_addr[1]==1'b1 ? { ~lds_n, ~uds_n } : 2'b00;

wire [15:0] cpu_data_in =
				cpu_addr[1] == 1'b1 ? DAT_I[15:0] : DAT_I[31:16];

assign DAT_O[15:0] = cpu_addr[1] == 1'b1 ? cpu_data_out[15:0] : 16'hX;
assign DAT_O[31:16] = cpu_addr[1] == 1'b0 ? cpu_data_out[15:0] : 16'hX;
assign ADR_O = cpu_addr[31:2];
assign WE_O = ~wr_n;

TG68_fast cpu (
	.clk( cpu_clk ), 
	.reset( ~RST_I ), 
	.clkena_in( cpu_clk_en ), 
	.data_in( cpu_data_in ), 
	.IPL( ~ipl_i ), 
	.address( cpu_addr ), 
	.data_write( cpu_data_out ), 
	.state_out( state_out ),
	.UDS( uds_n ), 
	.LDS( lds_n ), 
	.wr( wr_n ),
	.decodeOPC( decodeOPC )
);



endmodule
