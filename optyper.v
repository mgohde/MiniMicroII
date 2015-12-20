//This unit determines the category of operation requested of the Branch/Memory Unit.
module optyper(
	OP,
	load,
	store,
	branch,
	cmp,
	stack,
	ldl//,
	//call
	);

input [6:0] OP;
output load;
output store;
output branch;
output cmp;
output stack;
output ldl;

assign ldl=(OP==64)||stack;
assign stack=(OP>39)&&(OP<47);
assign branch=(OP>50)&&(OP<55);
assign load=(OP==60)||(OP==43);
assign store=(OP==61)||(OP==42);
assign cmp=(OP==50);

endmodule
