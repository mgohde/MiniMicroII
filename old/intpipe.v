//This is a 3-stage integer pipeline.
//It fetches dependencies, executes, and writes back to a register file.
module intpipe(
  CLK,
  PAUSE,
  EMPTY,
  OPCODE,
  A,
  B,
  C,
  ADAT,
  BDAT,
  FLGS,
  aSel,
  bSel,
  cSel,
  cOut,
  cWrite,
  flgs
  );
  
input CLK;
input PAUSE;
input EMPTY;
input [3:0] OPCODE;
input [2:0] A;
input [2:0] B;
input [2:0] C;
input [15:0] ADAT;
input [15:0] BDAT;
input [7:0] FLGS;
output [2:0] aSel;
output [2:0] bSel;
output [2:0] cSel;
output [15:0] cOut;
output cWrite;
output [7:0] flgs;

wire [15:0] aPath [1:0];
wire [15:0] bPath [1:0];
wire [15:0] aluOut;
wire [3:0] aluOp;
wire [7:0] flgIn;
wire [7:0] flgOut;
reg [7:0] flgs;
wire writeBack;

reg [3:0] opCodeShifter[1:0];
reg [3:0] writeBackRegShifter[2:0];
//reg [15:0] datShifter[1:0]
reg [15:0] aluOutput;
reg [15:0] aDatShifter[1:0];
reg [15:0] bDatShifter[1:0];
reg write;
assign cWrite=write&&(~PAUSE);

wire aPathSel;
wire bPathSel;

assign flgs=flgOut;
assign FLGS=flgIn;

assign aPathSel=writeBackRegShifter[2]==A;
assign bPathSel=writeBackRegShifter[2]==B;

assign aSel=A;
assign bSel=B;
assign cSel=writeBackRegShifter[2];
assign cOut=aluOutput;
assign aPath[0]=aDatShifter[1];
assign aPath[1]=aluOut;
assign bPath[0]=bDatShifter[1];
assign bPath[1]=aluOut;
assign aluOp=opCodeShifter[1];

wire [15:0] AD1;
assign AD1=aDatShifter[0];
wire [15:0] AD2;
assign AD2=aDatShifter[1];

//Build an ALU:
ALU a(aluOp, flgIn, aPath[aPathSel], bPath[bPathSel], flgOut, aluOut, writeBack);

always@(posedge CLK) begin
 if(PAUSE==1) begin
  //Do nothing!
  //Please note that the write output should be anded with pause.
 end
 
 else if(EMPTY==0) begin //Do something!
  //Set the next string of ops:
  opCodeShifter[0]<=OPCODE;
  opCodeShifter[1]<=opCodeShifter[0];
  writeBackRegShifter[0]<=C;
  writeBackRegShifter[1]<=writeBackRegShifter[0];
  writeBackRegShifter[2]<=writeBackRegShifter[1];
  
  aluOutput<=aluOut;
  write<=writeBack;
  
  aDatShifter[0]<=ADAT;
  bDatShifter[0]<=BDAT;
  aDatShifter[1]<=aDatShifter[0];
  bDatShifter[1]<=bDatShifter[0];
 end
 
 else begin //This means that EMPTY is true.
  opCodeShifter[0]<=0;
  opCodeShifter[1]<=0;
  writeBackRegShifter[0]<=0;
  writeBackRegShifter[1]<=0;
  writeBackRegShifter[2]<=0;
  aluOutput<=0;
  write<=0;
  aDatShifter[0]<=0;
  aDatShifter[1]<=0;
  bDatShifter[0]<=0;
  bDatShifter[1]<=0;
 end
end

//This is actually unnecessary. The register file 
//operates off of the same clock source and thus would use that for gating.
//always@(negedge CLK) begin
//  if(write==1) begin
//    write<=~write; //Ensure that the register file can catch up.
//  end
//end

initial begin
  opCodeShifter[0]=0;
  writeBackRegShifter[0]=0;
  writeBackRegShifter[2]=0;
  aluOutput=0;
  write=0;
  aDatShifter[0]=0;
  bDatShifter[0]=0;
end
  
endmodule
