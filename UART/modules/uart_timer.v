
/*

provides 8-bit timer to TX and RX module to synchronize baudrate.


*/


module uart_timer(
		input reg uart_clk, //divided clock, enable line can be avoided because uart_clk is enabled only on RE and TE
		input reg[7:0] timerInitVal, //initial value for timer, timer is reloaded with this value after overflow
		output reg[7:0] timerCurrentVal //incremented real-time value of timer
	);

always @(timerInitVal)
begin
	timerCurrentVal <= timerInitVal;

end


always @(posedge uart_clk)
begin
	if(timerCurrentVal != 8'd255)
		timerCurrentVal <= timerCurrentVal + 8'b1;
	else
		timerCurrentVal <= timerInitVal;

end

endmodule