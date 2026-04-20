module counter (
    input clk,
    input gate,
    input ctr_wr,    // Count value write (still needed)
    input [7:0] data_in,
    input [7:0] control_word,  // Direct control word input
    output reg out
);
    reg [7:0] count;
    // Store count value
    always @(posedge clk) begin
        if (ctr_wr) begin
            count <= data_in;
            out <= 0;  // Reset output when new count is loaded
        end
    end
    // Mode 0 operation using direct control word input
    always @(posedge clk) begin
        if (gate && count > 0) begin
            count <= count - 1;
            if (count == 1)
                out <= 1;
        end
    end
endmodule
