`include "alu.v"
`include "decoder.v"
module calc (output reg [15:0] led,
input clk,btnc,btnl,btnu,btnr,btnd,
input wire signed [15:0] sw);
reg  signed [15:0] accumulator;
reg signed [31:0] acc_sign;
reg signed [31:0] sw_sign;
wire  signed [31:0] n0;
wire [3:0] n1;


always @(accumulator or sw)
begin 
    acc_sign <= {{16{accumulator[15]}},accumulator};
    sw_sign <= {{16{sw[15]}},sw};
end

decoder U0 (.F(n1), .A(btnr), .B(btnl), .C(btnc));

alu U1 (.result(n0), 
.op1(acc_sign), 
.op2(sw_sign),
.alu_op(n1));



always @ (posedge clk or posedge btnu)
begin
if(btnu) begin
    accumulator = 0;
    led=0;
end
else if(btnd) begin
    accumulator = n0[15:0];
    led = accumulator;
end
else begin
    accumulator <= accumulator;
    //led<=led; 
end

end

endmodule