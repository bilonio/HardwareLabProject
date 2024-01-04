`include "datapath.v"
`include "ram.v"
`include "rom.v"
module multicycle 
#(parameter [31:0] INITIAL_PC=32'h00400000,
parameter [6:0] SW=7'b0100011,
LW=7'b0000011
,IMMEDIATE=7'b0010011,
BEQ=7'b1100011,
RR=7'b0110011,
parameter [2:0] IF=3'b000,
ID=3'b001,
EX=3'b010,
MEM=3'b011,
WB=3'b100)

(output wire [31:0] PC,dAddress,dWriteData,WriteBackData,
output reg MemRead,MemWrite,
input clk,rst,
input wire [31:0] instr,dReadData
);

reg alusrc,regwrite,memtoreg,loadpc,pcsrc;
reg [2:0] current_state,next_state;
wire zero;
reg [3:0] aluctrl;

datapath  #(.INITIAL_PC(INITIAL_PC)) U0(
  .PC(PC),
  .instr(instr),
  .dAddress(dAddress),
  .dReadData(dReadData),
  .dWriteData(dWriteData),
  .ALUSrc(alusrc),
  .ALUCtrl(aluctrl),
  .RegWrite(regwrite),
  .MemToReg(memtoreg),
  .loadPC(loadpc),
  .Zero(zero),
  .PCSrc(pcsrc),
  .clk(clk),
  .rst(rst),
  .WriteBackData(WriteBackData)
);

always @(posedge clk or posedge rst)
begin : STATE_MEMORY 
if(rst)
    current_state <= IF;
else
    current_state <= next_state;
end

always @(current_state)
begin : NEXT_STATE_LOGIC
case(current_state)
IF : next_state <= ID;
ID : next_state <= EX;
EX : next_state <= MEM;
MEM : next_state <= WB;
WB : next_state <= IF;
endcase
end

always @(current_state or instr)
begin : OUTPUT_LOGIC
case(current_state)
IF : begin 
    loadpc <= 0;
    regwrite <= 0;
    pcsrc <= 0;
end
ID : begin 
end
EX : begin 
end
MEM : begin
case(instr[6:0])     
SW : begin 
    MemWrite <= 1; 
    MemRead <= 0;
end
LW : begin 
    MemWrite <= 0; 
    MemRead <= 1;
end 
endcase
end
WB : begin
case(instr[6:0])
LW : begin 
    regwrite <= 1; 
    memtoreg <= 1;
end
BEQ : begin 
    regwrite <= 0; 
    memtoreg <= 0;
    if(zero)
        pcsrc <= 1;
end 
SW : begin
    regwrite <= 0; 
    memtoreg <= 0;
end
default : begin 
    regwrite <= 1; 
    memtoreg <= 0;
end
endcase
loadpc <= 1;
MemRead <= 0;
MemWrite <= 0;
end
endcase
end

always @(instr) begin
case(instr[6:0])
//STORE, LOAD INSTRUCTIONS
SW : begin 
    alusrc <= 1; 
    aluctrl <= 4'b0010; 
end  
LW : begin 
    alusrc <= 1; 
    aluctrl <= 4'b0010; 
end

//BEQ INSTRUCTIONS
BEQ : begin 
    alusrc <= 0; aluctrl <= 4'b0110;     
end

//IMMEDIATE INSTRUCTIONS
IMMEDIATE: begin 
    alusrc <= 1;
    case(instr[14:12])
    3'b000 : aluctrl <= 4'b0010; //ADDI
    3'b010 : aluctrl <= 4'b0111; //SLTI
    3'b100 : aluctrl <= 4'b1101; //XORI
    3'b110 : aluctrl <= 4'b0001; //ORI
    3'b111 : aluctrl <= 4'b0000; //ANDI
    3'b001 : aluctrl <= 4'b1001; //SLLI
    3'b101 : begin
    case(instr[31:25])
    7'b0000000 : aluctrl <= 4'b1000; //SRLI
    7'b0100000 : aluctrl <= 4'b1010; //SRAI
    endcase
    end
    endcase  
end

//REGISTER-REGISTER INSTRUCTIONS
RR: begin
    alusrc <= 0;
    case(instr[31:25])
    7'b0000000 : begin
        case(instr[14:12])
        3'b000 : aluctrl <= 4'b0010; //ADD
        3'b001 : aluctrl <= 4'b1001; //SLL
        3'b010 : aluctrl <= 4'b0111; //SLT
        3'b100 : aluctrl <= 4'b1101; //XOR
        3'b110 : aluctrl <= 4'b0001; //OR
        3'b111 : aluctrl <= 4'b0000; //AND
        3'b101 : aluctrl <= 4'b1000; //SRL
        endcase
    end
    7'b0100000 : begin 
        case(instr[14:12])
        3'b000 : aluctrl <= 4'b0110; //SUB
        3'b101 : aluctrl <= 4'b1000; //SRA
        endcase
    end
    endcase
end
default : begin alusrc <= 0; aluctrl <= 0; end
endcase
end
endmodule 