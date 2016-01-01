//Defines an integer pipeline that can attempt to do internal dependency resolution.
//By shifting execution to individual components, the revision B core
//should be easier to debug.

module intpipe(op, clk, rst, opWt, regWt, aSel, bSel, cSel, aDat, bDat, flgIn, FLGWRI, COUT, CWRI, AS, BS, CS, FLGOUT);

input [3:0] op;
input clk;
input rst;
//Wait signals for operations and the register file.
input opWt;
input regWt;
input [2:0] aSel;
input [2:0] bSel;
input [2:0] cSel;
input [15:0] aDat;
input [15:0] bDat;
input [7:0] flgIn;
output [15:0] COUT;
output [2:0] AS;
output [2:0] BS;
output [2:0] CS;
output CWRI; 
output FLGWRI;
output [7:0] FLGOUT;

assign AS=aSel;
assign BS=bSel;

//Now create some internal signals/shifters:
reg [3:0] opShifter[2:0]; //Fetch/data resolve, execute, writeback.
reg [2:0] destShifter[2:0]; //So that we can keep track of where each op wants to write.
reg [15:0] operandA;
reg [15:0] operandB;
reg [15:0] operandC;
reg cwr;

wire [2:0] dest0;
wire [2:0] dest1;
wire [2:0] dest2;
assign dest0=destShifter[0];
assign dest1=destShifter[1];
assign dest2=destShifter[2];

assign CS=destShifter[2];
assign CWRI=cwr;

wire [15:0] aluOut;
wire [7:0] flgs;
wire aluWriteback;
reg [7:0] curFlgs;
assign COUT=aluOut;

wire [3:0] curOp;
assign curOp=opShifter[1];

//wire [15:0] aluA [0:1];
//wire [15:0] aluB [0:1];
//assign aluA[0]=operandA;
//assign aluB[0]=operandB;
//assign aluA[1]=operandC;
//assign aluB[1]=operandC;

wire aluASelect;
wire aluBSelect;

assign aluASelect=(aSel==destShifter[1]);//||(aSel==destShifter[1]);
assign aluBSelect=(bSel==destShifter[1]);//||(bSel==destShifter[1]);

//This is so that ALU data can be checked:
//wire [15:0] a;
//wire [15:0] b;

//assign a=aluA[aluASelect];
//assign b=aluB[aluBSelect];

ALU crunchinator(opShifter[1], curFlgs, operandA, operandB, flgs, aluOut, aluWriteback);

always@(posedge clk) begin
	//First, check whether we should shift:
	if(~opWt&&~regWt) begin //TODO: consider converting to inverted or.
		opShifter[0]<=op;
		opShifter[1]<=opShifter[0];
		opShifter[2]<=opShifter[1];

		destShifter[0]<=cSel;
		destShifter[1]<=destShifter[0];
		destShifter[2]<=destShifter[1];
	end

	//Now do some general stuff:
	cwr<=aluWriteback;

	//operandA<=aDat;
	//operandB<=bDat;
	operandC<=aluOut;

	if(aluASelect) begin //aSel==destShifter[1]) begin
		operandA<=aluOut;
	end

	//This must be exclusive with the above.
	//else if(aSel==destShifter[1]) begin
	//	operandA<=operandC;
	//end

	else begin
		operandA<=aDat;
	end

	if(aluBSelect) begin//bSel==destShifter[1]) begin
		operandB<=aluOut;
	end

	//else if(bSel==destShifter[1]) begin
	//	operandB<=operandC;
	//end

	else begin
		operandB<=bDat;
	end
	//There need not be anything to handle writebacks if there's a stall, because the pipe
	//will simply freeze.
end

initial begin
	destShifter[0]=0;
	destShifter[1]=0;
	destShifter[2]=0;
end
endmodule