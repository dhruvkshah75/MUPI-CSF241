`ifndef ROM32BYTE_V
`define ROM32BYTE_V

// 32-Byte ROM: 16 × 16-bit read-only locations, pre-loaded in an initial block.
module rom32byte(input outputEnable, input chipSelect, input [3:0] address, output reg [15:0] dataOut);

    // TODO: declare internal memory storage (16 locations of 16-bits each)
    // Hint: Do not instantiate actual registers with write and clock disabled.
    // Instead, use an internal 2D array structure.
    wire [15:0] rom [0:15];


    // TODO: initialize the ROM with 16 16-bit values
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1) begin 
            assign rom[i] = 16'hAA00 + i + 1;
        end 
    endgenerate


    always @(outputEnable, chipSelect, address) begin
        // TODO: Map address to the correct ROM output based on chipSelect and outputEnable
        if(chipSelect == 1'b1 && outputEnable == 1'b1) begin 
            dataOut = rom[address];
        end
        else begin 
            dataOut = 16'b0;
        end
    end

endmodule

`endif
