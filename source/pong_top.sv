`timescale 1ns/1ps

module pong_top(
    input logic clk, 
    input logic rst,
    input logic rx,
    output logic tx
);

logic [15:0] ram_data [0:2][0:2];
logic [15:0] ram_write [0:2][0:2];
logic [7:0] uart_data_in;
logic [7:0] uart_data_out;
logic uart_tx_busy;
logic uart_tx_valid;
logic w_en;
logic data_valid;
logic uart_rx_ready;
logic uart_w_en;
logic new_moves;

uart_top UART(
    .clk(clk), 
    .rst(rst),
    .rx(rx),
    .data_in(uart_data_in),
    .wr_en(uart_tx_valid),
    .tx(tx),
    .ready(uart_rx_ready),
    .busy(uart_tx_busy),
    .uart_w_en(uart_w_en),
    .data_out(uart_data_out)
);

ram_memory RAM(
    .clk(clk), 
    .rst(rst),
    .uart_w_en(uart_w_en),
    .w_en(w_en),
    .data_in(ram_write),      
    .uart_data_in(uart_data_out),
    .data_out(ram_data),
    .new_moves(new_moves)
);

processing_unit UP(
    .clk(clk),
  	.rst(rst),
    .new_moves(new_moves),
    .uart_tx_busy(uart_tx_busy),
    .ram_data(ram_data),
    .w_en(w_en),
    .uart_tx_valid(uart_tx_valid),
    .ram_write(ram_write),
    .uart_out(uart_data_in)
);

endmodule