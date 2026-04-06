
module mux_2_to_1_4bit(
    input [3:0] A,input [3:0] B, 
    input sel, output [3:0] Y
);

    assign Y = sel ? B : A;

endmodule
