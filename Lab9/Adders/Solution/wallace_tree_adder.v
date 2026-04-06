// Wallace Tree Adder Module
`include "half_adder.v"
`include "full_adder.v"
`include "carry_look_ahead_4_bit_adder.v"
`include "carry_look_ahead_5_bit_adder.v"
module wallace_tree_adder(
    input [3:0] A, 
    input [3:0] B, 
    input [3:0] C, 
    input [3:0] D, 
    input [3:0] E,
    output [6:0] S
);

wire [4:0]X;
wire [4:0]Y;
wire [4:0]Z;

full_adder f1(A[0], B[0], C[0], Y[0], X[1]);
full_adder f2(A[1], B[1], C[1], Y[1], X[2]);
full_adder f3(A[2], B[2], C[2], Y[2], X[3]);
full_adder f4(A[3], B[3], C[3], Y[3], X[4]);

assign X[0] = 1'b0;
assign Y[4] = 1'b0;

carry_look_ahead_4_bit_adder a1(E, D, 1'b0, Z[3:0], Z[4]);

wire [4:0]U;
wire [4:0]V;

half_adder h1(Y[0], Z[0], S[0], V[0]);
full_adder f5(Y[1], Z[1], X[1], U[0], V[1]);
full_adder f6(Y[2], Z[2], X[2], U[1], V[2]);
full_adder f7(Y[3], Z[3], X[3], U[2], V[3]);
half_adder h2(X[4], Z[4], U[3], V[4]);

assign U[4]= 1'b0;

carry_look_ahead_5_bit_adder a2(U, V, 1'b0, S[5:1], S[6]);


endmodule


