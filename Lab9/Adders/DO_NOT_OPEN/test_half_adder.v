`timescale 1ns/1ps
`include "./half_adder.v"
module test_half_adder;
    // Inputs
    reg a, b;
    // Outputs
    wire sum, cout;

    // Instantiate the Half Adder
    half_adder uut (
        .a(a),
        .b(b),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Testcase 1
        a = 1'b0; b = 1'b0;
        #10;
        $display("TC1: a=%b b=%b => sum=%b cout=%b", a, b, sum, cout);

        // Testcase 2
        a = 1'b0; b = 1'b1;
        #10;
        $display("TC2: a=%b b=%b => sum=%b cout=%b", a, b, sum, cout);

        // Testcase 3
        a = 1'b1; b = 1'b0;
        #10;
        $display("TC3: a=%b b=%b => sum=%b cout=%b", a, b, sum, cout);

        // Testcase 4
        a = 1'b1; b = 1'b1;
        #10;
        $display("TC4: a=%b b=%b => sum=%b cout=%b", a, b, sum, cout);

        $finish;
    end
endmodule 