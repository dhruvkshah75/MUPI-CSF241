module rw_logic (
    input cs,      // chip select => cs = 0 then ignore everything 
    input wr,      // write signal => wr = 0 no write operation happens 
    input a1, a0,  // a1, a0 are address lines => used to select internal registers 

    // now the ouputs 
    output ctr0_wr, ctr1_wr, ctr2_wr, ctrl_reg_wr;
    // This write enable signals => only one of them becomes 1 at the same time 
    // eg ctr0_wr = 1 -> write to counter 0 or ctrl_reg_wr = 1 -> write control word 
);

    always @(*) begin 
        {ctr0_wr, ctr1_wr, ctr2_wr, ctrl_reg_wr} = 4'b0;
        // make all the enables for their respective counter or register as only one of them is 1 at a time 
        if(cs & wr) begin 
            case({a1, a0})
                2'b00: ctr0_wr = 1;
                2'b01: ctr1_wr = 1;
                2'b10: ctr2_wr = 1;
                2'b11: ctrl_reg_wr = 1;
            endcase 
        end
    end


endmodule 
/*
    A1 A0   Select 
    0  0    Counter 0
    0  1    Counter 1 
    1  0    Counter 2
    1  1    Control register 
*/