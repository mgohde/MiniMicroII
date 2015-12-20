//Manages memory and 
//dispatches instructions to the rest of
//the processor.
//This unit doesn't have a proper pipeline,
//rather it is mostly hard-wired combinational logic.
module dispatchu(
  CLK,
  MEMDAT,
  ADAT,
  BDAT,
  CDAT,
  addr,
  memOut,
  memWrite,
  Cout,
  cWrite,
  Asel,
  Bsel,
  Csel,
  intPipeOp,
  intPipeA,
  intPipeB,
  intPipeC
  );
  
input CLK;
input [15:0] MEMDAT;
input [15:0] ADAT;
input [15:0] BDAT;
input [15:0] CDAT;
output [31:0] addr;
output [15:0] memOut;
output memWrite;
output [15:0] Cout;
output cWrite;
output [2:0] Asel;
output [2:0] Bsel;
output [2:0] Csel;
output [3:0] intPipeOp;
output [2:0] intPipeA;
output [2:0] intPipeB;
output [2:0] intPipeC;
  
reg stkpInc, stkpDec, stkpWrite;
wire [31:0] ABBus;
wire [31:0] stkPtrBus;
pointer stackPointer(CLK, stkpInc, stkpDec, ABBus, stkpWrite, stkPtrBus);

reg pcWrite;
wire pcInc, pcDec;
wire [31:0] PCBus;
wire [31:0] pcInputBus [1:0];
wire [31:0] extendedMemoryInputBus; //Allows for rets.
assign extendedMemoryInputBus[31:16]=0;
assign extendedMemoryInputBus[15:0]=MEMDAT;
assign pcInputBus[0]=ABBus;
assign pcInputBus[1]=extendedMemoryInputBus;
reg pcInputSel;
pointer programCounter(CLK, pcInc, pcDec, pcInputBus[pcInputSel], pcWrite, PCBus);

assign ABBus[31:16]=ADAT;
assign ABBus[15:0]=BDAT;

reg [15:0] memOutReg;
assign memOut=memOutReg;

wire [31:0] addrMux[0:2];
//Addressing can either be from:
//1. The program counter.
//2. The AB bus.
//3. The the stack pointer.
assign addrMux[0]=PCBus;
assign addrMux[1]=ABBus;
assign addrMux[2]=stkPtrBus;
reg [1:0] addrMuxSelector;
assign addr=addrMux[addrMuxSelector];

reg [15:0] curVals;
wire [6:0] op;
wire [2:0] a;
wire [2:0] b;
wire [2:0] c;
assign op=curVals[15:9];
assign a=curVals[8:6];
assign b=curVals[5:3];
assign c=curVals[2:0];
assign Asel=a;
assign Bsel=b;
assign Csel=c;
assign intPipeA=a;
assign intPipeB=b;
assign intPipeC=c;

wire [15:0] cOutMux[2:0];
reg [1:0] cSelector;
assign cOutMux[0]=MEMDAT;
assign cOutMux[1]=curVals[14:0];
assign cOutMux[2]=stkPtrBus[15:0];
assign Cout=cOutMux[cSelector];

//Assign out an optyper to get operation types:
wire load, store, branch, cmp, stack, ldl, call, intOp;
optyper ot(op, load, store, branch, cmp, stack, ldl);//, call);
assign intOp=(~load)&&(~store)&&(~branch)&&(~cmp)&&(~stack)&&(~ldl);
//assign cWrite=ldl||(some representative combinational logic.

wire [3:0] intPipeOpSelector[3:0];
assign intPipeOpSelector[0]=0;
assign intPipeOpSelector[1]=op[3:0];
assign intPipeOp=intPipeOpSelector[intOp];

wire fetchNextOp;
assign fetchNextOp=intOp;
//assign pcInc=fetchNextOp;

//Build a comparator so that we can have flags.
wire greater, less, same;
comparator comp(ADAT, BDAT, greater, less, same);

reg gFlag, lFlag, sFlag;

reg memWriteReg;
assign memWrite=memWriteReg;

reg stateReg;
reg cWriteReg;
assign cWrite=cWriteReg;
assign pcInc=~stateReg&&fetchNextOp;
assign pcDec=0;

//This 1-state design is going to be the biggest bottleneck
//to reaching higher clockspeeds.
always@(posedge CLK) begin
  if(stateReg) begin //Second state for actions that require another state.
    stateReg<=1'b0;
    //curVals<=0; //Reset the current thingy.
    addrMuxSelector<=0;
    
    if(op!=44&&op!=45) begin
      curVals<=0; //Reset the current instruction to NOP.
    end
    
    if(op==44) begin //Second half of call; completes the jump.
      
    end
    
    else if(op==45) begin //Second half of ret; completes the jump.
      pcWrite<=0;
    end
    
    else if(stack) begin //Be sure to do the stack register stuff:
      if(store) begin
	memWriteReg<=0;
	stkpDec<=0;
      end
      else begin
	stkpInc<=0;
	cWriteReg<=1;
      end
    end
    
    else if(~stack) begin
      if(store) begin
	memWriteReg<=0;
      end
      
      else begin //I don't think I actually have to do anything.
	cWriteReg<=0;
      end
    end
    
  end //End of state 1 stuff.
  
  //Beginning of state 0 stuff:
  else begin 
    if(fetchNextOp) begin
      addrMuxSelector<=2'b00;
      curVals<=MEMDAT;
      cWriteReg<=0;
      stkpWrite<=0;
      //pcInc<=0;
      pcInputSel<=0;
    end
    
    else if(ldl) begin
      curVals<=0;//MEMDAT;
      cSelector<=1;
      cWriteReg<=1;
    end
    
    else if(cmp) begin
      curVals<=0;//MEMDAT;
      gFlag<=greater;
      lFlag<=less;
      sFlag<=same;
    end
    
    //Now for branches:
    else if(branch) begin
      if(op==51) begin//Unconditional jump
	pcWrite<=1;
	//curVals<=MEMDAT;
	curVals<=0; //Insert a NOP so that we go back to the first state.
      end
      
      else if(op==52) begin //Jump on equal
	if(same) begin
	  pcWrite<=1;
	  curVals<=0; //Same as above.
	end
	
	else begin
	  curVals<=MEMDAT;
	end
	
      end
      
      else if(op==53) begin //Jump on positive
	if(greater) begin
	  pcWrite<=1;
	  curVals<=0;
	end
	
	else begin
	  curVals<=MEMDAT;
	end
      end
      
      else if(op==54) begin //Jump on negative
	if(less) begin
	  pcWrite<=1;
	  curVals<=0;
	end
	
	else begin
	  curVals<=MEMDAT;
	end
      end
    end
    
    //Now catch any stack loads/stores:
    else if(op==40) begin //Store Stack Register
      cSelector<=2;
      cWriteReg<=1;
      curVals<=0;
    end
    
    else if(op==41) begin //Load Stack Register
      stkpWrite<=1;
      curVals<=0;
    end
    
    else if(op==44) begin //Call. This instruction will definitely 
		    //Limit clockspeed potential.
      addrMuxSelector<=2'b10;
      stkpDec<=1;
      //stateReg<=1;
      memOutReg<=PCBus[15:0]; //Write the 16 lowest bits of the program counter.
      memWriteReg<=1;
    end
    
    else if(op==55) begin //Ret
      stkpInc<=1;
      addrMuxSelector<=2'b10;
      pcInputSel<=1; //Set the input to the memory bus.
      pcWrite<=1;
      curVals<=MEMDAT;
    end
    
    //Now for loads/stores:
    else if(stack) begin
      stateReg<=1;
      addrMuxSelector<=2'b10;
      if(store) begin
	memWriteReg<=1'b1;
	stkpDec<=1;
	memOutReg<=CDAT;
      end
      
      else begin
	stkpInc<=1;
      end
    end
    
    else if(~stack) begin
      stateReg<=1;
      addrMuxSelector<=2'b01;
      
      if(store) begin
	memWriteReg<=1'b1;
	memOutReg<=CDAT;
      end
      
      else begin
	cSelector<=0;
	cWriteReg<=1;
      end
    end
  end //End of state 0 stuff.
end

initial begin
  curVals<=0;
  addrMuxSelector<=0;
  stateReg<=0;
  memWriteReg<=0;
  memOutReg<=0;
  cSelector<=0;
  cWriteReg<=0;
  pcWrite<=0;
end

endmodule