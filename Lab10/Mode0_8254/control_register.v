module control_register (
    input clk,
    input wr_en,           // wr_en is the write enable => wr_en = 1 then control word is written 
    input [7: 0] data_in,  // This is the contol word => [SC1 SC0 | RW1 RW0 | M2 M1 M0 | BCD]

    // outputs are the control words for each counter 
    output reg [7:0] ctr0_control
    output reg [7:0] ctr1_control
    output reg [7:0] ctr2_control
);

    // SC1 SC0 decides which counter gets selected 
    always @(posedge clk) begin 
        if(wr_en) begin 
            case(data_in[7:6]) 
                2'b00: ctr0_control <= data_in;
                2'b01: ctr1_control <= data_in;
                2'b10: ctr2_control <= data_in;
                default: ;  // 2'b11 => this is the read back condition 
            endcase
        end
    end

endmodule