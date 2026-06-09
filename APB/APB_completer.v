


// APB completer module

module APB_completer(

		input reg PCLK, //clock signal

		input reg ENABLE_DMA,	// to initialize state variable and other signals

	// ports to memory manager
		output reg enable,	// enable for mem manager, forwards PENABLE
		input reg ready,	// ready driven by mem manager, forwarded to PREADY
		output reg[7:0] addr,	// address bus for mem manager
		output reg[7:0] data_w,	// data write bus for mem manager
		input reg[7:0] data_r,	// data read bus
		output reg dir,		// r/w signal
		input reg error,	// error signal from mem manager


	// buses and signals to requester, APB
		input reg[7:0] PWDATA,  // data write bus (incoming)
		output reg[7:0] PRDATA, // data read bus(outgoing)
		input reg[7:0] PADDR, 	// address bus
		input reg PSEL, 	// select line for this peripheral
		input reg PWRITE, 	// r/w control line, write=1, read=0
		input reg PENABLE, 	// enable signal for APB r/w
		output reg PREADY,	// ready signal		
		output reg PSLVERR	// signals error when invalid addr or restricted r/w


);


reg[1:0] state; // state variable for FSM


// initializing state variable and other buses and signals.
always @(posedge ENABLE_DMA)
begin
	
	state <= 2'b00;

	enable <= 0;
	addr <= 8'bz;
	data_w <= 8'bz;
	dir <= 1'bz;
	PRDATA <= 8'bz;
	//PREADY <= 0;
	PSLVERR <= 0;

end


// enable ready logic
always @(posedge ready)
begin
	enable <= 0;
end




// APB completer FSM
always @(posedge PCLK)
begin
	
	case(state)
		
		2'b00 : begin
			//PREADY <= 0;
			PRDATA <= 8'bz;
			PSLVERR <= 0;
			if(PSEL==1)
				begin
				state <= 2'b01;
				end
			if(PWRITE==1)
				begin
				data_w <= PWDATA;
				end
			end
		
		2'b01 : begin

				addr <= PADDR;
				dir <= PWRITE;

				state <= 2'b10;

			end

		2'b10 : begin
			if(ready==1 || error==1)
				begin
				case(PWRITE)
	
					0 : begin
						PRDATA <= data_r;
					    end

				endcase
	
				PREADY <= 1;
				enable <= 0;
				state <= 2'b00;
				PSLVERR <= error;
				end
			end


	endcase

end


always @(posedge PENABLE)
begin
	enable <= 1;
end

always @(ready)
begin
	PREADY <= ready;
end



endmodule