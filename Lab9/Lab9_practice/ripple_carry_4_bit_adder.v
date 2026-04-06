`include "full_adder.v"
module ripple_carry_4_bit_adder(
    input [3:0] A,input [3:0] B, input Cin, 
    output [3:0] Sum,output Cout
);

wire c1,c2,c3;

//implement ripple carry adder 
// we must implement the normal 4 bit full adder 
full_adder fa1(.a(A[0]), .b(B[0]), .cin(Cin), .sum(Sum[0]), .cout(c1));
full_adder fa2(.a(A[1]), .b(B[1]), .cin(c1), .sum(Sum[1]), .cout(c2));
full_adder fa3(.a(A[2]), .b(B[2]), .cin(c2), .sum(Sum[2]), .cout(c3));
full_adder fa4(.a(A[3]), .b(B[3]), .cin(c3), .sum(Sum[3]), .cout(Cout));

endmodule
