//Testbench for the dispatch unit.
module dispatchu_tb(
  );

reg clk;
reg [15:0] aDat;
reg [15:0] bDat;
reg [15:0] cDat;
wire [31:0] addr;
wire [15:0] memOut;
wire memWrite;
wire [15:0] cOut;
wire cWrite;
wire [2:0] aSel;
wire [2:0] bSel;
wire [2:0] cSel;
wire [3:0] intOp;
wire [2:0] intA;
wire [2:0] intB;
wire [2:0] intC;

wire [15:0] memDat;

//Make a small, 16 word memory to play with.
reg [15:0] memoryArray[15:0]; 
reg [3:0] memSel;
assign memDat=memoryArray[memSel];

dispatchu du(clk, memDat, aDat, bDat, cDat, addr, memOut, memWrite, cOut, cWrite, aSel, bSel, cSel, intOp, intA, intB, intC);


initial begin
//Set up the virtual memory space:
  clk=0;
  aDat=0;
  bDat=0;
  cDat=0;
  memSel=0;
  memoryArray[0]=16'h000a;
  memoryArray[1]=16'h8007;
  memoryArray[2]=16'h6638;
end

always begin
  #1 clk<=!clk;
  if(clk) begin
    if(memWrite) begin
      memoryArray[addr%16]<=memOut;
    end
      
    else begin
      memSel<=addr%16;
    end
  end
end

initial begin
  $dumpfile("dispatchu_tb.vcd");
  $dumpvars;
end

initial 
  #128 $finish;
endmodule