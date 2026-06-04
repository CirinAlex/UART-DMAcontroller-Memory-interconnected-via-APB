


module TXshift(
	input reg[7:0] timerCurrentVal, //real-time output of uart-timer
	input reg[7:0] timerInitVal,
	input reg[7:0] TXbuff, 		//buffer for TX, data to transmit is written to this buffer
	input reg TXshiftenable, 	//signals the TX block to start transmitting, when TXshiftenable = 1, block enabled
	input reg clk, 			//master clock signal
	output reg TXshiftready, 	//Driven by this block to signal that TX has been completed, when TXshiftready = 1, TX completed
	output reg TX 			//output TX pin
);

reg[7:0] timeToShift; //stores the sampled value of timerCurrentVal when block is enabled, the shifting and consequently TX of a bit occurs when the timerCurrentVal is equal to this value
reg[9:0] TXbuffshift; //shift register buffer with added start bit and stop bit, start-bit + TXbuff + stop-bit
reg[3:0] counter;     //used to record the number of bits transmitted

always @(posedge TXshiftenable)
begin
 	// loading the shift register, ie., setting up the frame
	TXbuffshift[8:1] <= TXbuff;
	TXbuffshift[9] <= 1'b1;
	TXbuffshift[0] <= 1'b0;

	TXshiftready <= 1'b0;   // pulling the TXshiftready to 0, indicates that the block is BUSY
	timeToShift <= timerCurrentVal != 255? timerCurrentVal + 1: timerInitVal;
	counter <= 4'd10; 	// initialized with 10, because the total transmission in 10 bits
	TX <= 1; 		// initializes TX, to erase the UNKNOWN state
end


always @(timerCurrentVal)
begin	
			if(TXshiftenable==1 && counter!=0 && timerCurrentVal==timeToShift)
				begin
				TX <= TXbuffshift[0]; 			//transmitting the LSB
				TXbuffshift <= {1'b1, TXbuffshift[9:1]};// shifting
				counter <= counter - 4'b0001; 		//counter decremented by 1 per transmission
				end

			case({TXshiftenable,counter})		
				5'b10000 : begin 		// when counter reaches 0, ie., when all bits are finished transmitting
					if(timerCurrentVal==timeToShift)
					begin
						TXshiftready <= 1'b1; // block is ready for new data
					end
				end
				5'b0xxxx : TXshiftready <= 1'b1;      // block is ready because the block was disabled externally
			endcase
end
endmodule