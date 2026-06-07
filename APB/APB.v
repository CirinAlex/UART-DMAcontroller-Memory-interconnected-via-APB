


// APB interface module
// Uses multiplexed read and write data buses for easy synthesis

module APB(

// ports for master peripheral (here master is DMA)
	input reg[7:0] data_w, 	// data to write to the peripheral
	output reg[7:0] data_r, // data read from the peripheral
	input reg[7:0] addr, 	// address of memory or register to r/w data
	input reg dir,		// direction of data transfer write=1, read=0
	input reg enable,	// enable signal to begin transfer
	output reg ready, 	// signals the completion of transfer

// APB buses and control signals
	output reg[7:0] PWDATA, // data write bus
	input reg[7:0] PRDATA,  // data read bus
	output reg[7:0] PADDR,	 // address bus
	output reg[1:0] PSEL,	 // select lines, 1 for each peripheral. here, PSEL[1] for UART and PSEL[0] for memory
	output reg PCLK,	 // clock line for data transfer sync
	output reg PWRITE,	 // read/write control line, write=1, read=0
	output reg PENABLE, 	 // enable signal for APB
	input reg[1:0] PREADY	 // ready signals, PREADY[1] for UART and PREADY[0] for memory
);








endmodule