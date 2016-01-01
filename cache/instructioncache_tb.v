//This defines a very simple testbench for the instruction cacher.
//It is intended to work with "real world" access data in order to provide statistics for
//hits, misses, and whether the cache actually flipping works.

module instructioncache_tb();

reg [31:0] requestedAddresses [0:5000];
reg [31:0] addressCounter;
wire [31:0] selectedAddress;
wire [15:0] memDat;
reg clk;
wire rst;
wire wt;
wire [63:0] outWire;
wire [31:0] outAddr;
wire cachewt;

assign selectedAddress=requestedAddresses[addressCounter];
assign memDat=outAddr[15:0];
assign rst=0;
assign wt=0;

instructioncache icache(memDat, selectedAddress, clk, rst, wt, outWire, outAddr, cachewt);
reg [31:0] numMisses;
reg [31:0] numHits;
   
reg [31:0] numCycles;
reg [31:0] numwtCycles;

initial begin
	addressCounter=0;
	$readmemb("memaccess.txt", requestedAddresses);
	clk=0;
	numMisses=0;
	numCycles=0;
   numwtCycles=0;
   numHits=0;
   
   
end



always begin
	#1 clk=~clk;
	
end

always@(posedge cachewt) begin
	numMisses<=numMisses+1;
end

always@(posedge clk) begin
	numCycles<=numCycles+1;
	if(~cachewt) begin
		addressCounter<=addressCounter+1;
	   numHits=numHits+1;
	   
	end

	else begin
		numwtCycles<=numwtCycles+1;
	end
end

initial begin
   	$display("Number of misses: %d", numMisses);
	$display("Number of cycles: %d", numCycles);
	$display("Number of cycles stalled: %d", numwtCycles);
	$dumpfile("instructioncache_tb.vcd");
	$dumpvars;
end

initial
  #4000 $finish;
   
endmodule
