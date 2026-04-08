`timescale 1ns/1ps
`include "memory_system.v"

// NOTE TO STUDENTS:
// ROM expected values assume rom32byte uses rom[k] = 0xAA00 + k + 1.
//
// Address map reminder:
//   RAM: byte addresses 0x00000 – 0x0001F  (A[19:5] = 15'b000_0000_0000_0000)
//   ROM: byte addresses 0xFFFE0 – 0xFFFFF  (A[19:5] = 15'b111_1111_1111_1111)
//   Internal word address to RAM/ROM = A[4:1]  (A[0] ignored)
module memory_system_tb;
    reg         clk, reset;
    reg  [19:0] address;
    reg  [15:0] data_in;
    wire [15:0] data_out;
    reg         RD_n, WR_n, M_IO_n;
    integer pass_count = 0, fail_count = 0;

    memory_system dut(.clk(clk), .reset(reset), .address(address),
                      .data_in(data_in), .data_out(data_out),
                      .RD_n(RD_n), .WR_n(WR_n), .M_IO_n(M_IO_n));

    initial clk = 0;
    always #10 clk = ~clk;

    // ------------ Bus cycle helpers ------------

    // Memory write cycle (active-low WR_n)
    task bus_write;
        input [19:0] addr;
        input [15:0] data;
        begin
            @(negedge clk);
            address = addr; data_in = data; M_IO_n = 0;
            WR_n = 0; RD_n = 1;
            @(posedge clk); #1;
            WR_n = 1;
        end
    endtask

    // Memory read cycle (active-low RD_n)
    task bus_read_check;
        input [19:0] addr;
        input [15:0] expected;
        input [7:0]  test_id;
        input [127:0] desc;
        begin
            @(negedge clk);
            address = addr; M_IO_n = 0;
            RD_n = 0; WR_n = 1;
            #5;
            if (data_out === expected) begin
                $display("  PASS [%0d] %0s: addr=%05h -> %04h", test_id, desc, addr, data_out);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%0d] %0s: addr=%05h -> expected %04h, got %04h",
                         test_id, desc, addr, expected, data_out);
                fail_count = fail_count + 1;
            end
            @(negedge clk);
            RD_n = 1;
        end
    endtask

    initial begin
        $dumpfile("outputs/memory_system_tb.vcd");
        $dumpvars(0, memory_system_tb);
        $display("=== Memory System (8086) Testbench ===");
        $display("  RAM: 0x00000-0x0001F | ROM: 0xFFFE0-0xFFFFF");

        // Idle bus
        RD_n = 1; WR_n = 1; M_IO_n = 1; address = 0; data_in = 0; reset = 0;

        // --- Reset ---
        @(negedge clk); reset = 1;
        @(posedge clk); #1; reset = 0;

        // ==== RAM Tests ====
        $display("  -- RAM Write/Read --");
        bus_write(20'h00002, 16'h1234);   // RAM word addr 1  (byte addr 0x00002 → A[4:1]=1)
        bus_write(20'h00004, 16'h5678);   // RAM word addr 2
        bus_write(20'h0001E, 16'hABCD);   // RAM last word (byte 0x01E → A[4:1]=15)

        bus_read_check(20'h00002, 16'h1234, 1, "RAM@0x00002");
        bus_read_check(20'h00004, 16'h5678, 2, "RAM@0x00004");
        bus_read_check(20'h0001E, 16'hABCD, 3, "RAM@0x0001E");

        // ==== ROM Tests (read-only) ====
        $display("  -- ROM Read --");
        // ROM word addr 0 = byte addr 0xFFFE0 → rom[0] of module = 0xAA01
        bus_read_check(20'hFFFE0, 16'hAA01, 4, "ROM@0xFFFE0 (word 0)");
        // ROM word addr 1 = byte addr 0xFFFE2 → rom[1] = 0xAA02
        bus_read_check(20'hFFFE2, 16'hAA02, 5, "ROM@0xFFFE2 (word 1)");
        // ROM last word addr 15 = byte addr 0xFFFFE
        bus_read_check(20'hFFFFE, 16'hAA10, 6, "ROM@0xFFFFE (word 15)");

        // ==== Address gap — no device selected ====
        $display("  -- Gap address (no device) --");
        @(negedge clk);
        address = 20'h10000; M_IO_n = 0; RD_n = 0; WR_n = 1;
        #5;
        if (data_out === 16'bz || data_out === 16'bx) begin
            $display("  PASS [7]: gap addr 0x10000 -> data_out=HiZ/X (no device)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL [7]: gap addr 0x10000 -> expected HiZ, got %04h", data_out);
            fail_count = fail_count + 1;
        end
        @(negedge clk); RD_n = 1;

        // ==== I/O cycle (M_IO_n=1) — RAM must NOT respond ====
        $display("  -- I/O cycle (M_IO_n=1) should not select RAM --");
        @(negedge clk);
        address = 20'h00002; M_IO_n = 1; RD_n = 0; WR_n = 1;
        #5;
        if (data_out === 16'bz || data_out === 16'bx || data_out !== 16'h1234) begin
            $display("  PASS [8]: M_IO_n=1 -> RAM not selected (data_out=%04h)", data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL [8]: M_IO_n=1 but RAM responded with %04h", data_out);
            fail_count = fail_count + 1;
        end
        @(negedge clk); RD_n = 1; M_IO_n = 0;

        $display("=== memory_system Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
