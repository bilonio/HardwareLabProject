`include "alu.v"
`include "regfile.v"
module datapath 
#(parameter [31:0] INITIAL_PC=32'h00400000)

(output reg Zero, 
output reg [31:0] PC,dAddress,dWriteData,WriteBackData,
input clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC,
input wire [31:0] instr,dReadData,
input wire [3:0] ALUCtrl
);
reg [31:0] rData1,rData2,immediate,store,branch,branch_offset,wrbData;
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
.alu_op(ALUCtrl)
);



always @(instr) begin 
    //for immediate instructions
    immediate=instr[31:20];
    immediate={{20{immediate[31]}},immediate};
    //for store instructions
    store=instr[31:20];
    store={{20{store[31]}},store};
    //for branch instructions
    branch=instr[31:20];
    branch = {{20{branch[31]}}, branch};
    branch_offset=branch<<1;
    //decoding instructions
    rReg1=instr[19:15];
    rReg2=instr[24:20];
    wReg=instr[11:7];
end


//update PC or reset
always @(posedge clk or rst) begin 
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
end

//mux for deciding the 2nd operand of alu (op2)
always@(posedge clk) begin
if(ALUSrc) begin
    rData2<=immediate;
end
else begin
    rData2<=n2;
end
rData1<=n1;
end




//mux for writing to register file
always @(posedge clk) begin
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
