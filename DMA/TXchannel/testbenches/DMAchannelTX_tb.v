

 // VERY VERY IMPORTANT, BUS GRANT IS MADE ZERO AFTER ONE CLOCK CYCLE


// DMA channel RX testbench


module DMAchannelRX_tb;


reg[7:0] mem1;
reg[7:0] mem2;
reg[7:0] mem3;
reg[7:0] mem4;
reg[7:0] TXbuff;

reg master_clk;
reg enable_DMA;
reg TI;
wire TI_in;
wire BUS_request;
reg BUS_grant;
wire error_reg;
reg half_buffer_in;
reg full_buffer_in;
wire half_buffer;
wire full_buffer;
reg[7:0] memory_start_address;
reg[7:0] memory_buffer_offset;
reg ready_transfer;
wire enable_transfer;
wire[7:0] addr_transfer_out;
reg[7:0] data_r;
wire[7:0] data_w;
wire dir_transfer;
reg error;




//instantiation of unit under test
DMAchannelRX UUT(.master_clk(master_clk), .enable_DMA(enable_DMA), .TI(TI), .TI_in(TI_in), .BUS_request(BUS_request), .BUS_grant(BUS_grant), .error_reg(error_reg), .half_buffer_in(half_buffer_in), .full_buffer_in(full_buffer_in), .half_buffer(half_buffer), .full_buffer(full_buffer), .memory_start_address(memory_start_address), .memory_buffer_offset(memory_buffer_offset), .ready_transfer(ready_transfer), .enable_transfer(enable_transfer), .addr_transfer_out(addr_transfer_out), .data_r(data_r), .data_w(data_w), .dir_transfer(dir_transfer), .error(error));


always #1 master_clk = ~master_clk;

initial begin

$dumpfile("DMATX.vcd");
$dumpvars();


master_clk = 0;
TI = 0;
BUS_grant = 0;
ready_transfer = 1;

#3;
enable_DMA = 0;
memory_start_address = 8'h40;
memory_buffer_offset = 8'd4;


mem1 = 8'b10101110;
mem2 = 8'b10001010;
mem3 = 8'b00101010;
mem4 = 8'b10111110;


#1;
enable_DMA = 1;
#4;

TI = 1;


#200;
enable_DMA = 0;
#2;
enable_DMA = 1;
#20;
$finish;


end


always @(posedge BUS_request)
begin

#5;

BUS_grant = 1;

end





always @(posedge enable_transfer)
begin
ready_transfer = 0;

#4;

case(addr_transfer_out)

8'h82 : begin
	if(dir_transfer==0)
	begin
		TXbuff = data_w;
	end
	else
	begin
		error = 1;
	end
	end

8'h40 : begin
	if(dir_transfer==1)
	begin
		data_r = mem1; //8'b10101110;
	end
	else
	begin
		error = 1;
	end
	end

8'h41 : begin
	if(dir_transfer==1)
	begin
		data_r = mem2; //8'b10001010;
	end
	else
	begin
		error = 1;
	end
	end

8'h42 : begin
	if(dir_transfer==1)
	begin
		data_r = mem3; //8'b00101010;
	end
	else
	begin
		error = 1;
	end
	end

8'h43 : begin
	if(dir_transfer==1)
	begin
		data_r = mem4; //8'b10111110;
	end
	else
	begin
		error = 1;
	end
	end

endcase


#6;
#1;
ready_transfer = 1;

#1; // VERY VERY IMPORTANT, BUS GRANT IS MADE ZERO AFTER ONE CLOCK CYCLE
//BUS_grant = 0;

end



always @(negedge BUS_request)
begin

if(BUS_request==0)
begin
	BUS_grant = 0;
end
end



endmodule