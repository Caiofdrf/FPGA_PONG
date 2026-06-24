module pong_tb();

logic clk;
logic rst;
logic rx;
logic tx;

pong_top PONG(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx(tx)
);


endmodule