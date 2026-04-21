`include "rw_logic.v"
`include "control_register.v"
`include "counter.v"
`include "data_bus_buffer.v"

module intel_8254_simplified (
    input clk,
    input wr, rd, cs,        // write operation, read operation (not used) chip select 
    input a1, a0,            // used in rw operation to select the counter using their enables 
    input [7:0] data_in,
    output [7:0] data_out,
    input gate0, gate1, gate2,  // gate for each counter => gate = 1 continue counting, gate = 0 stop counting 
    output out0, out1, out2     // out signal for each counter 
);

    // declare write enables for counter 0, 1, 2 and control register 
    wire ctr0_wr, ctr1_wr, ctr2_wr, ctrl_reg_wr;
    // wires for storing control word for each counter 
    wire [7: 0] ctr0_control, ctr1_control, ctr2_control;

    rw_logic rw1(cs, wr, a1, a0, ctr0_wr, ctr1_wr, ctr2_wr, ctrl_reg_wr);

    wire [7: 0] int_data_out;
    // now pass the cpu data into the internal data bus buffer 
    data_bus_buffer bus_buff(data_in, int_data_out);
    assign data_out = int_data_out;

    // now using the control register get the constrol word for each counter => only enabled when creg_wr is high 
    control_register cr(clk, crtl_reg_wr, int_data_out, ctr0_control, ctr1_control, ctr2_control);

    // now call the 3 counters => ctr0, ctr1, ctr2

    counter c0(clk, gate0, ctr0_wr, int_data_out, ctr0_control, out0);   

    counter c1(clk, gate1, ctr1_wr, int_data_out, ctr1_control, out1);

    counter c2(clk, gate2, ctr2_wr, int_data_out, ctr2_control, out2);

endmodule

