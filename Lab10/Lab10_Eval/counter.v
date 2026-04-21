module counter (
    input clk,
    input gate,
    input ctr_wr,
    input [7:0] data_in,
    input [7:0] control_word,
    output reg out
);

    // Internal state registers for tracking the count and load sequence
    reg [15:0] count;
    reg [15:0] reload_value;
    
    // State flag for 16-bit read/write operations
    reg byte_state;

    wire [1:0] rw_mode = control_word[5:4];
    wire [2:0] mode = control_word[3:1];

    // Check if the configured mode corresponds to Rate Generator
    wire valid_mode = (mode == 3'b010 || mode == 3'b110);
    //Note that valid_mode is checked for both values 2,6 for mode 2, no need to change anything here
    initial begin
        // TODO: Set initial states for your internal variables: count, reload_value, byte_state, out
        count <= 16'b0;
        reload_value <= 16'b0;
        byte_state <= 1'b0;
        out <= 1;
    end

    always @(posedge clk) begin
        if (ctr_wr) begin
            // TODO: Implement the count load logic based on rw_mode
            // Ensure you handle the two-byte load sequence correctly
            
            if (rw_mode == 2'b01) begin 
                count <= {8'b0, data_in};
                reload_value <= {8'b0, data_in};
                out <= 1;
            end 
            else if (rw_mode == 2'b10) begin 
                count <= {data_in, 8'b0};
                reload_value <= {data_in, 8'b0};
                out <= 1;
            end 
            else if (rw_mode == 2'b11) begin 
                if (byte_state == 0) begin
                    count <= {8'b0, data_in};
                    reload_value <= {8'b0, data_in};
                    byte_state <= 1;
                end 
                else begin
                    count <= {data_in, reload_value[7:0]};
                    reload_value[15:8] <= data_in;
                    out <= 1;
                end
            end
        end
        else if (valid_mode) begin // Counting happens only in Mode 2
            // TODO: Implement the core Mode 2 counting and output logic
            // Consider what happens when the count reaches the terminal value
            if (gate) begin
                if(count > 1) begin 
                    count <= count - 1;
                    out <= 1;
                end 
                else begin 
                    out <= 0;
                    count <= reload_value;
                end
            end 
            else begin
                out <= 1;
            end  
        end 
        else begin
            // Not a valid mode (not Mode 2), so we do not count down
            out <= 1;
        end
    end
endmodule