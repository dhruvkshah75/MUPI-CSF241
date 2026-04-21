module counter(
    input clk,                // the clock signal 
    input gate,               // gate pin => gate = 1 counting is allowed and gate = 0 => counter is paused 
    input ctr_wr,             // => counter wire signal => when this is high load a new count value in the counter 
    input [7: 0] data_in,     // the value to load in the counter 
    input [7: 0] control_word // This is the control word => since this is mode 0 so no decoding of a mode is required 
    output reg out            // output signal of the counter => out pin 
);

    // Now the internal logic 
    reg [7: 0] count;

    always @(posedge clk) begin 
        if(ctr_wr) begin 
            count <= data_in;
            out <= 0;  // writing count => OUT goes low immediatelty
        end
    end

    // second always block is decrementing the count 
    always @(posedge clk) begin 
        if(gate && count > 0) begin 
            count <= count - 1;
            // in mode 0 when count becomes 0 then OUT becomes high 
            if(count == 1) begin 
                out <= 1;
            end
        end
    end

endmodule

