

// APB_requester testbench

module APB_requester_tb;



// inputs to dut
reg ENABLE_DMA;
reg master_clk;		// functions as PCLK
reg[7:0] data_w;
reg[7:0] addr;
reg dir;
reg enable;
reg[7:0] PRDATA;
reg[1:0] PREADY;
reg[1:0] PSLVERR;

// outputs from dut
wire[7:0] data_r;
wire error;
wire ready;
wire[7:0] PWDATA;
wire [7:0] PADDR;
wire [1:0] PSEL;
wire PWRITE;
wire PENABLE;

reg[7:0] write_data;
reg[7:0] read_data;


APB_requester dut(.PCLK(master_clk), .ENABLE_DMA(ENABLE_DMA), .data_w(data_w), .data_r(data_r), .addr(addr), .dir(dir), .error(error), .enable(enable), .ready(ready), .PWDATA(PWDATA), .PRDATA(PRDATA), .PADDR(PADDR), .PSEL(PSEL), .PWRITE(PWRITE), .PENABLE(PENABLE), .PREADY(PREADY), .PSLVERR(PSLVERR));

integer op;

always @(posedge PENABLE)
begin
// Peripheral side
if(PSEL[0]==1)
	begin

	// WRITE operation
	if(PWRITE==1 && PENABLE==1)
		begin
		PREADY[0] = 1;
		write_data = PWDATA;
		op = 1;
		end

	// READ operation
	if(PWRITE==0 && PENABLE==1)
		begin
		PREADY[0] = 1;
		PRDATA <= read_data;
		end

	end
end


always @(posedge ready)
begin
	enable <= 0;

end





always #1 master_clk = ~master_clk;

initial begin

$dumpfile("APB_requester.vcd");
$dumpvars();

enable = 0;
op = 0;

master_clk = 0;
ENABLE_DMA = 0;
PREADY = 2'b00;
PSLVERR = 2'b00;

#3;
ENABLE_DMA = 1;
#10;

// testing write operation
data_w = 8'h67;
addr = 8'h10;
dir = 1;
#2;
enable = 1;
#30;
PREADY[0] = 0;



// testing read operation
read_data = 8'h59;
addr = 8'h01;
dir = 0;
#2;
enable = 1;


#50;
$finish;

end

endmodule