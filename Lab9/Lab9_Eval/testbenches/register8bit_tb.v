`timescale 1ns/1ps
`include "register8bit.v"

module register8bit_tb;
    reg        clk, chipSelect, reset, regWrite, enable;
    reg  [7:0] inR;
    wire [7:0] outR;
    integer pass_count = 0, fail_count = 0;

    register8bit dut(.clk(clk), .chipSelect(chipSelect), .reset(reset),
                     .regWrite(regWrite), .enable(enable), .inR(inR), .outR(outR));

    initial clk = 0;
    always #10 clk = ~clk;

    task apply_check;
        input [7:0] data_in;
        input       cs_in, rw_in, en_in, rst_in;
        input [7:0] expected;
        input [7:0] test_id;
        begin
            @(negedge clk);
            inR = data_in; chipSelect = cs_in; regWrite = rw_in;
            enable = en_in; reset = rst_in;
            @(posedge clk); #1;
            if (outR === expected) begin
                $display("  PASS [%0d]: inR=%08b cs=%b rw=%b en=%b rst=%b -> outR=%08b",
                         test_id, data_in, cs_in, rw_in, en_in, rst_in, outR);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%0d]: inR=%08b -> expected %08b, got %08b",
                         test_id, data_in, expected, outR);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/register8bit_tb.vcd");
        $dumpvars(0, register8bit_tb);
        $display("=== 8-bit Register Testbench ===");

        chipSelect = 0; reset = 0; regWrite = 0; enable = 0; inR = 8'b0;

        // Test 1: Write 0x00 (all enables set)
        apply_check(8'h00, 1, 1, 1, 0, 8'h00, 1);
        // Test 2: Write 0xFF
        apply_check(8'hFF, 1, 1, 1, 0, 8'hFF, 2);
        // Test 3: Write 0x55
        apply_check(8'h55, 1, 1, 1, 0, 8'h55, 3);
        // Test 4: No write when chipSelect=0 (output retains 0x55)
        apply_check(8'hAA, 0, 1, 1, 0, 8'h55, 4);
        // Test 5: No write when regWrite=0
        apply_check(8'hAA, 1, 0, 1, 0, 8'h55, 5);
        // Test 6: No write when enable=0
        apply_check(8'hAA, 1, 1, 0, 0, 8'h55, 6);
        // Test 7: Reset clears to 0
        apply_check(8'hAA, 1, 1, 1, 1, 8'h00, 7);
        // Test 8: Write 0xA9 after reset
        apply_check(8'hA9, 1, 1, 1, 0, 8'hA9, 8);
        // Test 9: Write 0x0F
        apply_check(8'h0F, 1, 1, 1, 0, 8'h0F, 9);

        $display("=== register8bit Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
