`include "alu.v"
`include "regfile.v"
module datapath 
#(parameter [31:0] INITIAL_PC=32'h00400000,
parameter [6:0] SW=7'b0100011,
LW=7'b0000011
,IMMEDIATE=7'b0010011)

(output wire Zero, 
output reg [31:0] PC,dAddress,dWriteData,WriteBackData,
input clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC,
input wire [31:0] instr,dReadData,
input wire [3:0] ALUCtrl
);
reg [31:0] rData1,rData2;
reg [31:0] immediate,store_off,branch_offset,wrbData,branch_offset_sign;
wire [31:0] alu_res,n1,n2;
reg [4:0] rReg1,rReg2,wReg;



regfile U0(.readData1(n1),
.readData2(n2),
.write(RegWrite),
.writeData(wrbData),
.readReg1(rReg1),
.readReg2(rReg2),
.writeReg(wReg),
.clk(clk)
);

alu U1(.result(alu_res), 
.op1(rData1), 
.op2(rData2),
.alu_op(ALUCtrl),
.zero(Zero)
);

always @(instr) begin 
//decoding instructions 
rReg1 <= instr[19:15];
rReg2 <= instr[24:20];
wReg <= instr[11:7];

//for immediate instructions 
immediate <= {{20{instr[31]}},instr[31:20]};

//for store instructions
store_off <= {{20{instr[31]}},instr[31:25], instr[11:7]};

//for branch instructions
branch_offset_sign <= {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
branch_offset <= branch_offset_sign<<1;
end

always @(*) begin
//mux for deciding the 2nd operand of alu (op2)
if(ALUSrc) begin 
    case(instr[6:0])
    SW : rData2 <= store_off; //SW
    LW : rData2 <= immediate; //LW
    IMMEDIATE : case(ALUCtrl)
    4'b1001, 4'b1000, 4'b1010 : //SLLI, SRLI, SRAI
        rData2 <= immediate[4:0]; 
    default : rData2 <= immediate; //ALL OTHER IMMEDIATE
    endcase
    default : rData2 <= immediate;  
    endcase 
end
else begin
    rData2 <= n2; //RR AND BEQ
end
dWriteData <= n2; 
rData1 <= n1; //first operand is always from register file
end
always @(*) begin
//mux for writing to register file
if(MemToReg) begin
    wrbData <= dReadData;
    WriteBackData <= dReadData;
    end
else begin
    wrbData <= alu_res;
    WriteBackData <= alu_res;
end
dAddress <= alu_res;
end



always @(posedge clk) begin 
//update PC or reset
if(rst) begin 
    PC <= INITIAL_PC;
end

else if (loadPC) begin 
if(PCSrc) begin 
    PC <= PC + branch_offset;
end
else begin 
    PC <= PC + 4;
end
end

end

endmodule

