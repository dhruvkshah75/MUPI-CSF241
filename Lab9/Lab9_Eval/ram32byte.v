`ifndef RAM32BYTE_V
`define RAM32BYTE_V

`include "decoder4to16.v"
`include "register8bit.v"
`include "mux32to2.v"
`include "mux2to1_16bits.v"

// 32-Byte RAM: 16 locations × 16-bit words (Big-Endian)
module ram32byte(input clk, input chipSelect, input reset, input outputEnable, input writeEnable,
                 input [3:0] address, input [15:0] writeData, output [15:0] memOut);

    wire [7:0] Dmem0,  Dmem1,  Dmem2,  Dmem3,  Dmem4,  Dmem5,  Dmem6,  Dmem7,
               Dmem8,  Dmem9,  Dmem10, Dmem11, Dmem12, Dmem13, Dmem14, Dmem15,
               Dmem16, Dmem17, Dmem18, Dmem19, Dmem20, Dmem21, Dmem22, Dmem23,
               Dmem24, Dmem25, Dmem26, Dmem27, Dmem28, Dmem29, Dmem30, Dmem31;

    wire [15:0] decOut;
    wire [15:0] memReadOut;

    // TODO 1: Instantiate a 4-to-16 decoder to decode the address into write enables.
    decoder4to16 d4(address, decOut);

    // TODO 2: Instantiate 16 pairs of 8-bit registers (for locations 0-15).
    //         Each pair corresponds to a 16-bit word (Big-Endian).
    //         Use the decoder outputs to enable the appropriate registers during a write.
    register8bit rMem0(clk, chipSelect, reset, writeEnable, decOut[0], writeData[15:8], Dmem0);
    register8bit rMem1(clk, chipSelect, reset, writeEnable, decOut[0], writeData[7:0], Dmem1);

    register8bit rMem2(clk, chipSelect, reset, writeEnable, decOut[1], writeData[15:8], Dmem2);
    register8bit rMem3(clk, chipSelect, reset, writeEnable, decOut[1], writeData[7:0], Dmem3);

    register8bit rMem4(clk, chipSelect, reset, writeEnable, decOut[2], writeData[15:8], Dmem4);
    register8bit rMem5(clk, chipSelect, reset, writeEnable, decOut[2], writeData[7:0], Dmem5);

    register8bit rMem6(clk, chipSelect, reset, writeEnable, decOut[3], writeData[15:8], Dmem6);
    register8bit rMem7(clk, chipSelect, reset, writeEnable, decOut[3], writeData[7:0], Dmem7);

    register8bit rMem8(clk, chipSelect, reset, writeEnable, decOut[4], writeData[15:8], Dmem8);
    register8bit rMem9(clk, chipSelect, reset, writeEnable, decOut[4], writeData[7:0], Dmem9);

    register8bit rMem10(clk, chipSelect, reset, writeEnable, decOut[5], writeData[15:8], Dmem10);
    register8bit rMem11(clk, chipSelect, reset, writeEnable, decOut[5], writeData[7:0], Dmem11);

    register8bit rMem12(clk, chipSelect, reset, writeEnable, decOut[6], writeData[15:8], Dmem12);
    register8bit rMem13(clk, chipSelect, reset, writeEnable, decOut[6], writeData[7:0], Dmem13);

    register8bit rMem14(clk, chipSelect, reset, writeEnable, decOut[7], writeData[15:8], Dmem14);
    register8bit rMem15(clk, chipSelect, reset, writeEnable, decOut[7], writeData[7:0], Dmem15);

    register8bit rMem16(clk, chipSelect, reset, writeEnable, decOut[8], writeData[15:8], Dmem16);
    register8bit rMem17(clk, chipSelect, reset, writeEnable, decOut[8], writeData[7:0], Dmem17);

    register8bit rMem18(clk, chipSelect, reset, writeEnable, decOut[9], writeData[15:8], Dmem18);
    register8bit rMem19(clk, chipSelect, reset, writeEnable, decOut[9], writeData[7:0], Dmem19);

    register8bit rMem20(clk, chipSelect, reset, writeEnable, decOut[10], writeData[15:8], Dmem20);
    register8bit rMem21(clk, chipSelect, reset, writeEnable, decOut[10], writeData[7:0], Dmem21);

    register8bit rMem22(clk, chipSelect, reset, writeEnable, decOut[11], writeData[15:8], Dmem22);
    register8bit rMem23(clk, chipSelect, reset, writeEnable, decOut[11], writeData[7:0], Dmem23);

    register8bit rMem24(clk, chipSelect, reset, writeEnable, decOut[12], writeData[15:8], Dmem24);
    register8bit rMem25(clk, chipSelect, reset, writeEnable, decOut[12], writeData[7:0], Dmem25);

    register8bit rMem26(clk, chipSelect, reset, writeEnable, decOut[13], writeData[15:8], Dmem26);
    register8bit rMem27(clk, chipSelect, reset, writeEnable, decOut[13], writeData[7:0], Dmem27);

    register8bit rMem28(clk, chipSelect, reset, writeEnable, decOut[14], writeData[15:8], Dmem28);
    register8bit rMem29(clk, chipSelect, reset, writeEnable, decOut[14], writeData[7:0], Dmem29);

    register8bit rMem30(clk, chipSelect, reset, writeEnable, decOut[15], writeData[15:8], Dmem30);
    register8bit rMem31(clk, chipSelect, reset, writeEnable, decOut[15], writeData[7:0], Dmem31);



    // TODO 3: Instantiate a 32-to-2 byte multiplexer to select the correct bytes for reading based on the address.
    mux32to2 m32to2(Dmem0, Dmem1, Dmem2, Dmem3, Dmem4, Dmem5, Dmem6, Dmem7, Dmem8, Dmem9, Dmem10, Dmem11, 
                    Dmem12, Dmem13, Dmem14, Dmem15, Dmem16, Dmem17, Dmem18, Dmem19, Dmem20, Dmem21, Dmem22,
                    Dmem23, Dmem24, Dmem25, Dmem26, Dmem27, Dmem28, Dmem29, Dmem30, Dmem31, 
                    address, memReadOut);

    // TODO 4: Instantiate a 2-to-1 16-bit multiplexer to drive memOut based on (outputEnable & chipSelect).
    mux2to1_16bits m2to1(16'b0, memReadOut, outputEnable & chipSelect, memOut);

endmodule

`endif
