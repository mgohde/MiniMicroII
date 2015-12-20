//Defines a program counter.
//This is a 32 bit counter used to keep track of where the processor currently is.
module programcounter(
	CLK,
	INCREMENT,
	NEWV,
	WRITE,
	out
	);

input CLK;
input INCREMENT;
input [31:0] NEWV;
input WRITE;
output [31:0] out;

reg [31:0] val;
assign out=val;

//By triggering on the negative edge, I'm effectively staggering RAM access and reads. 
//This may potentially possibly maybe allow me to push higher clockspeeds.
always@(negedge CLK) begin
	if(~WRITE&&INCREMENT) begin
		val<=val+1;
	end
	else if(WRITE) begin
		val<=NEWV;
	end
end

initial begin
	val=0;
end
endmodule
