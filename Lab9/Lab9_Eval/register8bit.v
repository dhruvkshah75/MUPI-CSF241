`ifndef REGISTER8BIT_V
`define REGISTER8BIT_V

`include "D_ff.v"

// 8-bit register built from 8 D flip-flops
module register8bit(input clk, input chipSelect, input reset, input regWrite, input enable, input [7:0] inR, output [7:0] outR);

    genvar i;
    generate
        // TODO: instantiate D_ff for each bit to create an 8-bit register
        for(i = 0; i < 8; i = i + 1) begin 
            D_ff d1(clk, chipSelect, reset, regWrite, enable, inR[i], outR[i]);
        end
    endgenerate

endmodule

`endif
