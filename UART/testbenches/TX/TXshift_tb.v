

module TXshift_tb;

reg[7:0] timenow;
reg clk;
reg[7:0] TXbuff;
reg TXshiftenable;
wire TX;
wire TXshiftready;
wire[3:0] counter;
wire[7:0] timeToShift;

reg[7:0] timerInitVal;
wire TI;




TXshift uut(.timerCurrentVal(timenow), .TXbuff(TXbuff), .TXshiftenable(TXshiftenable), .clk(clk), .TXshiftready(TXshiftready), .TX(TX));



always @(posedge TXshiftready)
begin

TXshiftenable <= 0;

end




always #1 clk = ~clk;

always @(posedge clk) begin

if(8'd255 != timenow)
timenow = timenow + 1'b1;
else
timenow = timerInitVal;
end




initial begin
timerInitVal = 8'd253;
clk = 0;
timenow = 8'd253;

$dumpfile("TXshift.vcd");
$dumpvars(0, TXshift_tb);



TXbuff = 8'b11001001;
TXshiftenable = 1'b1;
#150;
if(TXshiftready==1'b1)
begin
TXshiftenable = 1'b0;
#3;
TXbuff = 8'b00000000;
TXshiftenable = 1'b1;
end

#200;
$finish;
end

endmodule



