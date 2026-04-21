module rw_logic (
    input cs,
    input wr,
    input a1,
    input a0,
    output reg ctr0_wr,
    output reg ctr1_wr,
    output reg ctr2_wr,
    output reg ctrl_reg_wr
);
    always @(*) begin
        {ctr0_wr, ctr1_wr, ctr2_wr, ctrl_reg_wr} = 4'b0;
        if (cs & wr) begin
            case ({a1,a0})
                2'b00: ctr0_wr = 1;
                2'b01: ctr1_wr = 1;
                2'b10: ctr2_wr = 1;
                2'b11: ctrl_reg_wr = 1;
            endcase
        end
    end
endmodule

