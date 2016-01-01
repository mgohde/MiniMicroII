//This defines a comparator for use with the 
//Branch-Memory Unit.
module comparator(
  A,
  B,
  greater,
  less,
  same
  );
  
input [15:0] A;
input [15:0] B;
output greater;
output less;
output same;

assign greater=A>B;
assign same=A==B;
assign less=~(greater||same); //Neither.
  
endmodule