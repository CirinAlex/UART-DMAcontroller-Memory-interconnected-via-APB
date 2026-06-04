
module RXshiftreg(input reg enableIN, 	// external signal to enable RXshift block
		output reg ready, 	// output signal to mention RXshift is ready to take date to transmit
		input reg[7:0] timerCurrentVal, //current value of timer register
		input reg[7:0] timerInitVal, 	//initial value of timer register, this value is initialized to the uart-timer and the timer autoreloads this value on overflow
		input reg RX, 			//RX output pin
		output reg[7:0] RXbuff		//buffer that stores recieved data
		);

reg[7:0] smplngTime; //the time at which RX pin should be sampled
reg[9:0] RXrawbuff;  //shift register buffer, includes start bit and stop bit along with data
reg[3:0] counter;    //stores the number of bits to recieve in current frame

reg[7:0] samp;



// initializing registers on enable
always @(posedge enableIN)
begin

if((((timerCurrentVal-timerInitVal) + (256-timerCurrentVal))/2'd2)%2==1)

 smplngTime <= (((256 - timerInitVal)/2) + 1) >= (256 - timerCurrentVal) ? timerInitVal + ((((256 - timerInitVal)/2) + 1) - (256 - timerCurrentVal)) : timerCurrentVal + (((256 - timerInitVal)/2) + 1); //midpoint = (255-timerInitVal)/2
//((midpoint + 1) - (255-timerCurrentVal)) + timerInitVal


else
	 smplngTime <= ((256 - timerInitVal)/2) >= (256 - timerCurrentVal) ? timerInitVal + ((((256 - timerInitVal)/2)) - (256 - timerCurrentVal)) : timerCurrentVal + ((256 - timerInitVal)/2);


//setting sampling time, calculated inorder to sample RX in middle of a bit by considering the time (timerCurrentVal) when RXshiftreg block was enabled







	counter <= 4'd10; 	//initialized counter, total 10 bits to recieve in a frame
	ready <= 1'b0;	  	//pulling ready signal 0, indicates parent module that th RXshiftreg module is BUSY
	RXrawbuff <= 10'd0; 	//initializes rawbuff
	RXbuff <= 8'd0; 	//initializes RXbuff
end


always @(counter)
begin

if(enableIN == 1'b1 && counter == 4'd0)
begin
	RXbuff <= RXrawbuff[8:1];
	ready <= 1'b1;
end

end



//shift register main block
always @(timerCurrentVal)
begin

//updates rawbuff by shifting and recieving bit, counter decremented on sampling of a bit to keep no. of bits left to recieve
if(enableIN == 1'b1 && timerCurrentVal == smplngTime && counter != 4'd0)
begin
	RXrawbuff <= {RX, RXrawbuff[9:1]};
	counter <= counter - 1'b1;

end



//ends reception as soon as counter reaches 0 ie, recieved a complete frame and transfers data to RXbuff after trimming start and stop bits, block is then ready to recieve next frame


end

endmodule