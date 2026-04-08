`ifndef MUX32TO2_V
`define MUX32TO2_V

// 32-to-2 byte MUX: select=N → muxOut = {in[2N], in[2N+1]}  (Big-Endian pairs)
// select=0 → {in0,in1}  select=1 → {in2,in3}  ...  select=15 → {in30,in31}
module mux32to2(
    input [7:0] in0,  input [7:0] in1,  input [7:0] in2,  input [7:0] in3,
    input [7:0] in4,  input [7:0] in5,  input [7:0] in6,  input [7:0] in7,
    input [7:0] in8,  input [7:0] in9,  input [7:0] in10, input [7:0] in11,
    input [7:0] in12, input [7:0] in13, input [7:0] in14, input [7:0] in15,
    input [7:0] in16, input [7:0] in17, input [7:0] in18, input [7:0] in19,
    input [7:0] in20, input [7:0] in21, input [7:0] in22, input [7:0] in23,
    input [7:0] in24, input [7:0] in25, input [7:0] in26, input [7:0] in27,
    input [7:0] in28, input [7:0] in29, input [7:0] in30, input [7:0] in31,
    input [3:0] select, output reg [15:0] muxOut);

    always @ (in0,  in1,  in2,  in3,  in4,  in5,  in6,  in7,
              in8,  in9,  in10, in11, in12, in13, in14, in15,
              in16, in17, in18, in19, in20, in21, in22, in23,
              in24, in25, in26, in27, in28, in29, in30, in31, select)
    begin
        // TODO: Map the 16 cases of 'select' to output the correct pair
        case(select)
            4'd0: muxOut = {in0, in1};
            4'd1: muxOut = {in2, in3};
            4'd2: muxOut = {in4, in5};
            4'd3: muxOut = {in6, in7};
            4'd4: muxOut = {in8, in9};
            4'd5: muxOut = {in10, in11};
            4'd6: muxOut = {in12, in13};
            4'd7: muxOut = {in14, in15};
            4'd8: muxOut = {in16, in17};
            4'd9: muxOut = {in18, in19};
            4'd10: muxOut = {in20, in21};
            4'd11: muxOut = {in22, in23};
            4'd12: muxOut = {in24, in25};
            4'd13: muxOut = {in26, in27};
            4'd14: muxOut = {in28, in29};
            4'd15: muxOut = {in30, in31};
            default: muxOut = 16'b0;
        endcase
    end
endmodule

`endif
