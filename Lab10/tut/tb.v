`include "top.v"
`timescale 1ns/1ps

module tb_intel_8254_simplified;

    // Clock and control signals
    reg clk;
    reg wr, rd, cs;
    reg [1:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;
    reg gate0, gate1, gate2;
    wire out0, out1, out2;

    // Test tracking
    integer error_count = 0;
    integer passed_tests = 0;
    integer test_num = 0;
    integer fail_flag;
    integer fail_flag0, fail_flag1, fail_flag2;

    // Device Under Test
    intel_8254_simplified dut (
        .clk(clk),
        .wr(wr),
        .rd(rd),
        .cs(cs),
        .a1(addr[1]),
        .a0(addr[0]),
        .data_in(data_in),
        .data_out(data_out),
        .gate0(gate0),
        .gate1(gate1),
        .gate2(gate2),
        .out0(out0),
        .out1(out1),
        .out2(out2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD dump for GTKWave
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_intel_8254_simplified);
    end

    // Helper task for checking results
    task check_test;
        input [0:0] expected;
        input [0:0] actual;
        input [127:0] msg;
        output integer fail_flag;
        begin
            if (actual !== expected) begin
                $display("  FAIL: %s", msg);
                $display("    Expected: %b, Actual: %b", expected, actual);
                fail_flag = 1;
            end else begin
                fail_flag = 0;
            end
        end
    endtask

    // Reset and initialize all signals
    task reset_all;
        begin
            wr = 0; rd = 0; cs = 0; addr = 2'b00;
            data_in = 8'd0;
            gate0 = 0; gate1 = 0; gate2 = 0;
            #20;
        end
    endtask

    // Main test sequence
    initial begin
        reset_all();

        // Test 1: Counter 0, count=3, expect OUT0 high after 3 clocks
        test_num = 1;
        fail_flag = 0;
        cs = 1; addr = 2'b11; data_in = 8'b00110000; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b00; data_in = 8'd3; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate0 = 1; #30; // 3 clocks
        check_test(1'b1, out0, "Counter0, count=3, OUT0 should be high after 3 clocks", fail_flag);
        if (!fail_flag) $display("[Test %0d] Test Case Passed", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (fail_flag == 0);
        reset_all();

        // Test 2: Counter 1, count=5, expect OUT1 high after 5 clocks
        test_num = 2;
        fail_flag = 0;
        cs = 1; addr = 2'b11; data_in = 8'b01110000; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b01; data_in = 8'd5; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate1 = 1; #50; // 5 clocks
        check_test(1'b1, out1, "Counter1, count=5, OUT1 should be high after 5 clocks", fail_flag);
        if (!fail_flag) $display("[Test %0d] Test Case Passed", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (fail_flag == 0);
        reset_all();

        // Test 3: Counter 2, count=2, expect OUT2 high after 2 clocks
        test_num = 3;
        fail_flag = 0;
        cs = 1; addr = 2'b11; data_in = 8'b10110000; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b10; data_in = 8'd2; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate2 = 1; #20; // 2 clocks
        check_test(1'b1, out2, "Counter2, count=2, OUT2 should be high after 2 clocks", fail_flag);
        if (!fail_flag) $display("[Test %0d] Test Case Passed", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (fail_flag == 0);
        reset_all();

        // Test 4: Counter 0, gate low disables counting, OUT0 remains low
        test_num = 4;
        fail_flag = 0;
        cs = 1; addr = 2'b11; data_in = 8'b00110000; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b00; data_in = 8'd4; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate0 = 0; #50; // Gate low, should not count
        check_test(1'b0, out0, "Counter0, gate low, OUT0 should remain low", fail_flag);
        if (!fail_flag) $display("[Test %0d] Test Case Passed", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (fail_flag == 0);
        reset_all();

        // Test 5: Counter 1, reload count while counting
        test_num = 5;
        fail_flag = 0;
        cs = 1; addr = 2'b11; data_in = 8'b01110000; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b01; data_in = 8'd4; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate1 = 1; #20; // 2 clocks
        cs = 1; addr = 2'b01; data_in = 8'd2; wr = 1; #10;
        wr = 0; cs = 0; #10;
        #20; // 2 more clocks
        check_test(1'b1, out1, "Counter1, reload to 2, OUT1 should be high after 2 more clocks", fail_flag);
        if (!fail_flag) $display("[Test %0d] Test Case Passed", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (fail_flag == 0);
        reset_all();

        // Test 6: All counters, different counts, OUTs should go high at expected times
        test_num = 6;
        fail_flag0 = 0; fail_flag1 = 0; fail_flag2 = 0;
        // Counter 0: 2, Counter 1: 3, Counter 2: 4
        cs = 1; addr = 2'b11; data_in = 8'b00110000; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b00; data_in = 8'd2; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b11; data_in = 8'b01110000; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b01; data_in = 8'd3; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b11; data_in = 8'b10110000; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b10; data_in = 8'd4; wr = 1; #10; wr = 0; cs = 0; #10;
        gate0 = 1; gate1 = 1; gate2 = 1;
        #20; // 2 clocks
        check_test(1'b1, out0, "Counter0, count=2, OUT0 should be high after 2 clocks", fail_flag0);
        #10; // 1 more clock
        check_test(1'b1, out1, "Counter1, count=3, OUT1 should be high after 3 clocks", fail_flag1);
        #10; // 1 more clock
        check_test(1'b1, out2, "Counter2, count=4, OUT2 should be high after 4 clocks", fail_flag2);
        if (!(fail_flag0 || fail_flag1 || fail_flag2)) $display("[Test %0d] Test Case Passed", test_num);
        else error_count = error_count + fail_flag0 + fail_flag1 + fail_flag2;
        passed_tests = passed_tests + ((fail_flag0 || fail_flag1 || fail_flag2) ? 0 : 1);
        reset_all();

        // Final report
        $display("\nTest Summary:");
        $display("  Passed: %0d/%0d", passed_tests, 6);
        $display("  Failed: %0d", 6 - passed_tests);
        $finish;
    end

endmodule
