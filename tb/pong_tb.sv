`timescale 1ns/1ps

module pong_tb();

logic clk;
logic rst;
logic rx;
logic tx;
int file_input, file_output;
string line;

localparam CLK_PERIOD = 20;
localparam BIT_PERIOD = 8680;

pong_top PONG(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx(tx)
);

always #(CLK_PERIOD/2) clk = ~clk;

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

// Computação dos outputs
initial begin
    file_output = $fopen("../movements_output.txt", "w");

    if (file_output == 0) begin
        $display("Falha ao abrir arquivo de outputs");
    end

    $fdisplay(file_output, "P1_POS    |     P2_POS    |    BALL_X    |    BALL_Y    |    END_BYTE\n");
    forever begin
        @(negedge tx);
        #(BIT_PERIOD / 2);
        #(BIT_PERIOD);

        for (int i = 0; i < 8; i++) begin
            data_out[i] = tx;
            #(BIT_PERIOD);
        end 

        $fdisplay(file_output, "%d", data_out);
        $fflush(file_output);
    end
end

// Computação dos inputs
initial begin
    clk = 0;
    rst = 1;
    rx = 1'b1;

    #(CLK_PERIOD * 5);
    rst = 0;
    #(CLK_PERIOD * 5);
    file_input = $fopen("../movements_input.txt", "r");
    if (file_input == 0) begin
        $display("Falha ao abrir arquivo de inputs");
    end

    while($fscanf(file_input, "%b\n", data_in) == 1) begin
        send_uart_byte(data_in);
        #(BIT_PERIOD * 3);
    end
    
    $fclose(file_input);
    $fclose(file_output);

    $display("Simulation done!\n");
    $finish;
end
endmodule