`include "calc.v"
`timescale 1ns/1ns
module calc_tb;
reg clk,btnc,btnl,btnu,btnr,btnd;
reg signed [15:0] sw;
wire [15:0] led;

calc DUT(led,clk,btnc,btnl,btnu,btnr,btnd,sw);


    

initial begin
$dumpfile("calc_tb.vcd");
$dumpvars(0,calc_tb);


clk=1'b0;
btnd=0;
btnu = 1'b0;

btnd=1;
btnl=0;
btnc=0;
btnr=0;
sw=16'h0000;
#10 btnu=1;



#10;
btnd=1;
btnu=0;
btnl=0;
btnc=1;
btnr=1;
sw=16'h1234;


#10;
btnl=0;
btnc=1;
btnr=0;
sw=16'h0ff0;

#10;
btnl=0;
btnc=0;
btnr=0;
sw=16'h324f;

#10;
btnl=0;
btnc=0;
btnr=1;
sw=16'h2d31;

#10;
btnl=1;
btnc=0;
btnr=0;
sw=16'hffff;

#10;
btnl=1;
btnc=0;
btnr=1;
sw=16'h7346;

#10;
btnl=1;
btnc=1;
btnr=0;
sw=16'h0004;

#10;
btnl=1;
btnc=1;
btnr=1;
sw=16'h0004;

#10;
btnl=1;
btnc=0;
btnr=1;
sw=16'hffff;

$display("Test complete");
$finish();

end

always begin 
        #5 clk=~clk;
    end
endmodule