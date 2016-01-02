//This unit executes and schedules all instruction fetch and flow control operations.
//It provides an interface to both an instruction cache and RAM. It is expected that
//the highest level CPU module provide appropriate memory lock signals.

module fetchdispatchunit(
	clk,
	rst,
	memWait,
	cacheWait,
	regWait,
	aDat,
	bDat,
	cDat,
	memIn,
	cacheDat,
	COUT,
	CWRI,
	MEMADDR,
	OPADDR,
	MEMOUT,
	MEMWRI,
	AS,
	BS,
	CS,
	P0_OP,
	P0_ASEL,
	P0_BSEL,
	P0_CSEL,
	P0_OPWAIT
	
	);


input clk, rst, memWait, cacheWait, regWait;
input [15:0] aDat;
input [15:0] bDat;
input [15:0] cDat;
input [15:0] memIn;
input [63:0] cacheDat;
output [15:0] COUT;
output [31:0] MEMADDR;
output [31:0] OPADDR;
output [15:0] MEMOUT;
output MEMWRI;
output [2:0] AS;
output [2:0] BS;
output [2:0] CS;
//Start first pipeline port. There will be more!
output [3:0] P0_OP; 
output [2:0] P0_ASEL;
output [2:0] P0_BSEL;
output [2:0] P0_CSEL;
output P0_OPWAIT;

//Create some internal dataflow:
reg [31:0] programCounter;
reg [31:0] stackPointer;
wire [15:0] curOp;
wire [1:0] curOffset;

assign curOffset=programCounter[1:0]; //Or %4, but this is clearer.
lineBreaker clbr(curOffset, cacheDat, curOp);

reg [15:0] bufferedControlOp;

//Add some wirey decoding for the op:
//Most instructions are formatted as follows:
//0000:0000:0000:0000
//IIII IIIA AABB BCCC
wire [6:0] opCode;
wire [2:0] operA;
wire [2:0] operB;
wire [2:0] operC;
assign operC=bufferedControlOp[2:0];
assign operB=bufferedControlOp[5:3];
assign operA=bufferedControlOp[8:6];
assign opCode=bufferedControlOp[15:9];

//Add decoding logic for the current, non-buffered instruction:
wire [6:0] curOpCode;
wire [2:0] curOperA;
wire [2:0] curOperB;
wire [2:0] curOperC;
assign curOperC=curOp[2:0];
assign curOperB=curOp[5:3];
assign curOperA=curOp[8:6];
assign curOpCode=curOp[15:9];

//LDL instructions are as follows:
//0000:0000:0000:0000
//IDDD DDDD DDDD DDDD
wire [14:0] rawData;
wire ldlBit;
assign ldlBit=curOp[15];
assign rawData=curOp[14:0];

wire [31:0] ABCombined; //32 bit combined A and B register.
assign ABCombined[31:16]=aDat;
assign ABCombined[15:0]=bDat;

//Now set up the logic to determine whether we should dispatch the op to the int pipe:
wire intPipeOp;
assign intPipeOp=curOpCode<11; //NOPs are also included as int ops.

//So that pipelines can be forced to do nothing:
wire [3:0] nullOp;
wire [2:0] nullSel;

reg [3:0] aluOp0;
reg [2:0] aluA0;
reg [2:0] aluB0;
reg [2:0] aluC0;

wire [3:0] P0_opMux [0:1];
wire [2:0] P0_aMux [0:1];
wire [2:0] P0_bMux [0:1];
wire [2:0] P0_cMux [0:1];
reg P0_wait;

assign P0_opMux[1]=aluOp0;
assign P0_opMux[0]=nullOp;
assign P0_aMux[1]=aluA0;
assign P0_aMux[0]=nullSel;
assign P0_bMux[1]=aluB0;
assign P0_bMux[0]=nullSel;
assign P0_cMux[1]=aluC0;
assign P0_cMux[0]=nullSel;

//Schedule ops using combinational logic if possible.
assign P0_OP=P0_opMux[intPipeOp]; 
assign P0_ASEL=P0_aMux[intPipeOp];
assign P0_BSEL=P0_bMux[intPipeOp];
assign P0_CSEL=P0_cMux[intPipeOp];
assign P0_OPWAIT=P0_wait;

//Set up some logic for comparison instructions:
wire grtr, less, same;
reg P, N, E; //To use the jump instruction terminology.
comparator compr(aDat, bDat, grtr, less, same);

wire allWait;
assign allWait=memWait||cacheWait||regWait;

reg [2:0] stateCtr;
wire activeState;
assign activeState=stateCtr!=0;

//Determines whether we want the stack pointer (0) or AB combined (1)
wire memAddrSelector;
//ABCombined is only used for two instructions:
assign memAddrSelector=(opCode==60)||(opCode==61);

wire [31:0] addressMux[0:1];
assign addressMux[0]=stackPointer;
assign addressMux[1]=ABCombined;
assign MEMADDR=addressMux[memAddrSelector];

reg memWriReg;
assign MEMWRI=memWriReg;

reg [15:0] cOutputBuffer;
assign COUT=cOutputBuffer;
reg cWrite;
assign CWRI=cWrite;

reg [15:0] memOutReg;
assign MEMOUT=memOutReg;

//Mux the C select line so that data will be available faster:
wire [2:0] csMux[0:1];
assign csMux[0]=operC;
assign csMux[1]=3'b111;

assign CS=csMux[ldlBit];

assign CS=csReg;
assign AS=operA;
assign BS=operB;

reg [15:0] pcBuffer;

wire [31:0] callPC;
assign callPC=programCounter+1;

reg halted;

always@(posedge clk or posedge rst) begin
	if(rst) begin
		stateCtr<=0;
		programCounter<=0;
		stackPointer<=32'hFFFFFFFF; //We want it to point to the top of RAM.
		aluOp0<=0;
		aluA0<=0;
		aluB0<=0;
		aluC0<=0;
		P0_wait<=0;
		halted<=0;
		cWrite<=0;
		memWriReg<=0;
	end

	else if(~allWait) begin //Only work if there are no wait signals.
		if(stateCtr==0) begin //State 0 is the normal mode of operation.
			//Determine if the current operation should be scheduled on the int pipe or not:
			if(intPipeOp) begin
				aluA0<=curOperA;
				aluB0<=curOperB;
				aluC0<=curOperC;
				aluOp0<=curOpCode;	
			end

			//Otherwise start executing whatever control op needs to be executed.
			else begin
				stateCtr<=1; //This is constant regardless.
				bufferedControlOp<=curOp;
			end
			programCounter<=programCounter+1;
		end

		//----------------BEGIN STATE 1--------------------//
		else if(stateCtr==1) begin
			if(ldlBit) begin //Easiest to handle:
				cWrite<=1;
				cOutputBuffer[14:0]<=rawData;
				cOutputBuffer[15]<=0;
				stateCtr<=2;
			end

			//SSR - 28h
			else if(opCode==40) begin
				cOutputBuffer<=stackPointer[15:0];
				cWrite<=1;
				stateCtr<=2;
			end

			//LSR - 29h
			else if(opCode==41) begin
				stackPointer<=ABCombined;
				stateCtr<=0;
			end

			//PUSH - 2Ah
			else if(opCode==42) begin
				memOutReg<=aDat;
				memWriReg<=1;
				stateCtr<=2;
			end

			//POP - 2Bh
			else if(opCode==43) begin
				stackPointer<=stackPointer+1;
				stateCtr<=2;
			end
		
			//CALL - 2Ch
			else if(opCode==44) begin
				memWriReg<=1;
				memOutReg<=callPC[15:0];
				stateCtr<=0;
			end

			//RET - 2Dh
			else if(opCode==45) begin
				stackPointer<=stackPointer+1;
				stateCtr<=2;
			end

			//CMP - 32h
			else if(opCode==50) begin
				P<=grtr;
				N<=less;
				E<=same;
				stateCtr<=0;
			end

			//JMP - 33h
			else if(opCode==51) begin
				programCounter<=ABCombined;
				stateCtr<=0;
			end

			//JE - 34h
			else if(opCode==52) begin
				if(E) begin
					programCounter<=ABCombined;
				end
				
				stateCtr<=0;
			end

			//JP - 35h
			else if(opCode==53) begin
				if(E) begin
					programCounter<=ABCombined;
				end

				stateCtr<=0;
			end

			//JN - 36h
			else if(opCode==54) begin
				if(N) begin
					programCounter<=ABCombined;
				end

				stateCtr<=0;
			end

			//HLT - 3Bh
			else if(opCode==59) begin
				halted<=1;
				stateCtr<=1; //Infinite loop.
			end

			//LOAD - 3Ch
			else if(opCode==60) begin
				csReg<=operC;
				cWrite<=1;
				cOutputBuffer<=memIn;
				stateCounter<=0;
			end

			//STORE - 3Dh
			else if(opCode==61) begin
				memOutReg<=cDat;
				memWriReg<=1;
			end

			//Insert stubs for LDFLGS and STFLGS here.

		end //---------------- END STATE 1 -----------------------//

		//----------------BEGIN STATE 2--------------------//
		else if(stateCtr==2) begin
			if(ldlBit) begin //Easiest to handle:
				cWrite<=0;
				stateCtr<=0;
			end

			//SSR - 28h
			else if(opCode==40) begin
				cWrite<=0;
				stateCtr<=0;
			end

			//LSR - 29h
			else if(opCode==41) begin
			end

			//PUSH - 2Ah
			else if(opCode==42) begin
				memWriReg<=0;
				stackPointer<=stackPointer-1;
				stateCtr<=0;
			end

			//POP - 2Bh
			else if(opCode==43) begin
				cWrite<=1;
				cOutputBuffer<=memIn;
				
			end
		
			//CALL - 2Ch
			else if(opCode==44) begin
				memOutReg<=callPC[31:16];
				stackPointer<=stackPointer-1;
			end

			//RET - 2Dh
			else if(opCode==45) begin
				stackPointer<=stackPointer+1;
				pcBuffer<=memIn;
			end

			//CMP - 32h
			else if(opCode==50) begin
			end

			//JMP - 33h
			else if(opCode==51) begin
			end

			//JE - 34h
			else if(opCode==52) begin
			end

			//JP - 35h
			else if(opCode==53) begin
			end

			//JN - 36h
			else if(opCode==54) begin
			end

			//HLT - 3Bh
			else if(opCode==59) begin
			end

			//LOAD - 3Ch
			else if(opCode==60) begin
			end

			//STORE - 3Dh
			else if(opCode==61) begin
				memWriReg<=0;
				stateCtr<=0;
			end

			//Insert stubs for LDFLGS and STFLGS here.
		end //---------------- END STATE 2 -----------------------//

		//----------------BEGIN STATE 3--------------------//
		else if(stateCtr==3) begin
			if(ldlBit) begin //Easiest to handle:
			end

			//SSR - 28h
			else if(opCode==40) begin
			end

			//LSR - 29h
			else if(opCode==41) begin
			end

			//PUSH - 2Ah
			else if(opCode==42) begin
			end

			//POP - 2Bh
			else if(opCode==43) begin
				memWrite<=0;
				stateCtr<=0;
			end
		
			//CALL - 2Ch
			else if(opCode==44) begin
				memWriReg<=0;
				stackPointer<=stackPointer-1;
				stateCtr<=0;
			end

			//RET - 2Dh
			else if(opCode==45) begin
				programCounter[31:16]<=memIn;
				stateCtr<=0;
				programCounter[15:0]<=pcBuffer;
			end

			//CMP - 32h
			else if(opCode==50) begin
			end

			//JMP - 33h
			else if(opCode==51) begin
			end

			//JE - 34h
			else if(opCode==52) begin
			end

			//JP - 35h
			else if(opCode==53) begin
			end

			//JN - 36h
			else if(opCode==54) begin
			end

			//HLT - 3Bh
			else if(opCode==59) begin
			end

			//LOAD - 3Ch
			else if(opCode==60) begin
			end

			//STORE - 3Dh
			else if(opCode==61) begin
			end

			//Insert stubs for LDFLGS and STFLGS here.

		end //---------------- END STATE 3 -----------------------//
	end
end

initial begin

end

endmodule