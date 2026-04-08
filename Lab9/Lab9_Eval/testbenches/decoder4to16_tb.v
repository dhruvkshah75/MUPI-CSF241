`timescale 1ns/1ps
`include "decoder4to16.v"

module decoder4to16_tb;
    reg  [3:0]  destReg;
    wire [15:0] decOut;
    integer pass_count = 0, fail_count = 0;
    integer k;

    decoder4to16 dut(.destReg(destReg), .decOut(decOut));

    task check_decode;
        input [3:0]  addr;
        input [15:0] expected;
        begin
            destReg = addr; #5;
            if (decOut === expected) begin
                $display("  PASS: addr=%0d -> decOut=%016b", addr, decOut);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: addr=%0d -> expected %016b, got %016b",
                         addr, expected, decOut);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/decoder4to16_tb.vcd");
        $dumpvars(0, decoder4to16_tb);
        $display("=== 4-to-16 Decoder Testbench ===");

        // Test all 16 inputs
        check_decode(4'd0,  16'b0000_0000_0000_0001);
        check_decode(4'd1,  16'b0000_0000_0000_0010);
        check_decode(4'd2,  16'b0000_0000_0000_0100);
        check_decode(4'd3,  16'b0000_0000_0000_1000);
        check_decode(4'd4,  16'b0000_0000_0001_0000);
        check_decode(4'd5,  16'b0000_0000_0010_0000);
        check_decode(4'd6,  16'b0000_0000_0100_0000);
        check_decode(4'd7,  16'b0000_0000_1000_0000);
        check_decode(4'd8,  16'b0000_0001_0000_0000);
        check_decode(4'd9,  16'b0000_0010_0000_0000);
        check_decode(4'd10, 16'b0000_0100_0000_0000);
        check_decode(4'd11, 16'b0000_1000_0000_0000);
        check_decode(4'd12, 16'b0001_0000_0000_0000);
        check_decode(4'd13, 16'b0010_0000_0000_0000);
        check_decode(4'd14, 16'b0100_0000_0000_0000);
        check_decode(4'd15, 16'b1000_0000_0000_0000);

        $display("=== decoder4to16 Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
