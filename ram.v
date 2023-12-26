module DATA_MEMORY(
input clk,
input we,
input [8:0] addr,
input [31:0] din,
output reg [31:0] dout
);

reg [31:0] RAM [511:0];

always @(posedge clk)
begin
if(we)
RAM[addr] = din;
else
dout = RAM[addr];
end

endmodule