


module uart_timer_tb;

reg uart_clk;
reg[7:0] timerInitVal;
wire[7:0] timerCurrentVal;



uart_timer U0(.uart_clk(uart_clk), .timerInitVal(timerInitVal), .timerCurrentVal(timerCurrentVal));


always #1 uart_clk = ~uart_clk;

initial begin

$dumpfile("uart_timer.vcd");
$dumpvars();


timerInitVal = 8'd253; //initialize timer first
#1;
uart_clk = 0; 		//after that RE or TE is enabled

#50;

$finish;

end

endmodule