`include "ripple_carry_4_bit_adder.v"
`include "mux_2_to_1_4bit.v"

module carry_select_adder_8bit(
    input [7:0] A, input [7:0] B, 
    output [7:0] S,output Cout
);

//impoelment the top module CSA here 
// Use any variable you need to by declaring them by wire

// to add two 8 bit numbers use the steps included in the lab sheet 
wire cs;

ripple_carry_4_bit_adder f1(.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(S[3:0]), .Cout(cs));

// as step 2 we calculate the sum of upper 4 bits with carry 1 and carry 0
wire[3:0] temp_sum_carry1;
wire[3:0] temp_sum_carry0;

wire temp_cout_carry0, temp_cout_carry1;

ripple_carry_4_bit_adder f2(.A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Sum(temp_sum_carry0[3:0]), .Cout(temp_cout_carry0));
ripple_carry_4_bit_adder f3(.A(A[7:4]), .B(B[7:4]), .Cin(1'b1), .Sum(temp_sum_carry1[3:0]), .Cout(temp_cout_carry1));

// using the mux with the select line as the cs 
// sel = 1 then B = temp_sum_carry1
// mux1 is used to get the sum and mux2 is used to get the carry out
mux_2_to_1_4bit m1(.A(temp_sum_carry0), .B(temp_sum_carry1), .sel(cs), .Y(S[7:4]));

assign Cout = cs ? temp_cout_carry1 : temp_cout_carry0;

endmodule
