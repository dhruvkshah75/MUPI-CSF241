// half adder module 
module half_adder(input a, input b, output sum, output cout);

    // Half Adder => Sum = a xor b => a ^ b
    // cout = ab
    assign sum = a ^ b;
    assign cout = a & b;

    // Use output reg when the signal is driven by a procedural block (always) 

endmodule 