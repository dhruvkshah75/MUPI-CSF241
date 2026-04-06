module mux2to1_16bits(
    input [15:0] in0, input [15:0] in1, input select, 
    output reg [15:0] muxOut
);

    // since output is reg we must use always block 
    always @(*) begin 
        case(select) 
            1'b0: muxOut = in0;
            1'b1: muxOut = in1;
        endcase
    end

endmodule 