`include "datapath.v"
`include "ram.v"
module multicycle 
#(parameter [31:0] INITIAL_PC=32'h00400000,
parameter [6:0] SW=7'b0100011,
LW=7'b0000011
,IMMEDIATE=7'b0010011,
BEQ=7'b1100011,
RR=7'b0110011)

(output wire [31:0] PC,dAddress,dWriteData,WriteBackData,
output reg MemRead,MemWrite,
input clk,rst,
input wire [31:0] instr,dReadData
);

reg alusrc,regwrite,memtoreg,loadpc,pcsrc;
wire zero;
reg [3:0] aluctrl;

datapath U0(.PC(PC),
.instr(instr),
.dAddress(dAddress),
.dReadData(dReadData),
.dWriteData(dWriteData),
.ALUSrc(alusrc),
.ALUCtrl(aluctrl),
.RegWrite(regwrite),
.MemToReg(memtoreg),
.loadPC(loadPC),
.Zero(zero),
.PCSrc(pcssrc)
);

DATA_MEMORY ram(.we(MemWrite));


always @(posedge clk) begin
case(instr[6:0])
//STORE, LOAD INSTRUCTIONS
SW : begin regwrite = 0; MemWrite = 1; end  
LW : begin 
    alusrc=1; aluctrl = 4'b0010; regwrite = 1; memtoreg=1; loadpc=1; MemRead = 1;
    end

//BEQ INSTRUCTIONS
BEQ : begin 
    alusrc = 0; aluctrl = 4'b0110; regwrite = 0;
    if(zero)
        pcsrc = 1;
    end

//IMMEDIATE INSTRUCTIONS
IMMEDIATE: begin 
    alusrc=1;
    regwrite = 1;
    loadpc=1;
    case(instr[14:12])
    3'b000 : aluctrl = 4'b0010; //ADDI
    3'b010 : aluctrl = 4'b0111; //SLTI
    3'b100 : aluctrl = 4'b1101; //XORI
    3'b110 : aluctrl = 4'b0001; //ORI
    3'b111 : aluctrl = 4'b0000; //ANDI
    3'b001 : aluctrl = 4'b1001; //SLLI
    3'b101 : begin
    case(instr[31:25])
    7'b0000000 : aluctrl = 4'b1000; //SRLI
    7'b0100000 : aluctrl = 4'b1010; //SRAI
    endcase
    end
    endcase  
end

//REGISTER-REGISTER INSTRUCTIONS
RR: begin
    alusrc = 0;
    regwrite = 1;
    loadpc=1;
    case(instr[31:25])
    7'b0000000 : begin
        case(instr[14:12])
        3'b000 : aluctrl = 4'b0010; //ADD
        3'b001 : aluctrl = 4'b1001; //SLL
        3'b010 : aluctrl = 4'b0111; //SLT
        3'b100 : aluctrl = 4'b1101; //XOR
        3'b110 : aluctrl = 4'b0001; //OR
        3'b111 : aluctrl = 4'b0000; //AND
        3'b101 : aluctrl = 4'b1000; //SRL
        endcase
    end
    7'b0100000 : begin 
        case(instr[14:12])
        3'b000 : aluctrl = 4'b0110; //SUB
        3'b101 : aluctrl = 4'b1000; //SRA
        endcase
    end
    endcase
end
default : begin alusrc = 0; aluctrl = 0; loadpc = 0; regwrite = 0; memtoreg=0; pcsrc = 0; end
endcase
end
endmodule 