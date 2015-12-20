//aluOpU -- Determines whether a set of pipeline stages are to be sent an ALU operation.
module aluOpU(
  OP1,
  OP2,
  OP3,
  OP4,
  OP5,
  aluOp
  );
  
input [6:0] OP1;
input [6:0] OP2;
input [6:0] OP3;
input [6:0] OP4;
input [6:0] OP5;
output [4:0] aluOp;

assign aluOp[0]=OP1<11&&(OP1!=0); //Note that the ALU can handle NOPs in and of itself, but this wire is also used
			//to determine writeback behavior.
assign aluOp[1]=OP2<11&&OP2!=0;
assign aluOp[2]=OP3<11&&OP3!=0;
assign aluOp[3]=OP4<11&&OP4!=0;
assign aluOp[4]=OP5<11&&OP5!=0;
endmodule