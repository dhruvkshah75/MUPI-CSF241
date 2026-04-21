`include "counter.v"
`timescale 1ns/1ps

module counter_tb;
    reg clk;
    reg gate;
    reg ctr_wr;
    reg [7:0] data_in;
    reg [7:0] control_word;
    wire out;

    integer passed_tests = 0;
    integer fail_count = 0;
    integer ff1;
    reg t2_passed;

    counter dut (
        .clk(clk),
        .gate(gate),
        .ctr_wr(ctr_wr),
        .data_in(data_in),
        .control_word(control_word),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check_test;
        input [0:0] expected;
        input [0:0] actual;
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
        $dumpfile("outputs/counter_tb.vcd");
        $dumpvars(0, counter_tb);
        $display("=== Counter Testbench ===");
        gate = 0; ctr_wr = 0; data_in = 0; control_word = 0;
        t2_passed = 0;
        #20;
        
        // TC1: Basic Mode 2 countdown (RW=LSB)
        control_word = 8'b00010100; // RW=01, Mode=2
        ctr_wr = 1; data_in = 8'd3; #10; ctr_wr = 0; #10;
        gate = 1;
        #10; // 1 cycle
        // Posedge at 45: count->2
        check_test(1'b1, out, "T1: Basic Countdown starts HIGH");

        // TC2: Terminal count LOW pulse
        #10; // Posedge at 55: count->1 
        // Need one more cycle for out to go low because count must be <=1 during posedge
        #10; // Posedge at 65: triggers out->0
        
        t2_passed = (out === 1'b0);
        check_test(1'b0, out, "T2: OUT goes LOW at terminal count");

        // TC3: Auto-reload
        #10; // Posedge at 75: reloads 3, out->1
        if (t2_passed) check_test(1'b1, out, "T3: OUT returns HIGH on auto-reload");
        else check_test(1'b1, 1'bx, "T3: Skipped (T2 failed)");

        // TC4: Gate Disable
        gate = 0;
        #40; // Wait 4 cycles
        if (t2_passed) check_test(1'b1, out, "T4: Gate disable halts counting (OUT stays HIGH)");
        else check_test(1'b1, 1'bx, "T4: Skipped (T2 failed)");

        // TC5: Edge case count <= 1 safety (Load 1)
        gate = 1;
        ctr_wr = 1; data_in = 8'd1; #10; ctr_wr = 0; #10;
        #10; // next cycle triggers <=1
        check_test(1'b0, out, "T5: Edge case count=1 triggers terminal securely");
        #10; // Let it reload

        // TC6: Invalid Mode handling (Mode 3)
        control_word = 8'b00010110; // Mode 3
        ctr_wr = 1; data_in = 8'd4; #10; ctr_wr = 0; #10;
        #40;
        if (t2_passed) check_test(1'b1, out, "T6: Invalid mode prevents count down (OUT stays HIGH)");
        else check_test(1'b1, 1'bx, "T6: Skipped (T2 failed)");

        // TC7: 16-bit loading (LSB first)
        control_word = 8'b00110100; // RW=11, Mode=2
        ctr_wr = 1; data_in = 8'd2; #10; ctr_wr = 0; #10;
        #20; 
        if (t2_passed) check_test(1'b1, out, "T7: 16-Bit loading LSB isolates count");
        else check_test(1'b1, 1'bx, "T7: Skipped (T2 failed)");

        // TC8: 16-bit loading (MSB triggers)
        ctr_wr = 1; data_in = 8'd0; #10; ctr_wr = 0; #10;
        #10; // 1 clock (count -> 1)
        #10; // 2nd clock triggers terminal count evaluation
        #10; // 3rd clock edge pushes out out=0 
        check_test(1'b0, out, "T8: 16-Bit complete load achieves correct terminal");

        $display("\n========================================");
        $display("=== counter_tb Results: %0d PASSED, %0d FAILED ===", passed_tests, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $display("  Score: %0d / 4 Marks", (passed_tests / 2));
        $display("========================================");
        $finish;
    end
endmodule
