// full adder module 

// full adder implementation by calling the half adder 
`include "half_adder.v"

module full_adder_impl(input a, b, cin, output sum, cout);
    // we write the full adder using half adder 
    wire sum1, carry1, carry2;

    // first half adder =>  inputs = a, b      outputs = sum1, carry1 
    // second half adder => inputs = sum1, cin outputs = sum, carry2 
    // cout = carry1 | carry2

    half_adder ha1(.a(a), .b(b), .sum(sum1), .cout(carry1));
    half_adder ha2(.a(sum1), .b(cin), .sum(sum), .cout(carry2));

    assign cout = carry1 | carry2;


endmodule


module full_adder(input a, b, cin, output sum, cout);

    // consider the full adder to be made from two half adders
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | ((a ^ b) & cin);

endmodule 


