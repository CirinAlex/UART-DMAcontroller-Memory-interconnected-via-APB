`include ".\modules\clk_divider.v"
`include ".\modules\UARTtop.v"
`include ".\modules\uart_timer.v"
`include ".\modules\RX\RXshift.v"
`include ".\modules\RX\RXtop.v"
`include ".\modules\TX\TXshift.v"
`include ".\modules\TX\TXtop.v"

module uart_tb;

reg master_clk;
reg[7:0] timerInitVal;
reg[7:0] TXbuff;
reg TE;
wire TI;
wire TX;

reg pwrite;

wire[7:0] RXbuff;
reg RE;
wire RI;
reg RI_in;
reg TI_in;
reg RX;


reg start;
reg[9:0] RXdata;
integer i;
integer co = 0;


uart dut(.master_clk(master_clk), .timerInitVal(timerInitVal), .TXbuff(TXbuff), .TE(TE), .TI(TI), .TI_in(TI_in), .TX(TX), .pwrite(pwrite), .RXbuff(RXbuff), .RE(RE), .RI(RI), .RI_in(RI_in), .RX(RX));


// drives TX
always @(start, TI)
begin
if(co==0)
begin
co = 1;
	pwrite = 1;
	TE = 1;
	#3;
	TI_in = 1;
	#5;
	TXbuff = 8'b00001101;
	pwrite = 0;
end


if(TI==1 && co==1)
begin
		#5;
		pwrite = 1;
		#1;

		TXbuff = 8'b01110011;
		TI_in = 0;
		#2;
		TI_in = 1;
		#10;
		pwrite = 0;
		co = 2;

end
if(TI==1 && co==2)
begin
		#5;
		pwrite = 1;
		#800;

		TXbuff = 8'b01000101;
		TI_in = 0;
		#2;
		TI_in = 1;
		#200;
		pwrite = 0;
		co = 3;

end
if(TI==1 && co==3)
begin
		#5;
		pwrite = 1;
		#800;

		TXbuff = 8'b00000011;
		TI_in = 0;
		#2;
		TI_in = 1;
		#200;
		pwrite = 0;
		co = 4;

end

if(TI==1 && co==4)
begin
		#5;
		pwrite = 1;
		#800;

		TXbuff = 8'b00000000;
		TI_in = 0;
		#2;
		TI_in = 1;
		#200;
		pwrite = 0;
		co = 5;

end

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

if(i!=9)
	j = 0;

	RX = RXdata[i];
	while(j<dly)
		begin
		#64;
		j = j+1;
		end

end

	#190;
	RI_in = 0;
	#2;
	RI_in = 1;
	#64;
	RXdata = 10'b1000000010;

for(integer i=0; i<10; i = i+1)
begin

if(i!=9)
	j = 0;

	RX = RXdata[i];
	while(j<dly)
		begin
		#64;
		j = j+1;
		end

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