`include "multicycle.v"
`timescale 1ns/1ns

module top_tb;

    // Inputs
    reg clk;
    reg rst;
    
    // Outputs
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire [31:0] WriteBackData;
    wire MemRead;
    wire MemWrite;
    wire [31:0] instr;
    wire [31:0] dReadData;
    
DATA_MEMORY ram(.we(MemWrite),.dout(dReadData),.din(dWriteData),.addr(dAddress[8:0]),.clk(clk));

INSTRUCTION_MEMORY rom(.addr(PC[8:0]),.dout(instr),.clk(clk));

multicycle UUT (
    .PC(PC),
    .dAddress(dAddress),
    .dWriteData(dWriteData),
    .WriteBackData(WriteBackData),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .dReadData(dReadData)
);
    
    // Clock generation
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    
    // Reset generation
    initial begin
        rst = 1;
        #10;
        rst = 0;     
    end
    
    // Test stimulus
initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0,top_tb);
    // Write your test cases here
    #10000;
    $finish;
end


endmodule

