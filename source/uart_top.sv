module uart_top (
    input logic clk, 
    input logic rst,
    input logic rx,
    input logic [7:0] data_in,
    input logic wr_en, 
    output logic tx,
    output logic ready,
    output logic busy,
    output logic uart_w_en,
    output logic [7:0] data_out
);
    logic rx_en;
    logic tx_en;

    uart_receiver UART_RX(
        .clk(clk), 
        .rst(rst),
        .rx(rx),
        .rx_en(rx_en),
        .ready(ready),
        .uart_w_en(uart_w_en),
        .data_out(data_out)
    );

    uart_transmitter UART_TX(
        .clk(clk),
        .rst(rst),
        .tx_en(tx_en),
        .tx_data_valid(wr_en),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    baud_rate_generator BAUD_GEN(
        .clk(clk),
        .rst(rst),
        .tx_en(tx_en),
        .rx_en(rx_en)
    );

endmodule