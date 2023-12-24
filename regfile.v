module regfile (output reg [31:0] readData1,readData2,
input clk,write,
input wire [4:0] readReg1,readReg2,writeReg,
input wire [31:0] writeData);

integer i;
reg [31:0] registers [31:0];

//initial block for setting all registers to 0
initial begin 
for(i=0; i<32; i=i+1)
    registers[i]=0;
end

//always block for reading from registers and writing to registers
always @(posedge clk) begin
    readData1<=registers[readReg1];
    readData2<=registers[readReg2];
    if(write)
        registers[writeReg]<=writeData;
    
end
endmodule
