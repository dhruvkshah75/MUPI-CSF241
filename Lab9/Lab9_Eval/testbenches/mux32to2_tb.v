`timescale 1ns/1ps
`include "mux32to2.v"

module mux32to2_tb;
    reg [7:0] in0,  in1,  in2,  in3,  in4,  in5,  in6,  in7;
    reg [7:0] in8,  in9,  in10, in11, in12, in13, in14, in15;
    reg [7:0] in16, in17, in18, in19, in20, in21, in22, in23;
    reg [7:0] in24, in25, in26, in27, in28, in29, in30, in31;
    reg [3:0] select;
    wire [15:0] muxOut;
    integer pass_count = 0, fail_count = 0;

    mux32to2 dut(
        .in0(in0),   .in1(in1),   .in2(in2),   .in3(in3),
        .in4(in4),   .in5(in5),   .in6(in6),   .in7(in7),
        .in8(in8),   .in9(in9),   .in10(in10), .in11(in11),
        .in12(in12), .in13(in13), .in14(in14), .in15(in15),
        .in16(in16), .in17(in17), .in18(in18), .in19(in19),
        .in20(in20), .in21(in21), .in22(in22), .in23(in23),
        .in24(in24), .in25(in25), .in26(in26), .in27(in27),
        .in28(in28), .in29(in29), .in30(in30), .in31(in31),
        .select(select), .muxOut(muxOut));

    task check_select;
        input [3:0]  sel;
        input [15:0] expected;
        begin
            select = sel; #5;
            if (muxOut === expected) begin
                $display("  PASS: select=%0d -> muxOut=%04h", sel, muxOut);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: select=%0d -> expected %04h, got %04h", sel, expected, muxOut);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/mux32to2_tb.vcd");
        $dumpvars(0, mux32to2_tb);
        $display("=== 32-to-2 Byte MUX Testbench ===");

        // Assign distinct values to each byte so we can verify selection
        in0  = 8'hA0; in1  = 8'hA1; in2  = 8'hA2; in3  = 8'hA3;
        in4  = 8'hA4; in5  = 8'hA5; in6  = 8'hA6; in7  = 8'hA7;
        in8  = 8'hA8; in9  = 8'hA9; in10 = 8'hAA; in11 = 8'hAB;
        in12 = 8'hAC; in13 = 8'hAD; in14 = 8'hAE; in15 = 8'hAF;
        in16 = 8'hB0; in17 = 8'hB1; in18 = 8'hB2; in19 = 8'hB3;
        in20 = 8'hB4; in21 = 8'hB5; in22 = 8'hB6; in23 = 8'hB7;
        in24 = 8'hB8; in25 = 8'hB9; in26 = 8'hBA; in27 = 8'hBB;
        in28 = 8'hBC; in29 = 8'hBD; in30 = 8'hBE; in31 = 8'hBF;
        #5;

        // Test all 16 select values
        check_select(4'd0,  {in0,  in1 });   // 0xA0A1
        check_select(4'd1,  {in2,  in3 });   // 0xA2A3
        check_select(4'd2,  {in4,  in5 });   // 0xA4A5
        check_select(4'd3,  {in6,  in7 });   // 0xA6A7
        check_select(4'd4,  {in8,  in9 });   // 0xA8A9
        check_select(4'd5,  {in10, in11});   // 0xAAAB
        check_select(4'd6,  {in12, in13});   // 0xACAD
        check_select(4'd7,  {in14, in15});   // 0xAEAF
        check_select(4'd8,  {in16, in17});   // 0xB0B1
        check_select(4'd9,  {in18, in19});   // 0xB2B3
        check_select(4'd10, {in20, in21});   // 0xB4B5
        check_select(4'd11, {in22, in23});   // 0xB6B7
        check_select(4'd12, {in24, in25});   // 0xB8B9
        check_select(4'd13, {in26, in27});   // 0xBABB
        check_select(4'd14, {in28, in29});   // 0xBCBD
        check_select(4'd15, {in30, in31});   // 0xBEBF

        $display("=== mux32to2 Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
