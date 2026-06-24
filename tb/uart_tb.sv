`timescale 1ns/1ps

module uart_top_tb;

  // System signals
  logic       clk;
  logic       rst;
  
  // Control and data signals
  logic [7:0] data_in;
  logic       wr_en;
  logic       rdy_clr;
  logic       rx;
  logic       tx;
  logic       ready;
  logic       busy;
  logic [7:0] data_out;

  // Loopback connection: TX directly drives RX for self-testing
  assign rx = tx;

  // Design Under Test (DUT)
  uart_top DUT (
    .clk      (clk),
    .rst      (rst),
    .rx       (rx),
    .data_in  (data_in),
    .wr_en    (wr_en),
    .rdy_clr  (rdy_clr),
    .tx       (tx),
    .ready    (ready),
    .busy     (busy),
    .data_out (data_out)
  );

  // 50MHz Clock Generation (20ns period)
  always #10 clk = ~clk;

  // ==========================================
  // TASK: Automated Send and Verify Routine
  // ==========================================
  task send_and_receive(input logic [7:0] test_data);
    begin
      $display("[%0t] Starting transmission of: 8'h%h", $time, test_data);

      // Trigger TX transmission
      @(negedge clk);
      data_in = test_data;
      wr_en   = 1'b1;

      @(negedge clk);
      wr_en = 1'b0;

      // Wait for TX to finish sending
      wait(busy == 1'b1); 
      wait(busy == 1'b0); 

      // Wait for RX to assemble the byte
      wait(ready == 1'b1);
      @(negedge clk); 

      // Self-checking verification
      if (data_out == test_data) begin
        $display("[%0t] SUCCESS! Data received: 8'h%h", $time, data_out);
      end else begin
        $display("[%0t] ERROR! Expected: 8'h%h | Received: 8'h%h", $time, test_data, data_out);
      end

      // Handshake: Clear the RX ready flag
      rdy_clr = 1'b1;
      @(negedge clk);
      rdy_clr = 1'b0;
      
      // Pause between packet transmissions
      #50000;
    end
  endtask

  // ==========================================
  // MAIN STIMULUS
  // ==========================================
  initial begin
    // Signal initialization
    clk     = 0;
    rst     = 1;
    data_in = 8'd0;
    wr_en   = 0;
    rdy_clr = 0;

    // Apply reset
    #100;
    rst = 0;
    #100;

    // Test patterns
    send_and_receive(8'hA5); // Alternating bits (10100101)
    send_and_receive(8'h3C); // Grouped bits (00111100)
    send_and_receive(8'hFF); // All 1s (Stop/Start bit stress)
    send_and_receive(8'h00); // All 0s

    $display("[%0t] All tests completed.", $time);
    $finish;
  end

endmodule