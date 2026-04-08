`ifndef MUX2TO1_16BITS_V
`define MUX2TO1_16BITS_V

// 2-to-1 MUX (16-bit): select=0 → in0 ; select=1 → in1
module mux2to1_16bits(input [15:0] in0, input [15:0] in1, input select, output reg [15:0] muxOut);
    always @(*) begin 
        if(select == 1'b1) begin 
            muxOut = in1;
        end 
        else begin 
            muxOut = in0;
        end
    end
endmodule

`endif
