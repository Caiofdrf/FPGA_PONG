`define CLK_FREQ 50000000
`define BAUD 115200

module baud_rate_generator(
	  input logic clk,
  	input logic rst,
  	output logic tx_en,
  	output logic rx_en
);
  
  localparam TX_COUNTER_MAX = `CLK_FREQ / `BAUD;
  localparam RX_COUNTER_MAX = `CLK_FREQ / (`BAUD * 16);

  logic [9:0] tx_counter;
  logic [5:0] rx_counter;
  
  always_ff @(posedge clk) begin
    if (rst) begin
      tx_counter <= 1'b0;
    end
    
    else if (tx_counter == (TX_COUNTER_MAX - 1)) begin
      tx_counter <= 1'b0;
    end
    
    else begin
      tx_counter <= tx_counter + 1'b1;
    end
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      rx_counter <= 1'b0;
    end
    
    else if (rx_counter == (RX_COUNTER_MAX - 1)) begin
      rx_counter <= 1'b0;
    end
    
    else begin
      rx_counter <= rx_counter + 1'b1;
    end
  end
  
  assign tx_en = (tx_counter == 0);
  assign rx_en = (rx_counter == 0);
  
endmodule
