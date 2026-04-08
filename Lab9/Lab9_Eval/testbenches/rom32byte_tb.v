`timescale 1ns/1ps
`include "rom32byte.v"

// NOTE TO STUDENTS:
// This testbench assumes your rom32byte initial block loads the following data:
//   rom[0]  = 16'hAA01,  rom[1]  = 16'hAA02,  ...  rom[15] = 16'hAA10
// (Each entry = 0xAA00 + location_index + 1)
// Make sure your rom32byte.v uses these exact values to pass this testbench.
module rom32byte_tb;
    reg         outputEnable, chipSelect;
    reg  [3:0]  address;
    wire [15:0] dataOut;
    integer pass_count = 0, fail_count = 0;
    integer k;

    rom32byte dut(.outputEnable(outputEnable), .chipSelect(chipSelect),
                  .address(address), .dataOut(dataOut));

    task check_read;
        input [3:0]  addr;
        input [15:0] expected;
        input [7:0]  test_id;
        begin
            address = addr; #5;
            if (dataOut === expected) begin
                $display("  PASS [%0d]: read@%0d -> %04h", test_id, addr, dataOut);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%0d]: read@%0d -> expected %04h, got %04h",
                         test_id, addr, expected, dataOut);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/rom32byte_tb.vcd");
        $dumpvars(0, rom32byte_tb);
        $display("=== 32-Byte ROM Testbench ===");
        $display("  (Expects rom[k] = 0xAA00 + k + 1)");

        outputEnable = 1; chipSelect = 1;
        #2;

        // Read all 16 locations (expects pattern 0xAA01..0xAA10)
        check_read(4'd0,  16'hAA01, 1);
        check_read(4'd1,  16'hAA02, 2);
        check_read(4'd2,  16'hAA03, 3);
        check_read(4'd5,  16'hAA06, 4);
        check_read(4'd9,  16'hAA0A, 5);
        check_read(4'd14, 16'hAA0F, 6);
        check_read(4'd15, 16'hAA10, 7);

        // outputEnable = 0 → dataOut must be 0 regardless of address
        outputEnable = 0; address = 4'd3; #5;
        if (dataOut === 16'b0) begin
            $display("  PASS [8]: outputEnable=0 -> dataOut=0");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL [8]: outputEnable=0 -> expected 0, got %04h", dataOut);
            fail_count = fail_count + 1;
        end

        // chipSelect = 0 → dataOut must be 0
        outputEnable = 1; chipSelect = 0; address = 4'd3; #5;
        if (dataOut === 16'b0) begin
            $display("  PASS [9]: chipSelect=0 -> dataOut=0");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL [9]: chipSelect=0 -> expected 0, got %04h", dataOut);
            fail_count = fail_count + 1;
        end

        $display("=== rom32byte Results: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                 $display("  SOME TESTS FAILED");
        $finish;
    end
endmodule
