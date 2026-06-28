module uart_ram_tb();

logic clk = 0, rst;
logic uart_tx_busy;
logic w_en;
logic uart_tx_valid;
logic [15:0] ram_data [0:2][0:2];
logic [15:0] ram_write [0:2][0:2];
logic new_moves;

logic uart_w_en;

logic rx;
logic tx;
logic uart_rx_ready;
logic [7:0] uart_data_in, uart_data_out;

logic [7:0] data_out;
logic [7:0] data [0:5];

logic [7:0] data_in;

localparam BIT_PERIOD = 8680;
localparam CLK_PERIOD = 20;

uart_top UART(
    .clk(clk), 
    .rst(rst),
    .rx(rx),
    .data_in(uart_data_out),
    .wr_en(uart_tx_valid), 
    .tx(tx),
    .ready(uart_rx_ready),
    .busy(uart_tx_busy),
    .uart_w_en(uart_w_en),
    .data_out(uart_data_in)
);

ram_memory RAM(
    .clk(clk), 
    .rst(rst),
    .uart_w_en(uart_w_en),
    .w_en(w_en),
    .data_in(ram_write),      
    .uart_data_in(uart_data_in),
    .data_out(ram_data),
    .new_moves(new_moves)
);

always #10 clk = ~clk;

task print_ram_state();
    $display("\n--- ESTADO ATUAL DA MEMÓRIA RAM ---");
    $display(" P1_MOV: %d  | P2_MOV: %d  | BALL_X: %d", RAM.ram[0][0], RAM.ram[0][1], RAM.ram[0][2]);
    $display(" P1_POS: %d  | P2_POS: %d  | BALL_Y: %d", RAM.ram[1][0], RAM.ram[1][1], RAM.ram[1][2]);
    $display(" P1_SC:  %d  | P2_SC:  %d  | ST_RST: %d", RAM.ram[2][0], RAM.ram[2][1], RAM.ram[2][2]);
    $display("------------------------------------\n");
endtask

task send_uart_byte(input logic [7:0] bits);
    begin
        rx = 1'b0;
        #BIT_PERIOD;
        for (int i = 0; i < 8; i++) begin
            rx = bits[i];
            #BIT_PERIOD;
        end
        rx = 1'b1;
    #BIT_PERIOD;
    end
endtask

// Computação dos inputs
initial begin
    clk = 0;
    rst = 1;
    rx = 1'b1;

    #(CLK_PERIOD * 5);
    rst = 0;
    #(CLK_PERIOD * 5);

    data_in = 8'b00001001;
    send_uart_byte(data_in);

    print_ram_state();
    data_in = 8'b00000000;
    send_uart_byte(data_in);

    print_ram_state();
    #(BIT_PERIOD * 100);

    $display("Simulation done!\n");
    $finish;
end

endmodule