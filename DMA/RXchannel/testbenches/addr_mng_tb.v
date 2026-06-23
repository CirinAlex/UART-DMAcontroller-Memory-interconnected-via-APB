


// addr_mng testbench module

module addr_mng_tb;


	  reg enable; 	// enable signal for this circuit
	  reg rw;		// r/w indicator 1=read, 0=write
	  wire[7:0] addr;	// address  
	  wire half_buffer;	// signals that half of the memory buffer has reached
	  wire full_buffer;	// signals full memory buffer reached
	  reg half_buffer_in;
	  reg full_buffer_in;
	  reg enable_DMA;

	// signals for memory buffer
	  reg[7:0] memory_start_address; 	// start address of memory buffer
	  reg[7:0] memory_buffer_offset;
	
		




addr_mng uut(.enable(enable), .rw(rw), .addr(addr), .half_buffer(half_buffer), .full_buffer(full_buffer), .enable_DMA(enable_DMA), .memory_start_address(memory_start_address), .memory_buffer_offset(memory_buffer_offset), .half_buffer_in(half_buffer_in), .full_buffer_in(full_buffer_in));



initial begin

$dumpfile("addr_mng.vcd");
$dumpvars();


enable_DMA = 0;
#1;
enable_DMA = 1;
half_buffer_in = 1;
full_buffer_in = 1;
memory_start_address = 8'h10;
memory_buffer_offset = 8'h08;
#8;
enable = 0;
#8;

for(integer i = 0; i < 10; i = i+1)
begin
	rw = 0;
	enable = 1;
	# 2;
	enable = 0;
	#2;
	rw = 1;
	enable = 1;
	#2;
	enable = 0;
	#2;
end
#5;

full_buffer_in = 0;
#5;

for(integer i = 0; i < 10; i = i+1)
begin
	rw = 0;
	enable = 1;
	# 2;
	enable = 0;
	#2;
	rw = 1;
	enable = 1;
	#2;
	enable = 0;
	#2;
end

#8;
$finish;


end






endmodule