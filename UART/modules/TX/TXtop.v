


module TXtop(
	input reg[7:0] timerCurrentVal,
	input reg[7:0] TXbuff,
	input reg TE,
	input wire TI_irq, // pulled low for short time
	output reg TI,
	output wire TX,
	input clk,
	output reg TXshiftenable,
	output TXshiftready,
	output reg TXCH,
	output reg[1:0] state
);

//reg[1:0] state;

//reg TXCH;
//reg TXshiftenable;
//wire TXshiftready;
	
//instantiation


TXshift A1(.timerCurrentVal(timerCurrentVal), .TXbuff(TXbuff), .TXshiftenable(TXshiftenable), .clk(clk), .TXshiftready(TXshiftready), .TX(TX));






/*always @(TE, posedge TXshiftready) //hidden for testing
begin
	state <= 2'b00;
	if(state != 2'b00)
	TXCH <= 0;

  end
*/

always @(posedge TE)
begin
state <= 2'b00;

end

always @(posedge TXshiftready)
begin

if(state != 2'b00)
TXCH <= 0;
end






always @(negedge TI_irq)
begin
	TI <= TI_irq;
end

always @(TXbuff)
begin

	TXCH <= 1;
	TXshiftenable <= 0;

end


always @(TXCH, TE, posedge TXshiftready)
begin

case(state)
	2'b00 : begin
		if(TE==1)
			state <= 2'b01;
	end

	2'b01 : begin  
		if(TE==0)
			state <= 2'b00;
		else if(TE==1)
			begin
				if(TXCH==1)
				begin
					TXCH <= 0;
					state <= 2'b10;
				end
			end
	end

	2'b10 : begin
		if(TXCH==1)
		begin
			state <= 2'b10;
			TXCH <= 0;
			TXshiftenable <= 0;
		end
		if(TE==0)
			state <= 2'b00;
		else if(TE==1 && TXshiftenable==0)
		begin
			TXshiftenable <= 1;
		end
		else if(TE==1 && TXshiftready==1)
		begin
			TXshiftenable <= 0;
			TI <= 1;
		end
	end


endcase
end

endmodule