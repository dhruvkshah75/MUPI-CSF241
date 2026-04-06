`timescale 1ns/1ps
`include "./carry_look_ahead_4_bit_adder.v"
module test_carry_look_ahead_4_bit_adder;
    // Inputs
    reg [3:0] A, B;
    reg Cin;
    // Outputs
    wire [3:0] Sum;
    wire Cout;

    // Instantiate the Carry Look-ahead 4-bit Adder
    carry_look_ahead_4_bit_adder uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        // Testcase 1
        A = 4'b0000; B = 4'b0000; Cin = 1'b0;
        #10;
        $display("TC1: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 2
        A = 4'b0101; B = 4'b0011; Cin = 1'b0;
        #10;
        $display("TC2: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 3
        A = 4'b0111; B = 4'b1001; Cin = 1'b0;
        #10;
        $display("TC3: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 4
        A = 4'b1111; B = 4'b1111; Cin = 1'b0;
        #10;
        $display("TC4: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 5
        A = 4'b1010; B = 4'b0101; Cin = 1'b1;
        #10;
        $display("TC5: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        $finish;
    end
endmodule 