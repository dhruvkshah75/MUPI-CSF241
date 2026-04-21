`include "control_register.v"
`timescale 1ns/1ps

module control_register_tb;
    reg clk;
    reg wr_en;
    reg [7:0] data_in;
    wire [7:0] ctr0_control;
    wire [7:0] ctr1_control;
    wire [7:0] ctr2_control;

    integer passed_tests = 0;
    integer fail_count = 0;
    integer ff1;

    control_register dut (
        .clk(clk),
        .wr_en(wr_en),
        .data_in(data_in),
        .ctr0_control(ctr0_control),
        .ctr1_control(ctr1_control),
        .ctr2_control(ctr2_control)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check_test;
        input [7:0] expected;
        input [7:0] actual;
        input [511:0] msg;
        begin
            if (actual !== expected) begin
                $display("  FAIL: %s", msg);
                $display("    Expected: %b, Actual: %b", expected, actual);
                fail_count = fail_count + 1;
            end else begin
                $display("  PASS: %s", msg);
                passed_tests = passed_tests + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/control_register_tb.vcd");
        $dumpvars(0, control_register_tb);
        $display("=== Control Register Testbench ===");
        
        wr_en = 0; data_in = 0;
        #20;
        
        // TC1: Write Ctr 0 (SC=00)
        wr_en = 1; data_in = 8'b00110100; #10; wr_en = 0; #10;
        check_test(8'b00110100, ctr0_control, "T1: Counter 0 Control Word");

        // TC2: Write Ctr 1 (SC=01)
        wr_en = 1; data_in = 8'b01010100; #10; wr_en = 0; #10;
        check_test(8'b01010100, ctr1_control, "T2: Counter 1 Control Word");

        // TC3: Write Ctr 2 (SC=10)
        wr_en = 1; data_in = 8'b10111110; #10; wr_en = 0; #10;
        check_test(8'b10111110, ctr2_control, "T3: Counter 2 Control Word");

        // TC4: Invalid Counter Write (SC=11) shouldn't affect others
        wr_en = 1; data_in = 8'b11000000; #10; wr_en = 0; #10;
        // Verify Ctr0 still holds its value to pass
        check_test(8'b00110100, ctr0_control, "T4: Invalid SC (11) retains previous");

        $display("\n========================================");
        $display("=== control_register_tb Results: %0d PASSED, %0d FAILED ===", passed_tests, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $display("  Score: %0d / 2 Marks", (passed_tests / 2));
        $display("========================================");
        $finish;
    end
endmodule
