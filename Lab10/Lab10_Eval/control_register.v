module control_register (
    input clk,
    input wr_en,
    input [7:0] data_in,
    output reg [7:0] ctr0_control,
    output reg [7:0] ctr1_control,
    output reg [7:0] ctr2_control
);

    always @(posedge clk) begin
        if (wr_en) begin
            // TODO: Route the incoming data to the appropriate counter's control register.
            // Review the 8254 control word format to determine which bits select the destination. Invalid SC (11) retains previous
            case({data_in[7:6]}) 
                2'b00: ctr0_control <= data_in;
                2'b01: ctr1_control <= data_in;
                2'b10: ctr2_control <= data_in;
                default: ;
            endcase 
        end
    end
endmodule