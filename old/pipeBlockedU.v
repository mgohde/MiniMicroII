//This module exists to clean the main CPU module a bit and to allow for there to be
//more hard-wired combinational logic in the CPU. Future revisions will include even further
//hard-wiring so as to hopefully increase clockspeed potential.
module pipeBlockedU(
  DAT1,
  DAT2,
  DAT3,
  DAT4,
  DAT5,
  blocked
  );

input [15:0] DAT1;
input [15:0] DAT2;
input [15:0] DAT3;
input [15:0] DAT4;
input [15:0] DAT5;
output blocked;

wire [6:0] o1;
wire [6:0] o2;
wire [6:0] o3;
wire [6:0] o4;
wire [6:0] o5;

assign o1=DAT1[15:9];
assign o2=DAT2[15:9];
assign o3=DAT3[15:9];
assign o4=DAT4[15:9];
assign o5=DAT5[15:9];

wire blocked1, blocked2, blocked3, blocked4, blocked5;

//Almost all operations beyond Store Stack Register and Load Stack Register should block:
//assign blocked1=o1>41&&o1~=50&&o1<64;
//assign blocked2=o2>41&&o2~=50&&o2<64;
//assign blocked3=o3>41&&o3~=50&&o3<64;
//Note, the additional ops to be excluded from blocking are pretty much all jumps.
//They really don't do anything harmful to the pipeline.
//assign blocked4=o4>41&&o4~=50&&o4<64&&o4~=51&&o4~=52&&o4~=53&&o4~=54;
//assign blocked5=o5>41&&o5~=50&&o5<64&&o4~=51&&o4~=52&&o4~=53&&o4~=54;

//This is a far finer grained, more efficient version.
assign blocked1=(o1>41 && o1<46) || (o1>50 && o1<55) || o1==60 || o1==61;// || o1==41;//o1==42||o1==43||o1==44||o1==45||o1==
assign blocked2=(o2>41 && o2<46) || (o2>50 && o2<55) || o2==60 || o2==61 || o2==41; //^LSR should make a 1 op bubble so that immediate pushes don't cause problems.
assign blocked3=(o3>41 && o3<46) || (o3>50 && o3<55) || o3==60 || o3==61 || o3==41;
assign blocked4=(o4>41 && o4<46) || (o4>50 && o4<55) || o4==60 || o4==61;// || o1==41;
assign blocked5=(o5==44 || o5==45);// || (o1>=51 && o1<=54) || o1==60 || o1=61;


assign blocked=blocked1||blocked2||blocked3||blocked4||blocked5;
endmodule