module ram_memory(
    input logic clk, 
    input logic rst,
    input logic uart_w_en,
    input logic w_en,
    input logic [15:0] data_in [0:2][0:2],      // Informações vindas da UP
    input logic [7:0] uart_data_in,             // Informações vindas da UART
    output logic [15:0] data_out [0:2][0:2]     // Informações saindo para UP
);

/*
Matriz da memória RAM:

P1_MOV     |      P2_MOV      |      BALL_X
P1_POS     |      P2_POS      |      BALL_Y
P1_SCORE   |      P2_SCORE    |     START/RST

*/
logic [15:0] ram [0:2][0:2];
assign data_out = ram;

initial begin
    ram[0][0] = 16'd1;    // P1_MOV
    ram[0][1] = 16'd1;    // P2_MOV
    ram[1][0] = 16'd128;  // P1_POS
    ram[1][1] = 16'd128;  // P2_POS
    ram[0][2] = 16'd256;  // BALL_X
    ram[1][2] = 16'd128;  // BALL_Y
    ram[2][0] = 16'd0;    // P1_SCORE
    ram[2][1] = 16'd0;    // P2_SCORE
    ram[2][2] = 16'd0;    // START/RST
end

always_ff @(posedge clk) begin
    if (rst) begin
        ram[0][0] <= 16'd1;    // P1_MOV
        ram[0][1] <= 16'd1;    // P2_MOV
        ram[1][0] <= 16'd128;  // P1_POS
        ram[1][1] <= 16'd128;  // P2_POS
        ram[0][2] <= 16'd256;  // BALL_X
        ram[1][2] <= 16'd128;  // BALL_Y
        ram[2][0] <= 16'd0;    // P1_SCORE
        ram[2][1] <= 16'd0;    // P2_SCORE
        ram[2][2] <= 16'd0;    // START/RST
    end

    else begin
        if (uart_w_en) begin
            ram[0][0] <= {14'd0, uart_data_in[1:0]};
            ram[0][1] <= {14'd0, uart_data_in[3:2]};
            ram[2][2] <= {15'd0, uart_data_in[7]};
        end

        if (w_en) begin
            ram <= data_in;
        end
    end
end
endmodule