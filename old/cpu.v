//Defines the top level CPU module
//This CPu is pipelined and has the following pipeline stages:
// 0. Fetch -- Instruction is read from the RAM buffer unless the CPU is executing a multi-cycle instruction.
//		In that case, the next op will be 0.
// 1. Data dependency resolve -- All data is copied the appropriate shifter.
// 2. Execute
// 3. Writeback
// 4. (empty stage, used for various memory operations)
//
// As a bit of cover for the quality of this CPU core:
// "Software people design hardware as hardware people write software"
// Take that as you will.
module cpu(
  CLK,
  MEMD,
  MEMRDY,
  addr,
  memDat,
  memWrite,
  hlt
  );
  
input CLK;
input [15:0] MEMD;
input MEMRDY;
output [31:0] addr;
output [15:0] memDat;
output memWrite;
output hlt;

reg halt;
assign hlt=halt;
wire clk;
assign clk=CLK&&~halt;

reg [15:0] memOut;
assign memDat=memOut;
reg memW;
assign memWrite=memW;

//This is the operation shifter that will allow the CPU to complete its tasks:
reg [15:0] opShifter[4:0]; //Five stages should be enough for anybody.
wire [6:0] op1;
wire [6:0] op2;
wire [6:0] op3;
wire [6:0] op4;
wire [6:0] op5;
wire [2:0] aSel2;
wire [2:0] aSel3;
wire [2:0] aSel4;
wire [2:0] bSel2;
wire [2:0] bSel3;
wire [2:0] bSel4;
wire [2:0] cSel2;
wire [2:0] cSel3;
wire [2:0] cSel4;
wire [14:0] literalValue;
pipeBreakU pbru(opShifter[0], opShifter[1], opShifter[2], opShifter[3], opShifter[4], op1, op2, op3, op4, op5, aSel2, aSel3, aSel4, bSel2, bSel3, bSel4, cSel2, cSel3, cSel4, literalValue);

reg [14:0] literalValueIntermediary;

wire [4:0] aluOp;
aluOpU aou(op1, op2, op3, op4, op5, aluOp);

reg [7:0] procFlags; //This generates the set of flags used by the processor.

//Declare the CPU's register file:
reg [15:0] registers[7:0]; //Registers are addressed with 3-bit literals.
//Define some wires so that we can keep track of each register:
wire [15:0] r0;
assign r0=registers[0];
wire [15:0] r1;
assign r1=registers[1];
wire [15:0] r2;
assign r2=registers[2];
wire [15:0] r3;
assign r3=registers[3];
wire [15:0] r4;
assign r4=registers[4];
wire [15:0] r5;
assign r5=registers[5];
wire [15:0] r6;
assign r6=registers[6];
wire [15:0] r7;
assign r7=registers[7];

reg [15:0] aShifter[0:3]; //Make it one shorter than the overall op register.
reg [15:0] bShifter[0:3];

//Again, some debugging values:
wire [15:0] as3;
assign as3=aShifter[3];
wire [15:0] as2;
assign as2=aShifter[2];
wire [15:0] as1;
assign as1=aShifter[1];
wire [15:0] as0;
assign as0=aShifter[0];

wire [15:0] bs3;
assign bs3=bShifter[3];
wire [15:0] bs2;
assign bs2=bShifter[2];
wire [15:0] bs1;
assign bs1=bShifter[1];
wire [15:0] bs0;
assign bs0=bShifter[0];

reg [31:0] abCombined;

//Ensure that the computer can actually compute:
wire [7:0] flagsOut; //This is mostly unused.
reg [7:0] flags;
wire [15:0] aluOut;
wire aluShouldWriteBack;
ALU alu(op3[3:0], procFlags, aShifter[0], bShifter[0], flagsOut, aluOut, aluShouldWriteBack); 
reg [15:0] intermediateResult;

//Make some wires to break the contents of the flags register out:
wire z, c, o, n;
assign z=flags[0];
assign c=flags[1];
assign o=flags[2];
assign n=flags[3];

//Declare a comparator for the cmp instruction, since manipulating the ALU would be a spot difficult.
wire greater, less, same;
reg g, l, s;
comparator cmp(aShifter[0], bShifter[0], greater, less, same);

//Declare the CPU's program counter:
reg [31:0] pCtr;

//Declare the CPU's stack pointer:
reg [31:0] stackPointer;

//wire [15:0] memOutMux [1:0];

reg [1:0] addrMuxSelector;
wire [31:0] addrMux[2:0];
assign addrMux[0]=pCtr;
assign addrMux[1]=stackPointer;
assign addrMux[2]=abCombined;
assign addr=addrMux[addrMuxSelector];

//This wire blocks the pipeline from attempting to issue more instructions.
wire pipeBlocked;
pipeBlockedU pbu(opShifter[0], opShifter[1], opShifter[2], opShifter[3], opShifter[4], pipeBlocked);

reg [31:0] shadowPc; //Used during calls and rets to keep the registers coherent.

//Set aside a direct path internally so that data stays up to date:
wire [15:0] aDataMux[4:0];
assign aDataMux[0]=registers[aSel2];
assign aDataMux[1]=aluOut;
assign aDataMux[2]=literalValueIntermediary;
assign aDataMux[3]=stackPointer[15:0];
assign aDataMux[4][7:0]=flags;
assign aDataMux[4][15:8]=0;

reg [31:0] instructionsFetched; //This is a performance/debugging variable only.

always@(posedge clk) begin
if(op1==44) begin
	//$display("Call instruction at %d", $time);
end
  if(op2!=0) begin
    instructionsFetched<=instructionsFetched+1;
  end

  //Shift all of the ops down the pipe:
  if(pipeBlocked) begin
    opShifter[0]<=0; //Issue a NOP if the pipe's blocked.
  end
  
  else begin
    opShifter[0]<=MEMD; //Else try to use the current bit of memory information.
    pCtr<=pCtr+1;
  end
  
  //Ensure that the rest of the pipeline is up to date:
  opShifter[1]<=opShifter[0];
  opShifter[2]<=opShifter[1];
  opShifter[3]<=opShifter[2];
  opShifter[4]<=opShifter[3];
  
  if(op3>63&&aSel2==7) begin //Data bypass for LDL; ||op4>63)
    aShifter[0]<=aDataMux[2];
  end
  
  else if(op3==40&&cSel3==aSel2) begin
    aShifter[0]<=aDataMux[3];
  end
  
  else if(op3==63&&cSel3==aSel2) begin
    aShifter[0]<=aDataMux[4];
  end
  
  else if(cSel3==aSel2&&(op3>0&&op3<11)) begin //For int ops.
    aShifter[0]<=aDataMux[1];
  end
  
  else if(cSel4==aSel2&&(op4>0&&op4<11)) begin //For int ops.
    aShifter[0]<=intermediateResult;
  end
  
  else if((op4>63) && (aSel2==7)) begin
    aShifter[0]<=aDataMux[2];
  end
  
  else begin
    aShifter[0]<=registers[aSel2];//aDataMux[0];
  end
  
  aShifter[1]<=aShifter[0];
  aShifter[2]<=aShifter[1];
  aShifter[3]<=aShifter[2];
  
  if((op3>63)&&bSel2==7) begin //Data bypass for LDL
    bShifter[0]<=aDataMux[2];
  end
  
  else if(op3==40&&cSel3==bSel2) begin
    bShifter[0]<=aDataMux[3];
  end
  
  else if(op3==63&&cSel3==bSel2) begin
    bShifter[0]<=aDataMux[4];
  end
  
  //TODO: Ensure coherence for LDFLGS instruction.
  
  else if(cSel3==bSel2&&(op3>0&&op3<11)) begin //For int ops.
    bShifter[0]<=aDataMux[1];
  end
  
  else if(cSel4==bSel2&&(op4>0&&op4<11)) begin //For int ops, since the registers are not yet coherent.
    bShifter[0]<=intermediateResult;
  end
  
  else if((op4>63) && (bSel2==7)) begin
    bShifter[0]<=aDataMux[2];
  end
  
  else begin
    bShifter[0]<=registers[bSel2];
  end
  
  bShifter[1]<=bShifter[0];
  bShifter[2]<=bShifter[1];
  bShifter[3]<=bShifter[2];
  
  //Handle the writeback stage for normal ops.
  //Everything else is handled for me along the normal integer pipeline.
  if(op4<11 && op4>0) begin
    registers[cSel4]<=intermediateResult;//aluOut;
    flags<=flagsOut;
  end
  
  if(op3<11 && op3>0) begin
    intermediateResult<=aluOut;
    //registers[cSel4]<=aluOut;
    //flags<=flagsOut;
  end
  
  //Handle non-normal operations:
  
  //BEGIN 2ND PIPELINE STAGE LOGIC
    if(op2>63) begin //Get the LDL instruction out of the way:
      literalValueIntermediary<=literalValue;
    end
  
    else if(op2==40) begin //Store stack register
    end
  
    else if(op2==41) begin //Load stack register. Loads the stack register from A and B.
      //abCombined[31:16]<=aShifter[0];//registers[aSel2];
      //abCombined[15:0]<=bShifter[0];//[bSel2];
    end
  
    else if(op2==42) begin //Push.
      addrMuxSelector<=1;
      stackPointer<=stackPointer-1;
      //memOut<=aShifter[1];//registers[aSel2];
    end
    
    else if(op2==43) begin //Pop
      addrMuxSelector<=1;
      //stackPointer<=stackPointer+1;
    end
    
    else if(op2==44) begin //Call
      addrMuxSelector<=1;
      //stackPointer<=stackPointer-1;
      //pCtr<=pCtr+1; // So that ret doesn't recurse!  NOTE: This is unncecessary due to the instruction's timing.
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
    end
    
    else if(op2==45) begin //Ret. AAAAUGH!
      addrMuxSelector<=1;
      //stackPointer<=stackPointer+1;
    end
    
    else if(op2==50) begin //CMP.
    end
    
    else if(op2>=51&&op2<=54) begin //Jmp instrs.
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
    end
    
    else if(op2==60) begin //Load
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
      addrMuxSelector<=2;
    end
    
    else if(op2==61) begin //Store
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
      addrMuxSelector<=2;
      memOut<=registers[cSel2];//registers[cSel2];
    end
    
    else if(op2==62) begin //Loads flags from the lower 8 bits of register A.
    end
    
    else if(op2==63) begin //Stores flags to the lower 8 bits of register A.
    end
    
  //BEGIN 3RD PIPELINE STAGE LOGIC
    if(op3>63) begin //Execute stage of the LDL instruction. Do nothing! Woo!
      //registers[7][14:0]<=literalValueIntermediary;
      //registers[7][15]<=0;
    end
  
    else if(op3==40) begin //Store stack register
    end
  
    else if(op3==41) begin //Load stack register. Loads the stack register from A and B.
    end
    
    else if(op3==42) begin //Push.
      memW<=1;
      memOut<=aShifter[0];
    end
    
    else if(op3==43) begin //pop
      registers[cSel3]<=MEMD;
    end
    
    else if(op3==44) begin //Call
      memOut<=pCtr[31:16];
      memW<=1;
      stackPointer<=stackPointer-1;
    end
    
    else if(op3==45) begin //Ret. AAAAUGH!
      pCtr[15:0]<=MEMD;
      stackPointer<=stackPointer+1;
    end
    
    else if(op3==50) begin //CMP.
      g<=greater;
      l<=less;
      s<=same;
    end
    
    else if(op3>=51&&op3<=54) begin //Jmp instrs.
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
    end
    

    
    //else if(op3==52) begin //Jump on equal.
    //  
    //end
    
    
    
    else if(op3==60) begin //Load
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
      addrMuxSelector<=2;
    end
    
    else if(op3==61) begin //Store
      abCombined[31:16]<=aShifter[0];//registers[aSel2];
      abCombined[15:0]<=bShifter[0];//registers[bSel2];
      addrMuxSelector<=2;
      if(op4>63&&cSel3==7) begin
	memOut[14:0]<=literalValueIntermediary;
	memOut[15]<=0;
      end
      
      else if(cSel4==cSel3) begin //Then it is most likely the product of an ALU action.
	if(op4>0&&op4<11) begin
	  memOut<=intermediateResult;
	end
	
	else if(op4==41) begin
	  memOut<=stackPointer[15:0];
	end
	
	else begin //Hope for the best:
	  memOut<=registers[cSel3];
	end
      end
      
      else begin
	memOut<=registers[cSel3];
      end
      
      memW<=1;
    end
    
    else if(op3==62) begin //Load flags.
    end
    
    else if(op3==63) begin //Stores flags to the lower 8 bits of register A.
    end
  
  // BEGIN 4TH PIPELINE STAGE LOGIC
    if(op4>63) begin //Writeback stage of the LDL instruction. Lovely!
      registers[7][14:0]<=literalValueIntermediary;
      registers[7][15]<=1'b0;
    end
  
    else if(op4==40) begin //Store stack register
      registers[cSel4]<=stackPointer[15:0];
    end
  
    else if(op4==41) begin //Load stack register. Loads the stack register from A and B.
      stackPointer[31:16]<=aShifter[1];
      stackPointer[15:0]<=bShifter[1];
      //stackPointer<=abCombined;
    end
    
    else if(op4==42) begin //Push
      memW<=0;
      //stackPointer<=stackPointer-1;
      addrMuxSelector<=0;
    end
    
    else if(op4==43) begin //Pop
      //registers[cSel4]<=MEMD;
      stackPointer<=stackPointer+1;
      addrMuxSelector<=0;
    end
    
    else if(op4==44) begin //Call
      memOut<=pCtr[15:0];
      stackPointer<=stackPointer-1;
      shadowPc[31:16]<=registers[aSel4];
      shadowPc[15:0]<=registers[bSel4];
    end
    
    else if(op4==45) begin //Ret. AAAAUGH!
      pCtr[31:16]<=MEMD;
      stackPointer<=stackPointer+1;
    end
    
    else if(op4==50) begin //CMP.
      flags[7]<=g; //This sort of writeback allows for better debugging.
      flags[6]<=l;
      flags[5]<=s;
    end
    
    else if(op4==59) begin //Halt. Should I even bother?
      halt<=1;
    end
  
    else if(op4==60) begin //Load
      registers[cSel4]<=MEMD;
      addrMuxSelector<=0;
    end
    
    else if(op4==51) begin //Jmp
      //pCtr[31:16]<=//aShifter[2];
      //pCtr[15:0]<=//bShifter[2];
      pCtr<=abCombined;
    end
    
    else if(op4==52) begin //JE
      if(s) begin
	//pCtr[31:16]<=aShifter[2];//registers[aSel4];//aShifter[1];
	//pCtr[15:0]<=bShifter[2];//registers[bSel4];//bShifter[1];
	pCtr<=abCombined;
      end
     end
     
     else if(op4==53) begin //Jump on positive (greater)
      if(g) begin
	pCtr[31:16]<=aShifter[2];//registers[aSel4];//aShifter[1];
	pCtr[15:0]<=bShifter[2];//registers[bSel4];//bShifter[1];
      end
    end
    
    else if(op4==54) begin //Jump on negative (less)
      if(n) begin
	pCtr[31:16]<=registers[aSel4];//aShifter[1];
	pCtr[15:0]<=registers[bSel4];//bShifter[1];
      end
    end
    
    else if(op4==61) begin //Store
      memW<=0;
      addrMuxSelector<=0;
    end
    
    else if(op4==62) begin //Load flags.
      flags<=aShifter[2][7:0];
    end
    
    else if(op4==63) begin //Store flags.
      registers[cSel4][7:0]<=flags;
    end
    
  // BEGIN 5TH PIPELINE STAGE LOGIC
    if(op5==44) begin //Call
      //pCtr[31:16]<=registers[cSel4];//Complete the jump
      //pCtr[15:0]<=bShifter[2];
      pCtr<=shadowPc;
      memW<=0; //Stop writing to memory.
      addrMuxSelector<=0; //Use the program counter for addressing.
      //stackPointer<=stackPointer-1; //3 shifts prevents push from destroying the address.
    end
    
    else if(op5==45) begin //Ret. AAAAUGH!
      addrMuxSelector<=0;
    end
    
    //Jmp placeholder.
end

initial begin
  addrMuxSelector<=0;
  abCombined<=0;
  halt<=0;
  pCtr<=0;
  stackPointer<=0;
  
  //Assign registers to 0:
  registers[0]<=0;
  registers[1]<=0;
  registers[2]<=0;
  registers[3]<=0;
  registers[4]<=0;
  registers[5]<=0;
  registers[6]<=0;
  registers[7]<=0;
  memW<=0;
  
  opShifter[0]<=0;
  opShifter[1]<=0;
  opShifter[2]<=0;
  opShifter[3]<=0;
  opShifter[4]<=0;
  
  instructionsFetched<=0;
end
  
endmodule
