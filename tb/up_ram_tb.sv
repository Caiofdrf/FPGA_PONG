module up_ram_tb();

logic clk = 0, rst;
logic uart_tx_busy;
logic w_en;
logic uart_tx_valid;
logic [15:0] ram_data [0:2][0:2];
logic [15:0] ram_write [0:2][0:2];
logic [7:0] uart_out;
logic [7:0] uart_historico [$];
logic new_moves;

logic uart_w_en;
logic [7:0] uart_data_in;

processing_unit UP(
    .clk(clk),
  	.rst(rst),
    .new_moves(new_moves),
    .uart_tx_busy(uart_tx_busy),
    .ram_data(ram_data),
    .w_en(w_en),
    .uart_tx_valid(uart_tx_valid),
    .ram_write(ram_write),
    .uart_out(uart_out)

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

always #20 clk = ~clk;

always @(posedge clk) begin
  if (uart_tx_valid) begin
      uart_historico.push_back(uart_out);
      $display("[MONITOR] Byte detectado e guardado: %d (Total acumulado: %0d)", uart_out, uart_historico.size());
      $display("w_en: %d", w_en);
  end
end

always @(posedge clk) begin
  if (uart_tx_valid) begin
    uart_tx_busy <= 1'b1;
  end 
  else if (uart_tx_busy) begin
    repeat(4) @(posedge clk); 
    uart_tx_busy <= 1'b0;
  end
end

task print_ram_state();
    $display("\n--- ESTADO ATUAL DA MEMÓRIA RAM ---");
    $display(" P1_MOV: %d  | P2_MOV: %d  | BALL_X: %d", RAM.ram[0][0], RAM.ram[0][1], RAM.ram[0][2]);
    $display(" P1_POS: %d  | P2_POS: %d  | BALL_Y: %d", RAM.ram[1][0], RAM.ram[1][1], RAM.ram[1][2]);
    $display(" P1_SC:  %d  | P2_SC:  %d  | ST_RST: %d", RAM.ram[2][0], RAM.ram[2][1], RAM.ram[2][2]);
    $display("------------------------------------\n");
endtask

initial begin
    rst = 1;
    uart_w_en = 0;
    uart_data_in = 8'd0;
    #50;
    rst = 0;
    @(posedge clk);
    uart_data_in = 8'b00000010;
    uart_w_en = 1;
    @(posedge clk);
    #1;
    uart_w_en = 0;

    print_ram_state();

    wait (UP.current_state == 3'd0);   // Espera voltar para IDLE
    print_ram_state();

    #100;

    uart_data_in = 8'b00001001;
    uart_w_en = 1;
    @(posedge clk);
    #1;
    uart_w_en = 0;
    
    print_ram_state();

    wait (UP.current_state == 3'd0);
    print_ram_state();

    #50;

    $display("\n=== FIM DA SIMULAÇÃO: HISTÓRICO UART ===");
    foreach (uart_historico[i]) begin
        $display("Byte [%0d]: %d", i, uart_historico[i]);
    end
    
    $finish;
end

endmodule