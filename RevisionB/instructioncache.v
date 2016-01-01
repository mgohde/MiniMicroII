//This module represents a very simple, small instruction cache.
//The cache exists to increase average bandwidth so that future revisions of the core
//can have nice things, like superscalar execution. 

module instructioncache(memdat, addr, clk, rst, wt, DATOUT, OUTADDR, OUTWAIT);

input [15:0] memdat;
input [31:0] addr;
input clk;
input rst;
input wt;
output [63:0] DATOUT;
output [31:0] OUTADDR;
output OUTWAIT;


//reg [63:0] outDat;
//assign OUT=outDat;
reg [31:0] outAddr;
assign OUTADDR=outAddr;

//Declare the actual cache memory itself.
//Overall, it has 64 4-word lines
reg [63:0] iCache [0:63]; 
reg [31:0] tags [0:63];

wire [5:0] lineSel;
instructionhasher hash(addr, lineSel);

wire [31:0] curLine;
assign curLine=tags[lineSel];
   
assign DATOUT=iCache[lineSel];

//The address should count up by four each time, as the instruction fetch/dispatch unit
//should effectively handle the rest.
   //wire     ow1;
   //assign ow1=(tags[lineSel]>=addr);
   //assign ow2=(addr<(tags[lineSel]+4);
assign OUTWAIT=~((addr>=tags[lineSel])&&(addr<(tags[lineSel]+4)));

reg [3:0] stateCtr;

//This exists basically just to fetch data from memory.
always@(posedge clk) begin
	if(OUTWAIT) begin
		//Set address lines for the first byte:
		if(stateCtr==0) begin
			outAddr<=addr;

			if(~wt) begin
				stateCtr<=stateCtr+1;
			end
		end

		else if(stateCtr==1) begin
			iCache[lineSel][15:0]<=memdat;
			outAddr<=addr+1;
			
			//Note: if necessary, I will break the state counter off into its own functional unit
			//so that I don't have to repeat so much code and waste so many gates.
			if(~wt) begin
				stateCtr<=stateCtr+1;
			end
		end

		else if(stateCtr==2) begin
			iCache[lineSel][31:16]<=memdat;
			outAddr<=addr+2;

			if(~wt) begin
				stateCtr<=stateCtr+1;
			end
		end

		else if(stateCtr==3) begin
			iCache[lineSel][47:32]<=memdat;
			outAddr<=addr+3;

			if(~wt) begin
				stateCtr<=stateCtr+1;
			end
		end

		else if(stateCtr==4) begin
			iCache[lineSel][63:48]<=memdat;
			tags[lineSel]<=addr;

			if(~wt) begin
				stateCtr<=0;
			end
		end
	end
end // always@ (posedge clk)

reg [10:0] i;
   
initial begin
   for(i=0;i<64;i=i+1) begin
      tags[i]=32'hF0000000;
      
   end

   stateCtr=0;
   
end

endmodule
