
module full_adder(
    input a,input b,input cin, 
    output sum,output cout
);

// implement full adder 
assign sum = a ^ b ^ cin;
assign cout = (a & b) | ((a ^ b) & cin);

endmodule
