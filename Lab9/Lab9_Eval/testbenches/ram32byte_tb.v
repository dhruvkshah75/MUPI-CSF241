`timescale 1ns/1ps
`include "ram32byte.v"

module ram32byte_tb;
    reg        clk, chipSelect, reset, outputEnable, writeEnable;
    reg  [3:0] address;
    reg  [15:0] writeData;
    wire [15:0] memOut;
    integer pass_count = 0, fail_count = 0;
    integer k;

    ram32byte dut(.clk(clk), .chipSelect(chipSelect), .reset(reset),
                  .outputEnable(outputEnable), .writeEnable(writeEnable),
                  .address(address), .writeData(writeData), .memOut(memOut));

    initial clk = 0;
    always #10 clk = ~clk;

    // Write one word to a given address
    task do_write;
        input [3:0]  addr;
        input [15:0] data;
        begin
            @(negedge clk);
            chipSelect = 1; outputEnable = 0; writeEnable = 1;
            address = addr; writeData = data;
            @(posedge clk); #1;
            writeEnable = 0;
        end
    endtask

    // Read and check a given address
    task do_read_check;
        input [3:0]  addr;
        input [15:0] expected;
        input [7:0]  test_id;
        begin
            @(negedge clk);
            chipSelect = 1; outputEnable = 1; writeEnable = 0;
            address = addr;
            #5;
            if (memOut === expected) begin
                $display("  PASS [%0d]: read@%0d -> %04h", test_id, addr, memOut);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%0d]: read@%0d -> expected %04h, got %04h",
                         test_id, addr, expected, memOut);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/ram32byte_tb.vcd");
        $dumpvars(0, ram32byte_tb);
        $display("=== 32-Byte RAM Testbench ===");

        chipSelect = 0; reset = 0; outputEnable = 0; writeEnable = 0;
        address = 0; writeData = 0;

        // -- Write to all 16 locations --
        $display("  [Writing to all 16 locations]");
        do_write(4'd0,  16'hAA01);
        do_write(4'd1,  16'hAA02);
        do_write(4'd2,  16'hAA03);
        do_write(4'd3,  16'hAA04);
        do_write(4'd4,  16'hAA05);
        do_write(4'd5,  16'hAA06);
        do_write(4'd6,  16'hAA07);
        do_write(4'd7,  16'hAA08);
        do_write(4'd8,  16'hAA09);
        do_write(4'd9,  16'hAA0A);
        do_write(4'd10, 16'hAA0B);
        do_write(4'd11, 16'hAA0C);
        do_write(4'd12, 16'hAA0D);
        do_write(4'd13, 16'hAA0E);
        do_write(4'd14, 16'hAA0F);
        do_write(4'd15, 16'hAA10);

        // -- Read back all 16 locations --
        $display("  [Reading back all 16 locations]");
        do_read_check(4'd0,  16'hAA01, 1);
        do_read_check(4'd1,  16'hAA02, 2);
        do_read_check(4'd5,  16'hAA06, 3);
        do_read_check(4'd7,  16'hAA08, 4);
        do_read_check(4'd15, 16'hAA10, 5);

        // -- Test: outputEnable=0 forces memOut=0 (chip still selected) --
        @(negedge clk);
        chipSelect = 1; outputEnable = 0; writeEnable = 0; address = 4'd5;
        #5;
        if (memOut === 16'b0) begin
            $display("  PASS [6]: outputEnable=0 -> memOut=0");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL [6]: outputEnable=0 -> expected 0, got %04h", memOut);
            fail_count = fail_count + 1;
        end

        // -- Test: reset clears all locations --
        @(negedge clk);
        chipSelect = 1; reset = 1; outputEnable = 0; writeEnable = 0;
        @(posedge clk); #1;
        reset = 0;
        do_read_check(4'd5, 16'h0000, 7);
        do_read_check(4'd0, 16'h0000, 8);

        // -- Test: write after reset --
        do_write(4'd3, 16'hBEEF);
        do_read_check(4'd3, 16'hBEEF, 9);

        $display("=== ram32byte Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
