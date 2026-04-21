`include "rw_logic.v"
`include "control_register.v"
`include "counter.v"
`include "data_bus_buffer.v"

module intel_8254_mode2 (
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

    // TODO: Instantiate the submodules and connect them according to the Lab Manual.
    // 1. rw_logic
    // 2. data_bus_buffer
    // 3. control_register
    // 4. counter c0, c1, and c2

    // Internal signals (wires) available for your use:
    wire c0_wr, c1_wr, c2_wr, creg_wr;
    wire [7:0] int_data_out;
    wire [7:0] c0_ctrl, c1_ctrl, c2_ctrl;

    // Write your component instantiations and assignments below:
    rw_logic rw1(cs, wr, a1, a0, c0_wr, c1_wr, c2_wr, creg_wr);

    data_bus_buffer d(data_in, int_data_out);
    assign data_out = int_data_out;

    control_register cr(clk, creg_wr, int_data_out, c0_ctrl, c1_ctrl, c2_ctrl);

    counter ctr0(clk, gate0, c0_wr, int_data_out, c0_ctrl, out0);

    counter ctr1(clk, gate1, c1_wr, int_data_out, c1_ctrl, out1);

    counter ctr2(clk, gate2, c2_wr, int_data_out, c2_ctrl, out2);

endmodule
