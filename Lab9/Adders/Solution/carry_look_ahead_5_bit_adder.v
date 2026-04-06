module carry_look_ahead_5_bit_adder (
    input  [4:0] A,   
    input  [4:0] B,    
    input        Cin,  
    output [4:0] Sum, 
    output       Cout  
);

wire [3:0]p;
wire [3:0]g;

assign p[0] = (A[0] ^ B[0]);
assign p[1] = (A[1] ^ B[1]);
assign p[2] = (A[2] ^ B[2]);
assign p[3] = (A[3] ^ B[3]);

assign g[0] = (A[0] && B[0]);
assign g[1] = (A[1] && B[1]);
assign g[2] = (A[2] && B[2]);
assign g[3] = (A[3] && B[3]);

wire c1, c2, c3, c4;

assign c1 = (Cin && p[0]) || g[0];
assign c2 = (Cin && p[0] && p[1]) || (p[1] && g[0]) || g[1];
assign c3 = (Cin && p[0] && p[1] && p[2]) || (p[1] && g[0] && p[2]) || (g[1] && p[2]) || g[2];
assign c4 = (Cin && p[0] && p[1] && p[2] && p[3]) || (p[1] && g[0] && p[2] && p[3]) || (g[1] && p[2] && p[3]) || (g[2] && p[3]) || g[3];

assign Sum[0] = A[0] ^ B[0] ^ Cin;
assign Sum[1] = A[1] ^ B[1] ^ c1;
assign Sum[2] = A[2] ^ B[2] ^ c2;
assign Sum[3] = A[3] ^ B[3] ^ c3;
assign Sum[4] = A[4] ^ B[4] ^ c4;
assign Cout = (c4 && (A[4] ^ B[4])) || (A[4] && B[4]);



endmodule
