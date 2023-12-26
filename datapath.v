`include "alu.v"
`include "regfile.v"
module datapath 
#(parameter [31:0] INITIAL_PC=32'h00400000,
parameter [6:0] SW=7'b0100011,
LW=7'b0000011
,IMMEDIATE=7'b0010011,
BEQ=7'b1100011,
RR=7'b0110011)

(output wire Zero, 
output reg [31:0] PC,dAddress,dWriteData,WriteBackData,
input clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC,
input wire [31:0] instr,dReadData,
input wire [3:0] ALUCtrl
);
reg [31:0] rData1,rData2,immediate,store1,store2,branch1,branch2,branch_offset,wrbData,shamt;
wire [31:0] alu_res,n1,n2;
reg [4:0] rReg1,rReg2,wReg;

regfile U0(.readData1(n1),
.readData2(n2),
.write(RegWrite),
.writeData(wrbData),
.readReg1(rReg1),
.readReg2(rReg2),
.writeReg(wReg)
);

alu U1(.result(alu_res), 
.op1(rData1), 
.op2(rData2),
.alu_op(ALUCtrl),
.zero(Zero)
);



always @(posedge clk or posedge rst) begin 
//update PC or reset
if(rst) begin 
    PC=INITIAL_PC;
end

else if (loadPC) begin 
if(PCSrc) begin 
    PC=PC+branch_offset;
end
else begin 
    PC=PC+4;
end
end

//decoding instructions 
rReg1=instr[19:15];
rReg2=instr[24:20];
wReg=instr[11:7];

//for immediate instructions 
immediate=instr[31:20];
immediate={{20{immediate[31]}},immediate};

//for immediate shift instructions
shamt=instr[24:20];
shamt={{27{shamt[24]}},shamt};

//for store instructions
store1=instr[11:7];
store1={{27{store1[11]}},store1};

store2 = instr[11:5];
store2={{25{store2[11]}},store2};

//for branch instructions
branch1=instr[11:7];
branch1 = {{27{branch1[11]}}, branch1};

branch2 = instr[31:25];
branch2 = {{25{branch2[31]}}, branch2};
branch2 = branch2 << 5;

branch_offset = branch1 | branch2 ;
branch_offset = {{20{branch_offset[11]}},branch_offset};
branch_offset = branch_offset<<1;

//mux for deciding the 2nd operand of alu (op2)
if(ALUSrc) begin
    rData2<=immediate;
end
else begin
    rData2<=n2;
end
rData1<=n1;

//mux for writing to register file
if(MemToReg) begin
        wrbData=dReadData;
        WriteBackData=dReadData;
    end
    else begin
        wrbData=alu_res;
        WriteBackData=alu_res;
    end
end
endmodule
