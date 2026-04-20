`include "rw_logic.v"
`include "control_register.v"
`include "counter.v"
`include "data_bus_buffer.v"

module intel_8254_simplified (
    input clk,
    input wr,
    input rd,
    input cs,
    input a1,
    input a0,
    input [7:0] data_in,
    output [7:0] data_out,
    input gate0,
    input gate1,
    input gate2,
    output out0,
    output out1,
    output out2
);
    // Internal signals
    wire c0_wr, c1_wr, c2_wr, creg_wr;
    wire [7:0] int_data_out;
    wire [7:0] c0_ctrl;
    wire [7:0] c1_ctrl;
    wire [7:0] c2_ctrl;
    // Read/Write Logic
    rw_logic r1(cs, wr, a1, a0, c0_wr, c1_wr, c2_wr, creg_wr);
    
    // Data Bus Buffer
    data_bus_buffer d1(data_in, int_data_out);
    assign data_out = int_data_out;
    
    // Control Register
    control_register cr1(clk, creg_wr, int_data_out, c0_ctrl, c1_ctrl, c2_ctrl);
    
    // Counter 0
    counter c0(clk, gate0, c0_wr, int_data_out, c0_ctrl, out0);
    
    // Counter 1
    counter c1(clk, gate1, c1_wr, int_data_out, c1_ctrl, out1);
    
    // Counter 2
    counter c2(clk, gate2, c2_wr, int_data_out, c2_ctrl, out2);
    
endmodule
