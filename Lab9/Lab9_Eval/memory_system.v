`ifndef MEMORY_SYSTEM_V
`define MEMORY_SYSTEM_V

`include "ram32byte.v"
`include "rom32byte.v"

// ============================================================
//  8086 Memory System — 32 Byte RAM + 32 Byte ROM
// ============================================================
// Address map (20-bit byte-addressed, 1 MB total):
//
//   Device    | Byte Range           | A[19:5]
//   ----------|----------------------|-----------------
//   RAM 32B   | 0x00000 – 0x0001F   | 15'b000_0000_0000_0000
//   ROM 32B   | 0xFFFFE – 0xFFFFF   | 15'b111_1111_1111_1111
//
// Word address to RAM/ROM = A[4:1] 
//
// Bus signals (active-LOW from 8086):
//   RD_n   — LOW when CPU reads memory
//   WR_n   — LOW when CPU writes memory
//   M_IO_n — 0 = memory cycle, 1 = I/O cycle (memory ignores I/O)
// ============================================================
module memory_system(
    input        clk,
    input        reset,
    input [19:0] address,
    input [15:0] data_in,
    output [15:0] data_out,
    input        RD_n,
    input        WR_n,
    input        M_IO_n
);

    wire ram_cs;
    wire rom_cs;
    wire output_enable;
    wire write_enable;
    wire [15:0] ram_out;
    wire [15:0] rom_out;

    // ── Control signals (derived from active-low CPU strobes) ──────────────
    assign output_enable = ~RD_n;
    assign write_enable  = ~WR_n;

    // TODO 1: Generate ram_cs based on M_IO_n and address[19:5]
    // ram_cs is ram chip select 
    assign ram_cs = (M_IO_n == 1'b0 && address[19:5] == 15'd0) ? 1'b1 : 1'b0;

    // TODO 2: Generate rom_cs based on M_IO_n and address[19:5]
    // rom_cs is the rom chip select => select regardless of M_IO_n => select based on address 
    assign rom_cs = (address[19:5] == 15'b111_1111_1111_1111) ? 1'b1 : 1'b0;

    // TODO 3: Instantiate ram32byte
    ram32byte ram1(clk, ram_cs, reset, output_enable, write_enable, address[4:1], data_in, ram_out);

    // TODO 4: Instantiate rom32byte
    rom32byte rom1(output_enable, rom_cs, address[4:1], rom_out);

    // TODO 5: Drive data_out based on which device is selected, else high-impedance
    assign data_out = ((ram_cs == 1'b1) ? ram_out : ((rom_cs == 1'b1) ? rom_out : 16'bz));

endmodule

`endif
