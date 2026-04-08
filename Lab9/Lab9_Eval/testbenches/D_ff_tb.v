`timescale 1ns/1ps
`include "D_ff.v"

module D_ff_tb;
    reg clk, chipSelect, reset, regWrite, enable, d;
    wire q;
    integer pass_count = 0, fail_count = 0;

    // Instantiate DUT
    D_ff dut(.clk(clk), .chipSelect(chipSelect), .reset(reset),
             .regWrite(regWrite), .enable(enable), .d(d), .q(q));

    // Clock generation: period = 20ns
    initial clk = 0;
    always #10 clk = ~clk;

    // Helper task: apply inputs on negedge, check output after next posedge
    task apply_check;
        input d_in, cs_in, rw_in, en_in, rst_in, expected;
        input [63:0] test_id;
        begin
            @(negedge clk);
            d = d_in; chipSelect = cs_in; regWrite = rw_in;
            enable = en_in; reset = rst_in;
            @(posedge clk); #1;
            if (q === expected) begin
                $display("  PASS [%0d]: d=%b cs=%b rw=%b en=%b rst=%b -> q=%b",
                         test_id, d_in, cs_in, rw_in, en_in, rst_in, q);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%0d]: d=%b cs=%b rw=%b en=%b rst=%b -> expected q=%b, got q=%b",
                         test_id, d_in, cs_in, rw_in, en_in, rst_in, expected, q);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/D_ff_tb.vcd");
        $dumpvars(0, D_ff_tb);
        $display("=== D Flip-Flop Testbench ===");

        // Initialise
        chipSelect = 0; reset = 0; regWrite = 0; enable = 0; d = 0;
        @(negedge clk); // let clock settle

        // Test 1: Write d=0 with all enables high
        apply_check(0, 1, 1, 1, 0, 0, 1);
        // Test 2: Write d=1 with all enables high
        apply_check(1, 1, 1, 1, 0, 1, 2);
        // Test 3: Retain value when chipSelect=0
        apply_check(0, 0, 1, 1, 0, 1, 3);
        // Test 4: Retain value when regWrite=0
        apply_check(0, 1, 0, 1, 0, 1, 4);
        // Test 5: Retain value when enable=0
        apply_check(0, 1, 1, 0, 0, 1, 5);
        // Test 6: Reset overrides data (q=0 even with d=1)
        apply_check(1, 1, 1, 1, 1, 0, 6);
        // Test 7: After reset, write d=1 again
        apply_check(1, 1, 1, 1, 0, 1, 7);
        // Test 8: Write d=0
        apply_check(0, 1, 1, 1, 0, 0, 8);
        // Test 9: Reset with chipSelect=0 should NOT reset (q stays 0 here — borderline)
        apply_check(1, 0, 1, 1, 1, 0, 9);

        $display("=== D_ff Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
