//This module implements the instruction cache's hashing function.
//It's placed in a separate module to allow for greater flexibility later on.
module instructionhasher(
	addr,
	OUT
	);

input [31:0] addr;
output [5:0] OUT;

wire [28:0] adjustedAddr;
assign adjustedAddr=addr[31:2];

assign OUT=adjustedAddr%64; //Don't bother with associativity yet.

endmodule