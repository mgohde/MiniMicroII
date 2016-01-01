//An ALU module for the integer pipeline.
//List of ops accepted:
//0: NOP
//1: ADD
//2: ADDC
//3: SUB
//4: SUBC
//5: BSL
//6: BSR
//7: AND
//8: OR
//9: INV
//10: XOR
module ALU(
  OP,
  FLGIN,
  A,
  B,
  flgOut,
  out,
  shouldWriteBack
  );

input [3:0] OP;
input [7:0] FLGIN;
input [15:0] A;
input [15:0] B;
output [7:0] flgOut;
output [15:0] out;
output shouldWriteBack;

wire [15:0] nopWire;
wire [16:0] addWire;
wire [16:0] addcWire;
wire [15:0] subWire;
wire [15:0] subcWire;
wire [15:0] bslWire;
wire [15:0] bsrWire;
wire [15:0] andWire;
wire [15:0] orWire;
wire [15:0] invWire;
wire [15:0] xorWire;

wire [15:0] outputMuxWire[15:0];

//Assign the wires to their respective actions:
assign nopWire=0;
assign addWire=A+B;
assign addcWire=A+B+FLGIN[1];
assign subWire=A-B;
assign subcWire=A-B-FLGIN[1];
assign bslWire=A<<B;
assign bsrWire=A>>B;
assign andWire=A&B;
assign orWire=A|B;
assign invWire=~A;
assign xorWire=A^B;

assign outputMuxWire[0]=nopWire;
assign outputMuxWire[1]=addWire[15:0];
assign outputMuxWire[2]=addcWire[15:0];
assign outputMuxWire[3]=subWire;
assign outputMuxWire[4]=subcWire;
assign outputMuxWire[5]=bslWire;
assign outputMuxWire[6]=bsrWire;
assign outputMuxWire[7]=andWire;
assign outputMuxWire[8]=orWire;
assign outputMuxWire[9]=invWire;
assign outputMuxWire[10]=xorWire;
assign outputMuxWire[11]=nopWire;
assign outputMuxWire[12]=nopWire;
assign outputMuxWire[13]=nopWire;
assign outputMuxWire[14]=nopWire;
assign outputMuxWire[15]=nopWire;

//Set normal computation outputs.
assign out=outputMuxWire[OP];
assign shouldWriteBack=OP>0&&OP<11; //Enables NOPs.

//Now construct flags: (zero, carry, overflow, negative)
wire zero, carry, overflow, negative;

wire zeroMuxWire[10:0];
assign zeroMuxWire[0]=nopWire==0;
assign zeroMuxWire[1]=addWire==0;
assign zeroMuxWire[2]=addcWire==0;
assign zeroMuxWire[3]=subWire==0;
assign zeroMuxWire[4]=subcWire==0;
assign zeroMuxWire[5]=bslWire==0;
assign zeroMuxWire[6]=bsrWire==0;
assign zeroMuxWire[7]=andWire==0;
assign zeroMuxWire[8]=orWire==0;
assign zeroMuxWire[9]=invWire==0;
assign zeroMuxWire[10]=xorWire==0;

assign zero=zeroMuxWire[OP];

assign carry=addWire[16]&&(OP==1)||addcWire[16]&&(OP==2);

//I'll figure out overflow later on:
assign overflow=0;
//Negative:
assign negative=subWire<0&&(OP==3)||subcWire<0&&(OP==4);

//Condense all of the flags:
assign flgOut[0]=zero;
assign flgOut[1]=carry;
assign flgOut[2]=overflow;
assign flgOut[3]=negative;
assign flgOut[7:4]=0;

endmodule