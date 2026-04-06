`timescale 1ns / 1ps
`include "carry_select_adder_8bit.v"

module tb_carry_select_adder;


    // Inputs
    reg [7:0] A;
    reg [7:0] B;

    // Outputs
    wire [7:0] S;
    wire Cout;

    // Variables for verification
    integer i, j;
    integer error_count = 0;
    reg [8:0] expected_val; // 9 bits to hold the carry + sum

    // Instantiate the Unit Under Test (UUT)
    carry_select_adder_8bit uut (
        .A(A), 
        .B(B), 
        .S(S), 
        .Cout(Cout)
    );

    initial begin
        // Initialize Inputs
        A = 0;
        B = 0;
        
        $display("Starting Exhaustive Testing...");
        
        // Loop through all 256 values of A
        for (i = 0; i < 256; i = i + 1) begin
            // Loop through all 256 values of B
            for (j = 0; j < 256; j = j + 1) begin
                A = i;
                B = j;
                
                #10; // Wait for combinational delay
                
                // Calculate expected value using behavioral addition
                expected_val = A + B;
                
                // Compare hardware result {Cout, S} with expected_val
                if ({Cout, S} !== expected_val) begin
                    $display("ERROR: A=%d, B=%d | Expected=%d, Got=%d", A, B, expected_val, {Cout, S});
                    error_count = error_count + 1;
                end
            end
        end

        // Final Report
        if (error_count == 0) begin
            $display("---------------------------------------");
            $display("TEST PASSED: All 65,536 cases correct!");
            $display("---------------------------------------");
        end else begin
            $display("---------------------------------------");
            $display("TEST FAILED: %d errors found.", error_count);
            $display("---------------------------------------");
        end
        
        $finish;
    end
    
    // Optional: Generate waveform file for GTKWave or Vivado
    initial begin
        $dumpfile("csa_test.vcd");
        $dumpvars(0, tb_carry_select_adder);
    end

endmodule