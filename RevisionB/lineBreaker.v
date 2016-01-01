//This unit breaks down each cache line into its individual operations.
module lineBreaker(sel, cacheLine, OUT);

input [1:0] sel;
input [63:0] cacheLine;
output [15:0] out;

wire [15:0] block0;
wire [15:0] block1;
wire [15:0] block2;
wire [15:0] block3;

//The cache fills lines bottom to top:
//(Implemented with separate wires for debugging)
assign block0=cacheLine[15:0];
assign block1=cacheLine[31:16];
assign block2=cacheLine[47:32];
assign block3=cacheLine[63:48];

wire [15:0] blockMux [0:3];

assign blockMux[0]=block0;
assign blockMux[1]=block1;
assign blockMux[2]=block2;
assign blockMux[3]=block3;

assign out=blockMux[sel];

endmodule
