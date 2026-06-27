module processing_unit_tb();

logic clk = 0, rst;
logic new_moves;
logic uart_tx_busy;
logic w_en;
logic uart_tx_valid;
logic [15:0] ram_data [0:2][0:2];
logic [15:0] ram_write [0:2][0:2];
logic [7:0] uart_out;
logic [7:0] uart_historico [$];
  
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

always #20 clk = ~clk;

always @(posedge clk) begin
  if (uart_tx_valid) begin
      uart_historico.push_back(uart_out);
      $display("[MONITOR] Byte detectado e guardado: %h (Total acumulado: %0d)", uart_out, uart_historico.size());
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
    
    $display("\n--- MATRIZ RAM DE SAIDA (PROCESSADA) ---");
    $display(" %d  |  %d  |  %d", ram_write[0][0], ram_write[0][1], ram_write[0][2]);
    $display(" %d  |  %d  |  %d", ram_write[1][0], ram_write[1][1], ram_write[1][2]);
    $display(" %d  |  %d  |  %d", ram_write[2][0], ram_write[2][1], ram_write[2][2]);

  	#10;
    $display("\n--- TODOS OS BYTES CAPTURADOS NA UART ---");
    foreach (uart_historico[i]) begin
      $display("Byte [%0d]: 8'h%d (ou em binário: %b)", i, uart_historico[i], uart_historico[i]);
    end

    for (int r = 0; r < 3; r++) begin
        for (int c = 0; c < 3; c++) begin
            ram_data[r][c] = ram_write[r][c];
        end
    end
  
    ram_data[0][0] = 2;
    ram_data[0][1] = 0;
  
  	@(posedge clk);
    #1;
    new_moves = 1;
    
    @(posedge clk);
    #1;
    new_moves = 0;

    wait (UP.current_state == 3'd0);
    
    $display("\n--- MATRIZ RAM DE SAIDA (PROCESSADA) ---");
    $display(" %d  |  %d  |  %d", ram_write[0][0], ram_write[0][1], ram_write[0][2]);
    $display(" %d  |  %d  |  %d", ram_write[1][0], ram_write[1][1], ram_write[1][2]);
    $display(" %d  |  %d  |  %d", ram_write[2][0], ram_write[2][1], ram_write[2][2]);

  	#10;
    $display("\n--- TODOS OS BYTES CAPTURADOS NA UART ---");
    foreach (uart_historico[i]) begin
      $display("Byte [%0d]: 8'h%d (ou em binário: %b)", i, uart_historico[i], uart_historico[i]);
    end    
    $finish;
end

endmodule