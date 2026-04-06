`include "D_ff.v"
module register8bit(
    input clk, input chipSelect, input reset, input regWrite, input enable, 
    input [7:0] inR, output [7:0] outR
);

    // genvar is the variable used in the for loop 
    // we must wrap the for loop in generate and endgenerate

    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) 
            D_ff dff(clk, chipSelect, reset, regWrite, enable, inR[i], outR[i]);
    endgenerate

endmodule