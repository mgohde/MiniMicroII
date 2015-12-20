//Testbench for the integer instruction pipe.
module intpipe_testbench();

reg clk, pause, empty;
reg [4:0] opCode;
reg [3:0] a;
reg [3:0] b;
reg [3:0] c;
reg [15:0] aDat;
reg [15:0] bDat;
wire [3:0] aSel;
wire [3:0] bSel;
wire [3:0] cSel;
wire [15:0] cOut;
wire cWrite;

reg [15:0] ctr; //This allows me to change some things for validation

intpipe p(clk, pause, empty, opCode, a, b, c, aDat, bDat, aSel, bSel, cSel, cOut, cWrite);

initial begin
 ctr=0;
 clk=0;
 pause=0;
 empty=0;
 opCode=1; //Add.
 a=0;
 b=1;
 c=2;
 aDat=1;
 bDat=1;
end

always begin
 #0 clk=!clk;
 if(clk==1) begin
  #1 aDat=aDat+1;
 end
 else begin
  #1 aDat=aDat;
 end
 
 ctr=ctr+1;
 
 //Send some NOPs through the pipe.
 if(ctr==10) begin
  opCode=0;
 end
 
 if(ctr==15) begin //Set it to subtract B from A.
  opCode=3;
 end
 
 //Now pause for a few cycles.
 if(ctr==20) begin
  pause=1;
 end
 
 if(ctr==30) begin //Resume normal operations.
  pause=0;
 end
end

initial begin
 $dumpfile("intpipe_testbench.vcd");
 $dumpvars;
end

initial begin
 $display("\t\tTime, \tClock, \tA, \tB, \tOp, \tOut, \tcWrite");
 $monitor("%d, \t%b, \t%b, \t%b, \t%b, \t%b, \t%b", $time, clk, opCode, aDat, bDat, cOut, cWrite);
end

initial 
 #128 $finish;
 
endmodule