


module clk_divider_tb;

reg master_clk;
wire uart_clk;
reg RE;
reg TE;


clk_divider C0(.master_clk(master_clk), .uart_clk(uart_clk), .RE(RE), .TE(TE));

always #1 master_clk = ~master_clk;

initial begin
$dumpfile("clk_divider.vcd");
$dumpvars();
master_clk = 0;

RE = 1;
#6;
TE = 1;

#640;

$finish;
end

endmodule
