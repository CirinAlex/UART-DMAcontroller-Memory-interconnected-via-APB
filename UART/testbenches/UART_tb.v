

module uart_tb;

reg master_clk;
reg[7:0] timerInitVal;
reg[7:0] TXbuff;
reg TE;
wire TI;
reg TI_in;
wire TX;

reg pwrite;

wire[7:0] RXbuff;
reg RE;
wire RI;
reg RI_in;
reg RX;


reg start;
reg[9:0] RXdata;
integer i;



uart dut(.master_clk(master_clk), .timerInitVal(timerInitVal), .TXbuff(TXbuff), .TE(TE), .TI(TI), .TI_in(TI_in), .TX(TX), .pwrite(pwrite), .RXbuff(RXbuff), .RE(RE), .RI(RI), .RI_in(RI_in), .RX(RX));


// drives TX
always @(start)
begin
	pwrite = 1;
	TE = 1;
	#1;
	TI_in = 1;
	#1;
	TI_in = 0;
	#5;
	TXbuff = 8'b00001101;
	pwrite = 0;

end


integer dly, j;

// drives RX
always @(start)
begin

	dly = 256 - timerInitVal;

	RE = 1;
	#4;

	#1;
	RI_in = 1;
	#50;
	RXdata = 10'b1010010010;


for(integer i=0; i<10; i = i+1)
begin

	j = 0;

	RX = RXdata[i];
	for(integer j=0; j<dly; j = j+1)
		#64;

end

	#190;
	RI_in = 0;
	#2;
	RI_in = 1;
	#64;
	RXdata = 10'b1000000010;

for(integer i=0; i<10; i = i+1)
begin

	j = 0;
	RX = RXdata[i];
	for(integer j=0; j<dly; j = j+1)
		#64;

end


end



always #1 master_clk = ~master_clk;

initial begin

$dumpfile("uart.vcd");
$dumpvars();
start = 0;

master_clk = 0;

timerInitVal = 8'd252; //baud rate 115200

#1;
start = 1;


#20000;

$finish;

end

endmodule