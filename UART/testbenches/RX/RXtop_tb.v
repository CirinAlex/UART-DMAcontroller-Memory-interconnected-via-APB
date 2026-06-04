

module test_tb;

reg RE;
wire RI;
reg RIin;
reg[7:0] timerCurrentVal;
reg[7:0] timerInitVal;
reg RX;
wire[7:0] RXbuff;


RXtop uut(.RE(RE), .RX(RX), .RI(RI), .buffer(RXbuff), .timer(timerCurrentVal), .initTimer(timerInitVal), .RI_irq(RIin));


initial begin
$dumpfile("test.vcd");
$dumpvars(0, test_tb);
RE = 1;
RIin = 1;
#10;
RX = 0;

for(integer k=0; k<3; k=k+1)
begin
for(integer j=0; j<10; j=j+1)
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
if(RI==1)
begin

 RIin = 1'b0;
#1;
 RIin = 1'b1;
end
end


$finish;
end

endmodule