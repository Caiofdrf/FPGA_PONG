`timescale 1ns/1ps

module pong_top(
    input logic clk, 
    input logic rst,
    input logic rx,
    output logic tx
);

logic [15:0] ram_data_out [0:2][0:2];
logic [15:0] ram_data_in [0:2][0:2];
logic [7:0] uart_data_in;
logic [7:0] uart_data_out;
logic busy;
logic w_en;
logic data_valid;
logic uart_rx_ready;

uart_top UART(
    .clk(clk), 
    .rst(rst),
    .rx(rx),
    .data_in(uart_data_in),
    .wr_en(data_valid), 
    .tx(tx),
    .ready(uart_rx_ready),
    .busy(busy),
    .data_out(uart_data_out)
);

ram_memory RAM_U(
    .clk(clk), 
    .rst(rst),
    .uart_w_en(uart_rx_ready),
    .w_en(w_en),
    .data_in(ram_data_in),      
    .uart_data_in(uart_data_out),
    .data_out(ram_data_out)
);

processing_unit PROCESS_U(
    .clk(clk), 
    .rst(rst),
    .new_moves(uart_rx_ready),
    .uart_tx_busy(busy),
    .ram_data(ram_data_out),
    .w_en(w_en),
    .uart_tx_valid(data_valid),
    .ram_write(ram_data_in),
    .uart_out(uart_data_in)
);
endmodule