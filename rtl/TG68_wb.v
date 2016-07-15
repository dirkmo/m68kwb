// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module TG68_wb(
	input CLK_I,
	input RST_I,
	
	input  [31:0] DAT_I,
	output [31:0] DAT_O,
	output [31:0] ADR_O,
	input ACK_I,
	output CYC_O,
	output STB_O,
	output [3:0] SEL_O,
	input ERR_I,
	output wire WE_O,

	input [2:0] ipl_i, // high active!
	input cpu_clk
);

wire [31:0] cpu_addr;
wire [15:0] cpu_data_out;
wire [1:0] state_out;
wire cpu_clk_en = (state_out[1:0] == 2'b01) ? 1 : ACK_I;
wire uds_n, uds;
wire lds_n, lds;
wire wr_n;
assign uds = ~uds_n;
assign lds = ~lds_n;
assign CYC_O = uds || lds;
assign STB_O = CYC_O;
wire decodeOPC;
wire [15:0] cpu_data_in;

// 68k Speicherorganisation: (68k ist big endian)
//
// 68k Signale						
// Adresse	Byte			ds
// --------------------------------
// 0		MSB High Word	uds
// 1		LSB High Word	lds
// 2		MSB  Low Word	uds
// 3		LSB  Low Word	lds

// Wishbone Datenorganisation
// --------------------------------
// DAT[]	31:24		23:16		15:8		7:0
// SEL[]	3			2			1			0
// Big		B0			B1			B2			B3   ; B0 = Byte von Adresse 0
// Little	B3			B2			B1			B0


`ifdef LITTLE_ENDIAN
// funktioniert nicht richtig
Fehler
// Little Endian
// DAT[]	31:24		23:16		15:8		7:0
// SEL[]	4'b1000		4'b0100		4'b0010		4'b0001
// Adresse	3			2			1			0
// cpudata	[7:0]		[15:8]		[7:0]		[15:8]
// ds		lds			uds			lds			uds

assign cpu_data_in[15:8] = (cpu_addr[1] == 1'b1) ? DAT_I[23:16] : DAT_I[7:0];
assign cpu_data_in[7:0]  = (cpu_addr[1] == 1'b1) ? DAT_I[31:24] : DAT_I[15:8];

assign DAT_O[31:24] = cpu_addr[1] == 1'b1 ? cpu_data_out[7:0]  : 16'hX;
assign DAT_O[23:16] = cpu_addr[1] == 1'b1 ? cpu_data_out[15:8] : 16'hX;
assign DAT_O[15:8]  = cpu_addr[1] == 1'b0 ? cpu_data_out[7:0]  : 16'hX;
assign DAT_O[7:0]   = cpu_addr[1] == 1'b0 ? cpu_data_out[15:8] : 16'hX;

assign SEL_O[3:2] = cpu_addr[1]==1'b1 ? { lds, uds } : 2'b00;
assign SEL_O[1:0] = cpu_addr[1]==1'b0 ? { lds, uds } : 2'b00;

`else
// Big Endian
// DAT[]	31:24		23:16		15:8		7:0
// SEL[]	4'b1000		4'b0100		4'b0010		4'b0001
// Adresse	0			1			2			3
// ds		uds			lds			uds			lds
// cpudata	[15:8]		[7:0]		[15:8]		[7:0]

assign cpu_data_in[15:8] = (cpu_addr[1] == 1'b1) ? DAT_I[15:8] : DAT_I[31:24];
assign cpu_data_in[7:0]  = (cpu_addr[1] == 1'b1) ? DAT_I[7:0] : DAT_I[23:16];

assign DAT_O[31:24] = cpu_addr[1] == 1'b0 ? cpu_data_out[15:8]  : 16'hX;
assign DAT_O[23:16] = cpu_addr[1] == 1'b0 ? cpu_data_out[7:0] : 16'hX;
assign DAT_O[15:8]  = cpu_addr[1] == 1'b1 ? cpu_data_out[15:8]  : 16'hX;
assign DAT_O[7:0]   = cpu_addr[1] == 1'b1 ? cpu_data_out[7:0] : 16'hX;

assign SEL_O[3:2] = cpu_addr[1]==1'b0 ? { uds, lds } : 2'b00;
assign SEL_O[1:0] = cpu_addr[1]==1'b1 ? { uds, lds } : 2'b00;

`endif


assign ADR_O = { cpu_addr[31:2], 2'b00 }; // 32 bit bus granuality
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
	.decodeOPC( decodeOPC ),
	.test_IPL(1'b0)
);

//address <= TG68_PC when state="00" else X"ffffffff" when state="01" else memaddr;
//LDS <= '0' WHEN (datatype/="00" OR state="00" OR memaddr(0)='1') AND state/="01" ELSE '1';
//UDS <= '0' WHEN (datatype/="00" OR state="00" OR memaddr(0)='0') AND state/="01" ELSE '1';
//state_out <= state;
//wr <= '0' WHEN state="11" ELSE '1';
//state <= "01";		--decode cycle, execute cycle

endmodule
