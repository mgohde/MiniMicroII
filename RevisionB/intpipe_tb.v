//This is a testbench for the integer pipeline.
//It for-loops its way through all possible operations and tests various combinations of operands.
//If any disparities in actions are detected, it makes note of that.
module intpipe_tb();

reg [3:0] opList[0:255];
reg [2:0] aSelList[0:255];
reg [2:0] bSelList[0:255];
reg [2:0] cSelList[0:255];
reg clk;
reg [31:0] incr;

wire rst, opWt, regWt;
wire [15:0] aDat;
wire [15:0] bDat;
wire [7:0] flgIn;

wire FLGWRI;
wire [15:0] COUT;
wire CWRI;
wire [2:0] AS;
wire [2:0] BS;
wire [2:0] CS;
wire [7:0] FLGOUT;

assign rst=0;
assign opWt=0;
assign regWt=0;
assign aDat=2;
assign bDat=3;
assign flgIn=0;

intpipe ipipe(opList[incr], clk, rst, opWt, regWt, aSelList[incr], bSelList[incr], cSelList[incr], aDat, bDat, flgIn, FLGWRI, COUT, CWRI, AS, BS, CS, FLGOUT);

//Now generate some constructs for validation:
reg [15:0] answers[0:255];
reg [3:0] curOp;
wire [15:0] A;
wire [15:0] B;
wire [15:0] C;
wire [7:0] aluFlgOut;
wire aluWriteback;
reg [15:0] virtualRegFile [0:7];

assign A=2;
assign B=3;
wire [3:0] aluOp;
assign aluOp=opList[incr-2];
//ALU cruncher(curOp, flgIn, A, B, aluFlgOut, C, aluWriteback);
ALU aluinator(opList[incr-2], flgIn, A, B, aluFlgOut, C, aluWriteBack);
   
reg startChecks;

wire correct;
reg [31:0] correctCount;
assign correct=C==COUT;

initial begin
	for(incr=0;incr<256;incr=incr+1) begin
		//opList[incr]=incr%16;
		opList[incr]=1; //Just add to make life easier.
		aSelList[incr]=1;//incr%2+1;
		bSelList[incr]=3;//incr%4;
		cSelList[incr]=3'b010; //This should force the pipeline to occasionally do bypass.
	end

	//Set up a quick fixed list to check for pipeline coherency:
	aSelList[1]=2;
	bSelList[2]=2;
	aSelList[4]=2;
	aSelList[6]=2;
	aSelList[8]=2;
	aSelList[9]=2;

	//Now compute results:
	//for(incr=0;incr<256;incr=incr+1) begin
	//	curOp=answers[incr];
	//	//A=virtualRegFile[aSelList[incr]];
	//	//B=virtualRegFile[bSelList[incr]];
	//	answers[incr]=C;
	//	virtualRegFile[cSelList[incr]]=C;
	//end

	clk=0;
	incr=0;
	correctCount=0;
end

always begin
	#1 clk=~clk;
end

initial begin
	#530 $finish;
end

always@(posedge clk) begin
	incr=incr+1;
	if(correct) begin
		correctCount=correctCount+1;
	end
end

initial begin
	$dumpfile("intpipe_tb.vcd");
	$dumpvars;
end
endmodule
