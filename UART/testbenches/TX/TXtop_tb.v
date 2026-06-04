
module TXtop_tb;

reg[7:0] timerCurrentVal;
reg[7:0] TXbuff;
reg TE;
reg TI_irq;
wire TI;
wire TX;
wire TXshiftready;
wire TXshiftenable;

reg pwrite;
wire[1:0] state;

reg clk;
reg[7:0] timerInitVal;


integer count = 0;


TXtop uut(.timerCurrentVal(timerCurrentVal), .TXbuff(TXbuff), .TE(TE), .TI_irq(TI_irq), .TI(TI), .TX(TX), .clk(clk), .pwrite(pwrite));


always #1 clk=~clk;

always @(posedge clk)
begin
	if(timerCurrentVal != 8'd255)
		timerCurrentVal = timerCurrentVal + 1'b1;
	else
		timerCurrentVal = timerInitVal;

end

always @(posedge TI)
begin
#1;
TI_irq = 0;
pwrite = 1;
#3;
TXbuff = 8'b00000000;
pwrite = 0;
count = count + 1;
#3;
TI_irq = 0;
#2;
TI_irq = 1;
end




initial begin



$dumpfile("TXtop.vcd");
$dumpvars();
#1;


TI_irq = 1;
#1; //think
TI_irq = 0;
#1;
TI_irq = 1;

timerInitVal = 8'd253;
timerCurrentVal = timerInitVal + 1'b1;

clk = 0;
TE = 1;
#1;


pwrite <= 1;
#3;

TXbuff = 8'b00011101;
#3
pwrite <= 0;
#36;
pwrite <= 1;
#1;
TXbuff = 8'b00000000;
#1;
pwrite <= 0;



#10;
#180;

$finish;

end

endmodule