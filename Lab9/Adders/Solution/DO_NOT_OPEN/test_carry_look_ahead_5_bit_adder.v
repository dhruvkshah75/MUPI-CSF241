`timescale 1ns/1ps
`include "./carry_look_ahead_5_bit_adder.v"
module test_carry_look_ahead_5_bit_adder;
    // Inputs
    reg [4:0] A, B;
    reg Cin;
    // Outputs
    wire [4:0] Sum;
    wire Cout;

    // Instantiate the Carry Look-ahead 5-bit Adder
    carry_look_ahead_5_bit_adder uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        // Testcase 1
        A = 5'b00000; B = 5'b00000; Cin = 1'b0;
        #10;
        $display("TC1: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 2
        A = 5'b01010; B = 5'b00101; Cin = 1'b0;
        #10;
        $display("TC2: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 3
        A = 5'b01111; B = 5'b10001; Cin = 1'b0;
        #10;
        $display("TC3: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 4
        A = 5'b11111; B = 5'b11111; Cin = 1'b0;
        #10;
        $display("TC4: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        // Testcase 5
        A = 5'b10100; B = 5'b01100; Cin = 1'b1;
        #10;
        $display("TC5: A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);

        $finish;
    end
endmodule 