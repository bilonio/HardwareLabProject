`include "alu.v"
`include "regfile.v"
module datapath 
#(parameter [31:0] INITIAL_PC=32'h00400000)

(output wire Zero, 
output reg [31:0] PC,dAddress,dWriteData,WriteBackData,
input clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC,
input wire [31:0] instr,dReadData,
input wire [3:0] ALUCtrl
);
reg [31:0] rData1,rData2,immediate,store_off,branch_offset,wrbData;
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

initial begin
    PC = INITIAL_PC;
    dAddress = 0;
    dWriteData = 0;
    WriteBackData = 0;
    rData1 = 0;
    rData2 = 0;
    immediate = 0;
    store_off = 0;
    branch_offset = 0;
    wrbData = 0;
    rReg1 = 0;
    rReg2 = 0;
    wReg = 0;
end 

always @(*) begin
    //decoding instructions 
rReg1 = instr[19:15];
rReg2 = instr[24:20];
wReg = instr[11:7];

//for immediate instructions 
immediate = instr[31:20];
immediate = {{20{immediate[11]}},immediate};

//for store instructions
store_off = {instr[31:25], instr[11:7]};
store_off = {{20{store_off[11]}},store_off};

//for branch instructions
branch_offset[4:1] = instr[11:8];
branch_offset[10:5] = instr[30:25];
branch_offset[12] = instr[31];
branch_offset[11] = instr[7];
branch_offset = {{19{branch_offset[12]}},branch_offset,1'b0};
branch_offset = branch_offset<<1; 
end

always @(posedge clk or posedge rst) begin 
//update PC or reset
if(rst) begin 
    PC = INITIAL_PC;
end

else if (loadPC) begin 
if(PCSrc) begin 
    PC = PC+branch_offset;
end
else begin 
    PC = PC+4;
end
end

//mux for deciding the 2nd operand of alu (op2)
if(ALUSrc) begin
    case(ALUCtrl)
    4'b1001, 4'b1000, 4'b1010 : //SLLI, SRLI, SRAI
        rData2 = immediate[4:0];
    4'b0010 : begin 
        if(RegWrite) begin //LW
            rData2 = immediate;
        end
        else rData2 = store_off; //SW
    end
    default : rData2 <= immediate; //ALL OTHER IMMEDIATE 
    endcase
end
else begin
    rData2 <= n2; //RR AND BEQ
end
rData1 <= n1; //FIRST OPERAND IS ALWAYS FROM REGISTER FILE

//mux for writing to register file
if(MemToReg) begin
        wrbData = dReadData;
        WriteBackData = dReadData;
    end
    else begin
        wrbData = alu_res;
        WriteBackData = alu_res;
    end
end
endmodule

