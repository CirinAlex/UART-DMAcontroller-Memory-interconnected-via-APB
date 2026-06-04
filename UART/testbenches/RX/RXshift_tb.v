

module test_tb;

reg enableIN;
wire ready;
reg[7:0] timerCurrentVal;
reg[7:0] timerInitVal;
reg RX;
wire[7:0] RXbuff;

RXshiftreg uut(.enableIN(enableIN), .ready(ready), .timerCurrentVal(timerCurrentVal), .timerInitVal(timerInitVal), .RX(RX), .RXbuff(RXbuff));


initial begin
$dumpfile("test.vcd");
$dumpvars(0, test_tb);
timerInitVal = 8'hfc;
enableIN = 1'b1;

timerCurrentVal = timerInitVal;

RX = 1'b0;
for(integer j=0; j<12; j=j+1)
begin
timerInitVal = 8'hfc;
timerCurrentVal = timerInitVal;

	for(integer i=0; i<4; i=i+1)
	begin
		#10;
		
		timerCurrentVal = timerCurrentVal + 1;
	end
RX = ~RX;
end
$finish;
end

endmodule