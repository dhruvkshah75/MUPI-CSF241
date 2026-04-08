`timescale 1ns/1ps
`include "mux2to1_16bits.v"

module mux2to1_16bits_tb;
    reg  [15:0] in0, in1;
    reg         select;
    wire [15:0] muxOut;
    integer pass_count = 0, fail_count = 0;

    mux2to1_16bits dut(.in0(in0), .in1(in1), .select(select), .muxOut(muxOut));

    task check_mux;
        input [15:0] a, b;
        input        sel;
        input [15:0] expected;
        begin
            in0 = a; in1 = b; select = sel; #5;
            if (muxOut === expected) begin
                $display("  PASS: in0=%04h in1=%04h sel=%b -> muxOut=%04h", a, b, sel, muxOut);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: in0=%04h in1=%04h sel=%b -> expected %04h, got %04h",
                         a, b, sel, expected, muxOut);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/mux2to1_16bits_tb.vcd");
        $dumpvars(0, mux2to1_16bits_tb);
        $display("=== 2-to-1 16-bit MUX Testbench ===");

        check_mux(16'h0014, 16'h0023, 0, 16'h0014);  // select 0 → in0
        check_mux(16'h0014, 16'h0023, 1, 16'h0023);  // select 1 → in1
        check_mux(16'h002D, 16'h0064, 0, 16'h002D);
        check_mux(16'h002D, 16'h0064, 1, 16'h0064);
        check_mux(16'hFFFF, 16'h0000, 0, 16'hFFFF);
        check_mux(16'hFFFF, 16'h0000, 1, 16'h0000);
        check_mux(16'hABCD, 16'h1234, 0, 16'hABCD);
        check_mux(16'hABCD, 16'h1234, 1, 16'h1234);

        $display("=== mux2to1_16bits Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
