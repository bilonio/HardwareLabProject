`include "regfile.v"
`timescale 1ns/1ns

module regfile_tb;

    // Declare signals
    reg [4:0] readReg1, readReg2;
    wire [31:0] readData1, readData2;
    reg [4:0] write_addr;
    reg [31:0] writeData;
    
    // Instantiate the regfile module
    regfile dut (readData1, readData2, clk, write_enable, readReg1, readReg2, write_addr, writeData);
    
    
    // Clock generation
    reg clk;
    always #5 clk = ~clk;
    
    
    
    // Write enable generation
    reg write_enable;
    initial begin
        write_enable = 0;
        #20 write_enable = 1;
    end
    
    // Write address and data generation
    
    initial begin
        write_addr = 2;
        writeData = 32'h12345678;
        #30 write_addr = 3;
        writeData = 32'hABCDEF01;
        #40 write_addr = 4;
        writeData = 32'h87654321;
        #50 write_addr = 5;
        writeData = 32'hFEDCBA98;
        #60 write_addr = 6;
        writeData = 32'h24681357;
    end
    
    // Testbench logic
    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0,regfile_tb);
        clk=0;
        // Read from registers
        #70 readReg1 = 2;
        #80 readReg2 = 3;
        #90 readReg1 = 4;
        #100 readReg2 = 5;
        #110 readReg1 = 6;
        #120 readReg2 = 7;
        
        // Display register values
        #130 $display("Register 2: %h", readData1);
        #140 $display("Register 3: %h", readData2);
        #150 $finish;
    end
    
endmodule
