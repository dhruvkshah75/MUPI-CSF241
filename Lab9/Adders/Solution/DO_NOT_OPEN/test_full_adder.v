`timescale 1ns/1ps
`include "./full_adder.v"
module test_full_adder;
    // Inputs
    reg a, b, cin;
    // Outputs
    wire sum, cout;

    // Instantiate the Full Adder
    full_adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Testcase 1
        a = 1'b0; b = 1'b0; cin = 1'b0;
        #10;
        $display("TC1: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 2
        a = 1'b0; b = 1'b0; cin = 1'b1;
        #10;
        $display("TC2: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 3
        a = 1'b0; b = 1'b1; cin = 1'b0;
        #10;
        $display("TC3: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 4
        a = 1'b0; b = 1'b1; cin = 1'b1;
        #10;
        $display("TC4: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 5
        a = 1'b1; b = 1'b0; cin = 1'b0;
        #10;
        $display("TC5: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 6
        a = 1'b1; b = 1'b0; cin = 1'b1;
        #10;
        $display("TC6: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 7
        a = 1'b1; b = 1'b1; cin = 1'b0;
        #10;
        $display("TC7: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        // Testcase 8
        a = 1'b1; b = 1'b1; cin = 1'b1;
        #10;
        $display("TC8: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);

        $finish;
    end
endmodule 