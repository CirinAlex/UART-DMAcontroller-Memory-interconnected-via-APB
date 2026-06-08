


// APB interface module
module APB(
	//input reg master_clk;
	input reg pwakeup,	// wakeup signal from external source, used to initialize state variable

// ports for master peripheral (here master is DMA)
	input reg[7:0] data_w, 	// data to write to the peripheral
	output reg[7:0] data_r, // data read from the peripheral
	input reg[7:0] addr, 	// address of memory or register to r/w data
	input reg dir,		// direction of data transfer write=1, read=0
	output reg error,	// error signal for invalid address or direction
	input reg enable,	// enable signal to begin transfer, initialize state variable, masterclock gating
	output reg ready, 	// signals the completion of transfer

// APB buses and control signals
	output reg[7:0] PWDATA, // data write bus
	input reg[7:0] PRDATA,  // data read bus
	output reg[7:0] PADDR,	 // address bus
	output reg[1:0] PSEL,	 // select lines, 1 for each peripheral. here, PSEL[1] for UART and PSEL[0] for memory
	output reg PCLK,	 // clock line for data transfer sync
	output reg PWRITE,	 // read/write control line, write=1, read=0
	output reg PENABLE, 	 // enable signal for APB
	input reg[1:0] PREADY,	 // ready signals, PREADY[1] for UART and PREADY[0] for memory
	input PSLVERR		// error response, used to indicate invalid address or direction.
);


// MEMORY_X_ADDR => memory address range
// UART_X_ADDR => UART TX and RX reg addresses
parameter MEMORY_STRT_ADDR = 8'h00, MEMORY_END_ADDR = 8'h7f, UART_TX_ADDR = 8'h80, UART_RX_ADDR = 8'h81, WIDTH = 7;



reg[1:0] state; //state variable


// initializing state variable on external wakeup signal
always @(pwakeup)
begin
	state <= 2'b00;
	PSEL <= 2'b00;
	PWRITE <= 1'bz;
	PWDATA <= 8'bz;
	PADDR <= 8'bz;
	error <= 0;
end


// On positive edge of enable, ready pulled LOW, PWRITE initialized, data_x written to the PXDATA, addr written to PADDR
always @(posedge enable)
begin
	error <= 0;
	ready <= 0;
	PWRITE <= dir; 	// setting PWRITE
	
	// setting data bus according to dir input by master peripheral.
	case(dir)
		1 : PWDATA <= data_w;
	endcase
	PADDR <= addr;
	PENABLE <= 0;

end


// On posedge of enable, drive PSELx to HIGH based on the addr, ie. address to PSEL mapping
always @(posedge enable)
begin
	if(addr[WIDTH:0] >= MEMORY_STRT_ADDR && addr[WIDTH:0] <= MEMORY_END_ADDR)
		PSEL[0] = 1;
	else if(addr == UART_RX_ADDR || addr == UART_TX_ADDR)
		PSEL[1] = 1;

end



// FSM
always @(PCLK)
begin
	
	case(state)
		2'b00 : begin
			if(PSEL[1:0] != 2'b00)
				state <= 2'b01;
			end

		// SETUP
		2'b01 : begin
			PENABLE <= 1;
			state <= 2'b10;
			end

		// ACCESS
		2'b10 : begin
			
			// ready and error cases
			case({PREADY, PSLVERR})
			2'b10 : begin
			
				case(PWRITE)
					1 : begin
						// keeping data bus in high impedance after transfer
						PWDATA <= 8'bz;
					end

					0 : begin
						// reading data to data_r (giving to master peripheral)
						data_r <= PRDATA;
					end
				endcase
				// pulling addr bus and pwrite to high impedance after transfer is complete, also signalling 
				// transfer complete to master peripheral by pulling ready HIGH
				PADDR <= 8'bz;
				PWRITE <= 1'bz;
				ready <= 1;
				state <= 2'b00;
				PSEL <= 2'b00;
			end

			// error HIGH, forwards to master and goes to state 00
			2'b11 : begin
					state <= 2'b00;
					error <= 1;
				end

			// remains in ACCESS state
			2'b0x : state <= 2'b10;

	endcase



end







endmodule