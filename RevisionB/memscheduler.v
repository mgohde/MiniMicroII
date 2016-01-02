//This is the top level memory interface module. 
//It sets appropriate wait signals when memory accesses occur.
module memscheduler(
	clk,
	rst,
	addr1,
	addr2,
	write1,
	write2,
	dat1,
	dat2,
	memdat,
	WAIT1,
	WAIT2,
	OUT1,
	OUT2
	MEMADDR,
	MEMWRI);

input clk, rst;
input [31:0] addr1;
input [31:0] addr2;
input write1, write2;
input [15:0] dat1;
input [15:0] dat2;
input [15:0] memdat;

always@(posedge clk or posedge rst) begin
end

endmodule
	