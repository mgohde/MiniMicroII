//This is a simple testbench for the instruction hasher.
//It goes through the first million possible addresses and returns results.

module instructionhasher_tb();

reg [31:0] addrCtr;
wire [5:0] hashedAddr;

reg [31:0] addrArray [0:10000];

instructionhasher hash(addrArray[addrCtr], hashedAddr);

initial begin
	addrCtr=0;
	$readmemb("memaccess.txt", addrArray);
end

always begin
	#1 addrCtr=addrCtr+1;
end

initial begin
	$dumpfile("instructionhasher_tb.vcd");
	$dumpvars;
end

initial 
	#1000000 $finish;
endmodule