//cpu_tb.v 
//This is a testbench for the CPU module. AAAAUGH!
module cpu_tb();

reg clk;
wire [31:0] addr;
wire [15:0] memOut;
wire memWrite;
wire memReady;

wire [15:0] memDat;

//Make a small, 16 word memory to play with.
reg [15:0] memoryArray[511:0]; 
reg [3:0] memSel;
//Allow for addresses to be wrapped around in realtime. 
wire [8:0] realAddr=addr%512;//&9'b111111111;
assign memDat=memoryArray[realAddr];//memSel];


cpu cp(clk, memDat, memReady, addr, memOut, memWrite);


initial begin
//Set up the virtual memory space:
  clk=0;
  memSel=0;
  $readmemb("memory.list", memoryArray);
end

always begin
  #1 clk<=!clk;
  if(clk) begin
    if(memWrite) begin
      memoryArray[realAddr]<=memOut;
    end
      
    //else begin
    //  memSel<=addr%511;
    //end
  end
end

initial begin
  $dumpfile("cpu.vcd");
  $dumpvars;
end

initial 
  #4096 $finish;
  
  
endmodule
