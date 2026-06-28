module uart_up_tb();

logic clk = 0, rst;
logic uart_tx_busy;
logic w_en;
logic uart_tx_valid;
logic [15:0] ram_data [0:2][0:2];
logic [15:0] ram_write [0:2][0:2];
logic [7:0] uart_out;
logic [7:0] uart_historico [$];
logic new_moves;

logic rx;
logic tx;
logic uart_rx_ready;
logic [7:0] uart_data_in, uart_data_out;

logic [7:0] data_out;
int j = 0;
logic [7:0] data [0:5];

localparam BIT_PERIOD = 8680;

uart_top UART(
    .clk(clk), 
    .rst(rst),
    .rx(rx),
    .data_in(uart_data_in),
    .wr_en(uart_tx_valid), 
    .tx(tx),
    .ready(uart_rx_ready),
    .busy(uart_tx_busy),
    .data_out(uart_data_out)
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

always #10 clk = ~clk;

initial begin
    rst = 1;
    new_moves = 0;
    #50;
    rst = 0;

    ram_data[0][0] = 16'd2;    // P1_MOV
    ram_data[0][1] = 16'd0;    // P2_MOV
    ram_data[1][0] = 16'd128;  // P1_POS
    ram_data[1][1] = 16'd128;  // P2_POS
    ram_data[0][2] = 16'd256;  // BALL_X
    ram_data[1][2] = 16'd128;  // BALL_Y
    ram_data[2][0] = 16'd3;    // P1_SCORE
    ram_data[2][1] = 16'd0;    // P2_SCORE
    ram_data[2][2] = 16'd0;    // START/RST

    @(posedge clk);
    #1;
    new_moves = 1;

    @(posedge clk);
    #1;
    new_moves = 0;

    wait (UP.current_state == 3'd0);
    for (int i = 0; i < 19; i++) begin
        ram_data[0][0] = 16'd2;    // P1_MOV
        ram_data[0][1] = 16'd0;    // P2_MOV
        ram_data[1][0] = 16'd128 - (5*(i+1));  // P1_POS
        ram_data[1][1] = 16'd128 + (5*(i+1));  // P2_POS
        ram_data[0][2] = 16'd256;  // BALL_X
        ram_data[1][2] = 16'd128;  // BALL_Y
        ram_data[2][0] = 16'd3;    // P1_SCORE
        ram_data[2][1] = 16'd0;    // P2_SCORE
        ram_data[2][2] = 16'd0;    // START/RST

        @(posedge clk);
        #1;
        new_moves = 1;

        @(posedge clk);
        #1;
        new_moves = 0;

        wait (UP.current_state == 3'd0);
    end
end

initial begin
    $display("P1_POS    |     P2_POS    |    BALL_X    |    BALL_Y    |    END_BYTE\n");
    forever begin
        @(negedge tx);
        #(BIT_PERIOD / 2);

        for (int i = 0; i < 8; i++) begin
            #(BIT_PERIOD);
            data_out[i] = tx;
        end 

        #(2 * BIT_PERIOD);
        
        data[j] = data_out;
        j = j + 1;

        if (j == 6) begin
            $display("%d    |    %d    |    %d    |    %d    |    %d", data[0], data[1], {data[2], data[3]}, data[4], data[5]);
            j = 0;
        end
        #(BIT_PERIOD * 2);
    end
end

endmodule