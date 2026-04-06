// filepath: /Users/tanishdesai37/Downloads/mup lab 2/test_wallace_tree_adder.v
`timescale 1ns/1ps
`include "./wallace_tree_adder.v"
module test_wallace_tree_adder;
    // Inputs
    reg [3:0] A, B, C, D, E;
    // Outputs
    wire [6:0] S;

    // Instantiate the Wallace Tree Adder
    wallace_tree_adder uut (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .E(E),
        .S(S)
    );

    initial begin
        // Testcase 1
        A = 4'b0000; B = 4'b0000; C = 4'b0000; D = 4'b0000; E = 4'b0000;
        #10;
        $display("TC1: A=%b B=%b C=%b D=%b E=%b => S=%b", A, B, C, D, E, S);

        // Testcase 2
        A = 4'b1000; B = 4'b0100; C = 4'b0010; D = 4'b0001; E = 4'b0000;
        #10;
        $display("TC2: A=%b B=%b C=%b D=%b E=%b => S=%b", A, B, C, D, E, S);

        // Testcase 3
        A = 4'b1111; B = 4'b1111; C = 4'b1111; D = 4'b1111; E = 4'b1111;
        #10;
        $display("TC3: A=%b B=%b C=%b D=%b E=%b => S=%b", A, B, C, D, E, S);

        // Testcase 4
        A = 4'b1010; B = 4'b0101; C = 4'b1010; D = 4'b0101; E = 4'b1010;
        #10;
        $display("TC4: A=%b B=%b C=%b D=%b E=%b => S=%b", A, B, C, D, E, S);

        // Testcase 5
        A = 4'b1100; B = 4'b0011; C = 4'b1100; D = 4'b0011; E = 4'b1100;
        #10;
        $display("TC5: A=%b B=%b C=%b D=%b E=%b => S=%b", A, B, C, D, E, S);

        // Testcase 6
        A = 4'b1011; B = 4'b1101; C = 4'b0111; D = 4'b0101; E = 4'b0011;
        #10;
        $display("TC6: A=%b B=%b C=%b D=%b E=%b => S=%b", A, B, C, D, E, S);

        $finish;
    end
endmodule