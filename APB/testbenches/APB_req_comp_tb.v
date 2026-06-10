


module APB_req_comp_tb;


reg ENABLE_DMA;
reg master_clk;	// PCLK


// APB BUS
wire[7:0] PWDATA;
wire [7:0] PADDR;
wire [1:0] PSEL;
wire PWRITE;
wire PENABLE;
wire[7:0] PRDATA;
wire[1:0] PREADY;
wire[1:0] PSLVERR;



// inputs to dut1 requester
reg[7:0] data_w_req;
reg[7:0] addr_req;
reg dir_req;
reg enable_req;


// outputs from dut1 requester
wire[7:0] data_r_req;
wire error_req;
wire ready_req;



// inputs to dut2 completer
reg[7:0] data_r_comp;
reg ready_comp;
reg error_comp;


//outputs from dut2 completer
wire[7:0] addr_comp;
wire dir_comp;
wire enable_comp;
wire[7:0] data_w_comp;



integer test_with_wait_state; // to indicate whether test is done with or without wait state

// TEST DATA FOR EACH TEST
parameter TEST_DATA_WRITE_WITHOUT_WW = 8'h76, TEST_DATA_WRITE_WITH_WW = 8'h67, TEST_DATA_READ_WITHOUT_WW = 8'h76, TEST_DATA_READ_WITH_WW = 8'h67;


// 8'h00 is the only accepted address that does not raise error signal in this testbench module
parameter TEST_ADDR_WRITE_WITHOUT_WW = 8'h67, TEST_ADDR_WRITE_WITH_WW = 8'h67, TEST_ADDR_READ_WITHOUT_WW = 8'h67, TEST_ADDR_READ_WITH_WW = 8'h67;


// address used to compare for error in this testbench module, 
parameter VALID_ADDR = 8'h11;	// must be valid with the requester module parameters



reg[7:0] data_to_write; // from requester
reg[7:0] data_written; // to completer

reg[7:0] data_to_read;  // from completer
reg[7:0] data_read; 	// to requester



APB_requester dut1(.PCLK(master_clk), .ENABLE_DMA(ENABLE_DMA), .data_w(data_w_req), .data_r(data_r_req), .addr(addr_req), .dir(dir_req), .error(error_req), .enable(enable_req), .ready(ready_req), .PWDATA(PWDATA), .PRDATA(PRDATA), .PADDR(PADDR), .PSEL(PSEL), .PWRITE(PWRITE), .PENABLE(PENABLE), .PREADY(PREADY), .PSLVERR(PSLVERR));



APB_completer dut2(.PCLK(master_clk), .ENABLE_DMA(ENABLE_DMA), .data_w(data_w_comp), .data_r(data_r_comp), .addr(addr_comp), .dir(dir_comp), .error(error_comp), .enable(enable_comp), .ready(ready_comp), .PWDATA(PWDATA), .PRDATA(PRDATA), .PADDR(PADDR), .PSEL(PSEL[0]), .PWRITE(PWRITE), .PENABLE(PENABLE), .PREADY(PREADY[0]), .PSLVERR(PSLVERR[0]));



//ready for requester side
always @(posedge ready_req)
begin
	enable_req <= 0;
	dir_req <= 1'bz;
	addr_req <= 8'bz;

	if(dir_req==0)
	data_read <= data_r_req;

end

always @(posedge enable_comp)
begin
	if(test_with_wait_state==0)
		begin
		if(dir_comp==0)
		begin
			if(addr_comp!=VALID_ADDR)
				error_comp = 1;
			else
				data_r_comp = data_to_read;

		end
		else
		begin
			if(addr_comp!=VALID_ADDR)
				error_comp = 1;
			else
				data_written = data_w_comp;
		end
		end
	else
		begin
		ready_comp = 0;
		#5;
		ready_comp = 1;
		if(dir_comp==0)
		begin
			if(addr_comp!=VALID_ADDR)
				error_comp = 1;
			else
				data_r_comp = data_to_read;
		end
		else
		begin
			if(addr_comp!=VALID_ADDR)
				error_comp = 1;
			else
				data_written = data_w_comp;
		end
		end
	ready_comp <= 1;
	
end

always @(posedge master_clk)
begin
	if(ready_comp==1)
	begin
		ready_comp <= 0;
		error_comp <= 0;
	end

end



always #1 master_clk = ~master_clk;

initial begin
$dumpfile("APB.vcd");
$dumpvars();



ready_comp = 0;
error_comp = 0;


data_w_req = 8'bz;

data_r_comp = 8'bz;



master_clk = 0;

enable_req = 0;

ENABLE_DMA = 0;
#5;
ENABLE_DMA = 1;
#1;


data_to_write = TEST_DATA_WRITE_WITH_WW;
// testing write operation with wait state.
test_with_wait_state = 1;
data_w_req = data_to_write;
addr_req = 8'h00;
dir_req = 1;
enable_req = 1;
#16;
error_comp = 0;

data_to_write = TEST_DATA_WRITE_WITHOUT_WW;
// testing write operation without wait state
test_with_wait_state = 0;
data_w_req = data_to_write;
addr_req = 8'h00;
dir_req = 1;
enable_req = 1;
#20;
error_comp = 0;

data_to_read = TEST_DATA_READ_WITH_WW;
// testing read operation with wait state
test_with_wait_state = 1;
//data_w_req = data_to_write;
addr_req = 8'h00;
dir_req = 0;
enable_req = 1;
#16;
error_comp = 0;

data_to_read = TEST_DATA_READ_WITHOUT_WW;
// testing write operation without wait state
test_with_wait_state = 0;
//data_w_req = data_to_write;
addr_req = 8'h00;
dir_req = 0;
enable_req = 1;
#16;
error_comp = 0;


$finish;
end


endmodule