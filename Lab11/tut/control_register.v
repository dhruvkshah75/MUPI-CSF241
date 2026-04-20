module control_register (
    input clk,
    input wr_en,   // wr_en is the write enable => gate enable only when active 
    input [7:0] data_in,
    output reg [7:0] ctr0_control,
    output reg [7:0] ctr1_control,
    output reg [7:0] ctr2_control
    // Removed the write strobe outputs
);

    // Note: In the control word => D7, D6 denote 00 => counter 0, 01 => counter 1, 10 => counter 2 and 11 => read
    always @(posedge clk) begin
        if (wr_en) begin
            case (data_in[7:6])  // SC1-SC0 bits select the counter
                2'b00: ctr0_control <= data_in;
                2'b01: ctr1_control <= data_in;
                2'b10: ctr2_control <= data_in;
                default: ; // No operation for other cases
            endcase
        end
    end
endmodule
