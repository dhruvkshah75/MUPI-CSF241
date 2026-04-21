`include "top.v"
`timescale 1ns/1ps

module top_tb;

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
    integer ff, ff1, ff2, ff3;

    // Easter egg canvas
    reg [4:0] canvas;

    // Device Under Test
    intel_8254_mode2 dut (
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

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD dump for GTKWave
    initial begin
        $dumpfile("outputs/top_tb.vcd");
        $dumpvars(0, top_tb);
        $display("=== Intel 8254 Mode 2 Testbench ===");
    end

    // Helper task for checking results
    task check_test;
        input [0:0] expected;
        input [0:0] actual;
        input [511:0] msg;
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
            canvas = 5'b00000;
            #20;
        end
    endtask

    // Easter egg drawing task
    task draw_char;
        input [4:0] col1;
        input [4:0] col2;
        input [4:0] col3;
        begin
            canvas = col1; #10;
            canvas = col2; #10;
            canvas = col3; #10;
            canvas = 5'b00000; #10;
        end
    endtask

    // Main test sequence
    initial begin
        reset_all();

        // =====================================================================
        // Test 1: Counter 0, count=4, basic Mode 2 periodic output
        //   OUT should stay HIGH, go LOW for 1 clock at terminal count,
        //   then go HIGH again (auto-reload). Period = 4 clocks.
        // =====================================================================
        test_num = 1;
        ff = 0;
        // Write control word for counter 0 (SC=00, Mode 2)
        cs = 1; addr = 2'b11; data_in = 8'b00010100; wr = 1; #10;
        wr = 0; cs = 0; #10;
        // Write count = 4
        cs = 1; addr = 2'b00; data_in = 8'd4; wr = 1; #10;
        wr = 0; cs = 0; #10;
        // Enable gate
        gate0 = 1;
        #30; // 3 clocks - still counting down, OUT should be HIGH
        check_test(1'b1, out0, "T1a: Counter0 HIGH during countdown", ff1);
        ff = ff | ff1;
        #10; // 4th clock - terminal count, OUT should be LOW
        check_test(1'b0, out0, "T1b: Counter0 LOW at terminal count (period=4)", ff1);
        ff = ff | ff1;
        #10; // 5th clock - auto-reloaded, OUT should be HIGH again
        check_test(1'b1, out0, "T1c: Counter0 HIGH after auto-reload", ff1);
        ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - Basic Mode 2 periodic output", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // =====================================================================
        // Test 2: Counter 1, count=3, verify different period
        // =====================================================================
        test_num = 2;
        ff = 0;
        cs = 1; addr = 2'b11; data_in = 8'b01010100; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b01; data_in = 8'd3; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate1 = 1;
        #20; // 2 clocks - still counting
        check_test(1'b1, out1, "T2a: Counter1 HIGH during countdown", ff1);
        ff = ff | ff1;
        #10; // 3rd clock - terminal count
        check_test(1'b0, out1, "T2b: Counter1 LOW at terminal count (period=3)", ff1);
        ff = ff | ff1;
        #10; // reloaded
        check_test(1'b1, out1, "T2c: Counter1 HIGH after auto-reload", ff1);
        ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - Counter 1, period=3", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // =====================================================================
        // Test 3: Counter 2, count=6, verify longer period
        // =====================================================================
        test_num = 3;
        ff = 0;
        cs = 1; addr = 2'b11; data_in = 8'b10010100; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b10; data_in = 8'd6; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate2 = 1;
        #50; // 5 clocks - still HIGH
        check_test(1'b1, out2, "T3a: Counter2 HIGH during countdown", ff1);
        ff = ff | ff1;
        #10; // 6th clock - terminal count
        check_test(1'b0, out2, "T3b: Counter2 LOW at terminal count (period=6)", ff1);
        ff = ff | ff1;
        #10; // reloaded
        check_test(1'b1, out2, "T3c: Counter2 HIGH after auto-reload", ff1);
        ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - Counter 2, period=6", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // =====================================================================
        // Test 4: Gate LOW disables counting, OUT stays HIGH
        // =====================================================================
        test_num = 4;
        ff = 0;
        cs = 1; addr = 2'b11; data_in = 8'b00010100; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b00; data_in = 8'd4; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate0 = 0; // Keep gate LOW
        #60; // Wait longer than one full period would take
        check_test(1'b1, out0, "T4: Counter0 gate=0, OUT remains HIGH", ff1);
        ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - Gate disable", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // =====================================================================
        // Test 5: Reload count mid-operation changes period
        //   Load count=5, let it count 2 clocks, reload count=3.
        //   Terminal count should occur 3 clocks after reload.
        // =====================================================================
        test_num = 5;
        ff = 0;
        cs = 1; addr = 2'b11; data_in = 8'b01010100; wr = 1; #10;
        wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b01; data_in = 8'd5; wr = 1; #10;
        wr = 0; cs = 0; #10;
        gate1 = 1;
        #20; // 2 clocks of counting
        // Reload with count=3
        cs = 1; addr = 2'b01; data_in = 8'd3; wr = 1; #10;
        wr = 0; cs = 0; #10;
        // After reload: count goes 3->2->1->terminal over 3 posedges
        #10; // 1 clock after deassert (count=2, OUT still HIGH)
        check_test(1'b1, out1, "T5a: Counter1 HIGH during new countdown", ff1);
        ff = ff | ff1;
        #10; // terminal count with new period
        check_test(1'b0, out1, "T5b: Counter1 LOW at terminal count (reloaded to 3)", ff1);
        ff = ff | ff1;
        #10; // auto-reload
        check_test(1'b1, out1, "T5c: Counter1 HIGH after reload auto-repeat", ff1);
        ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - Mid-operation reload", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // =====================================================================
        // Test 6: All 3 counters simultaneously, different periods
        //   Counter 0: count=2, Counter 1: count=3, Counter 2: count=4
        //   Verify staggered terminal counts
        // =====================================================================
        test_num = 6;
        ff1 = 0; ff2 = 0; ff3 = 0;
        // Program all three counters
        cs = 1; addr = 2'b11; data_in = 8'b00010100; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b00; data_in = 8'd2; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b11; data_in = 8'b01010100; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b01; data_in = 8'd3; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b11; data_in = 8'b10010100; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b10; data_in = 8'd4; wr = 1; #10; wr = 0; cs = 0; #10;
        // Enable all gates
        gate0 = 1; gate1 = 1; gate2 = 1;
        // Counter 0 (period=2) hits terminal count first
        #20;
        check_test(1'b0, out0, "T6a: Counter0 LOW at terminal count (period=2)", ff);
        ff1 = ff1 | ff;
        // Counter 1 (period=3) hits terminal count next
        #10;
        check_test(1'b0, out1, "T6b: Counter1 LOW at terminal count (period=3)", ff);
        ff2 = ff2 | ff;
        // Counter 2 (period=4) hits terminal count last
        #10;
        check_test(1'b0, out2, "T6c: Counter2 LOW at terminal count (period=4)", ff);
        ff3 = ff3 | ff;
        if (!(ff1 || ff2 || ff3)) $display("[Test %0d] PASSED - All 3 counters simultaneous", test_num);
        else error_count = error_count + ff1 + ff2 + ff3;
        passed_tests = passed_tests + ((ff1 || ff2 || ff3) ? 0 : 1);
        reset_all();

        // =====================================================================
        // Test 7: Non-Mode 2 handling (Should not count)
        //   Set Counter 0 to Mode 3 (011) and verify OUT stays HIGH
        // =====================================================================
        test_num = 7;
        ff = 0;
        // SC0, RW=LSB, Mode=3 (011) -> 00 01 011 0 = 00010110
        cs = 1; addr = 2'b11; data_in = 8'b00010110; wr = 1; #10; wr = 0; cs = 0; #10;
        cs = 1; addr = 2'b00; data_in = 8'd4; wr = 1; #10; wr = 0; cs = 0; #10;
        gate0 = 1;
        #30; 
        check_test(1'b1, out0, "T7a: Counter0 OUT HIGH under non-Mode 2", ff1); ff = ff | ff1;
        #20;
        check_test(1'b1, out0, "T7b: Counter0 OUT remains HIGH (no counting)", ff1); ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - Invalid Mode Handling", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // =====================================================================
        // Test 8: 16-bit count mode (RW = 11)
        //   Write LSB then MSB. Count = 0x0002 (2). Check period.
        // =====================================================================
        test_num = 8;
        ff = 0;
        // SC1, RW=11, Mode=2 -> 01 11 010 0 = 01110100
        cs = 1; addr = 2'b11; data_in = 8'b01110100; wr = 1; #10; wr = 0; cs = 0; #10;
        // Write LSB = 2
        cs = 1; addr = 2'b01; data_in = 8'd2; wr = 1; #10; wr = 0; cs = 0; #10;
        // Write MSB = 0
        cs = 1; addr = 2'b01; data_in = 8'd0; wr = 1; #10; wr = 0; cs = 0; #10;
        gate1 = 1;
        #10; // 1 clock 
        check_test(1'b1, out1, "T8a: Counter1 HIGH during 16-bit countdown", ff1); ff = ff | ff1;
        #10; // 2nd clock -> terminal count!
        check_test(1'b0, out1, "T8b: Counter1 LOW at terminal count (16-bit)", ff1); ff = ff | ff1;
        if (!ff) $display("[Test %0d] PASSED - 16-bit Count Modifiers", test_num);
        else error_count = error_count + 1;
        passed_tests = passed_tests + (ff == 0);
        reset_all();

        // Final report
        $display("\n========================================");
        $display("=== System Integration Results: %0d PASSED, %0d FAILED ===", passed_tests, 8 - passed_tests);
        if (passed_tests == 8) $display("  ALL TESTS PASSED");
        else                   $display("  SOME TESTS FAILED");
        $display("  Score: %0d / 4 Marks", (passed_tests / 2));
        $display("========================================");

        // =================================================================
        //  EASTER EGG: Waveform Art
        //  If all tests passed, a hidden message is drawn in the VCD file.
        //  Open top_tb.vcd in GTKWave, find the 'canvas' signal, expand
        //  it to show canvas[4], canvas[3], ..., canvas[0] as separate
        //  traces. Use View -> Show Filled High Values for best results.
        // =================================================================
        if (passed_tests == 6) begin
            $display("");
            $display(">> BONUS: Open top_tb.vcd in GTKWave and look for");
            $display("   the 'canvas' signal. Expand it to 5 separate bit");
            $display("   traces for a surprise! (View -> Show Filled High Values)");
            canvas = 5'b00000; #50;

            // Draw 'C'
            draw_char(5'b11111, 5'b10001, 5'b10001);
            // Draw 'S'
            draw_char(5'b11101, 5'b10101, 5'b10111);

            // Space between words
            canvas = 5'b00000; #40;

            // Draw '2'
            draw_char(5'b10111, 5'b10101, 5'b11101);
            // Draw '0'
            draw_char(5'b11111, 5'b10001, 5'b11111);
            // Draw '2'
            draw_char(5'b10111, 5'b10101, 5'b11101);
            // Draw '8'
            draw_char(5'b11111, 5'b10101, 5'b11111);

            canvas = 5'b00000; #50;
        end

        
        $finish;
    end

endmodule
