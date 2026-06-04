
// RX top module

module RXtop(input reg RE, //Reception Enable signal, enable = 1
	   input reg RX,   //RX pin
	   output reg RI,  //Reception Interrupt connected to port ready
	   output wire[7:0] RXbuff, //recieved data buffer
	   input reg[7:0] timerCurrentVal,    //timer current value, produced by uart-timer
	   input reg[7:0] timerInitVal,//initial value for timer
	   input reg RI_in	    //signal to pull down RI externally
	);

	reg[1:0] state;	   //state variable
	reg RX_ckt_enable; //enable signal for RXshiftreg
	wire RX_ckt_ready; //ready signal from RXshiftreg
	


//instantiation

// RXshiftreg
RXshiftreg R0(.enableIN(RX_ckt_enable), .ready(RX_ckt_ready), .timerCurrentVal(timerCurrentVal), .timerInitVal(timerInitVal), .RX(RX), .RXbuff(RXbuff));
	

//pulls RI LOW when RI_in is pulled low, this is to clear RI externally
always @(negedge RI_in)
begin
	RI <= RI_in;
end


//initializes state when RE enabled
always @(RE)
	begin
		if(RE==1)
			state <= 2'b00;
	end




//RX main FSM
always @(RE, RX, RI, RX_ckt_ready, timerCurrentVal)
	begin
		case(state)
			
			// IDLE
			2'b00 : begin
				// goes to state START when RE enabled, also initializes RI
				  if(RE==1)begin
					RI<=0;
					state <= 2'b01;
					end
				  else if(RE==0)
				  begin
					state <= 2'b00;
				end
				  end

			// START
			2'b01 : begin
				//jumps to state RECIEVE when RX pin gets start-bit (0)
				  if(RE==1 && RI==0 && RX==0)
					begin
					state <= 2'b10;
					RX_ckt_enable <= 1;
					end
	
				//returns to state IDLE if RE pulled low
				  else if(RE==0)
					state <= 2'b00;
				  end

			// RECIEVE
			2'b10 : begin
				//returns to state IDLE if RE pulled low
				  if(RE==0)
					state <= 2'b00;
				  //if(RE==1 && RI==0)
					//begin
					//RX_ckt_enable <= 1; //enables reception block
					//end

				//when reception completed, shiftreg writes RX_ckt_ready = 1, so, RI is made 1, shiftreg disabled and jumps to state STOP
				  if(RE==1 && RX_ckt_ready==1) //ready high?  RI=1;
					begin
					RI <= 1'b1;
					RX_ckt_enable <= 0; //disables reception block
					state <= 2'b11;
					end

				end
			

			// STOP
			2'b11 : begin
				//returns to state IDLE if RE pulled low
				  if(RE==0)
					state <= 2'b00;

				//when RI is cleared externally, jumps to state START
				  else if(RE==1)
					begin
					if(RI==0)
						state <= 2'b01;
					end
				  end
		endcase

	end
endmodule

