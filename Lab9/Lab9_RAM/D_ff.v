module D_ff(
    input clk, input chipSelect, input reset, input regWrite, input enable, input d, 
    output reg q
);
    // we write a positive edge triggered d flipflops 

    // enable => d ff only works when enable is HIGH
    // reset => q gets cleared to 0 when reset is HIGH
    // The FF only captures d when: chipSelect = 1 AND enable = 1 AND regWrite = 1

    always @(posedge clk) begin
        if(chipSelect == 1'b1 && reset == 1'b1) begin 
            q <= 1'b0;
        end 
        else if(chipSelect == 1'b1 && enable == 1'b1 && regWrite == 1'b1) begin 
            q <= d;
        end
    end

endmodule