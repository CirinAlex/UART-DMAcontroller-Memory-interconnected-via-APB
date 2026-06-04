/*

problem : initialization of counter and uart_clk
solution : initialized on enabling of RE, TE


problem : RE, TE not enabled simultaneosly, so counter can get resetted without completing half uart_clk cycle
advantage : uart_clk is enabled only when user activates uart. This helps to reduce unwanted power dissipation

FAILED
solution : initializes counter and uart_clk only when any ONE of TE or RE is enabled, ie. the condition is not satisfied 
	   if they are enabled at different times hence counter will not get reset.
trade-off : Assumes TE or RE is disabled when uart usage is over, because if TE or RE is disabled at different times, the condition still satisfies and resets the counter.

KEEPING AS A TRADE OFF assuming that the user is not intending to start uart until both RE and TE are enabled.

*/


//divides master_clk by 32
module clk_divider(input reg master_clk,//master clock of 11.0592MHz
		   output reg uart_clk,	//divided clock for uart
		   input reg RE, 	// used to initialize uart_clk and counter when RE enabled
		   input reg TE 	// used to initialize uart_clk and counter when TE enabled
		);



reg[3:0] counter; //to count number of master_clk posedge
reg flag;

//initializing counter and uart_clk on enabling of RE or TE
always @(TE, RE)
begin

	counter <= 4'b1111; //loaded with 16
	uart_clk <= 0;

end


//main block that divides clock by 32
always @(posedge master_clk)
begin
	//decrements counter on every master_clk posedge
	if(counter!=4'b0)
		counter <= counter - 1;

	//when counter reaches 0, uart clock is inverted and also counter is loaded with d16 for next clock cycle
	if(counter==4'b0000)
	begin
		uart_clk <= ~uart_clk;
		counter <= 4'b1111;
	end
end

endmodule