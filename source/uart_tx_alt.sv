
module uart_transmitter(
	input logic clk,
  	input logic rst,
    input logic [7:0] tx_data,
    input logic tx_data_valid,
    output logic tx_data_ready,
    output logic UART_TX
);
  
  import UART_CONFIG::*;
  
  logic tx_data_ready_i;
  logic uart_tx_i;
  logic [WORD_LENGTH - 1 :0] tx_data_i;
  
  always_ff @(posedge clk) begin
    if (rst) begin
      tx_data_i <= tx_data;
    end
    
    else begin
      if (tx_data_valid & tx_data_ready_i) begin
        tx_data_i <= tx_data;
      end
    end
  end
  
  enum {IDLE, START, DATA, PARITY, STOP, WAIT} current_state, next_state;
  
  localparam TX_IDLE = 1'b1;
  localparam TX_START = 1'b0;
  localparam TX_STOP = 1'b1;
  
  localparam BAUD_COUNTER_MAX = CLK_FREQ / BAUD;
  localparam BAUD_COUNTER_SIZE = $clog2(BAUD_COUNTER_MAX);
  
  localparam DATA_COUNTER_MAX = WORD_LENGTH;
  localparam DATA_COUNTER_SIZE = $clog2(DATA_COUNTER_MAX);
  
  logic [BAUD_COUNTERSIZE - 1 : 0] uart_baud_counter;
  logic [DATA_COUNTERSIZE - 1 : 0] uart_data_counter;
  logic uart_baud_done;
  logic uart_data_done;
  
  logic [7:0] uart_data_shift_buffer;
  
  
  always_ff @(posedge clk) begin
    if (rst) begin
      uart_baud_counter <= 0;
    end
    
    else begin
      if (current_state != next_stage) begin
        uart_baud_counter <= 0;
      end
      
      else begin
        uart_baud_counter <= uart_baud_counter + 'd1;
      end
    end
  end
  
  assign uart_baud_done = (uart_baud_counter == BAUD_COUNTER_MAX - 1);
  
  always_ff @(posedge clk) begin
    if (rst) begin
      uart_data_counter <= 'b0;
      uart_data_shift_buffer <= tx_data_i;
    end
    
    else if (uart_baud_done) begin
      if (current_state != next_state) begin
        uart_data_counter <= 'b0;
        uart_data_shift_buffer <= tx_data_i;
      end
      
      else begin
        uart_data_counter <= uart_data_counter + 'b1;
        uart_data_shift_buffer <= uart_data_shift_buffer >> 1;
      end
    end
  end
  
  assign uart_data_done = (uart_data_counter == DATA_COUNTER_MAX - 1);
  
  
  always_ff @(*) begin
    case (current_state)
      IDLE: begin
        if (tx_data_valid) begin
          next_state = START;
        end
        
        else begin
          next_state = current_state;
        end
      end
      
      START: begin
        if (uart_baud_done) begin
          next_state = DATA;
        end
        
        else begin 
          next_state = current_state;
        end
      end
      
      DATA: begin
        if (uart_data_done & uart_baud_done) begin
          next_stage = PARITY;
        end
        
        else begin
          next_state = current_state;
        end
      end
      
      PARITY: begin
        if (uart_baud_done) begin 
          next_state = STOP;
        end
        
        else begin
          next_state = current_state;
        end
      end
      
      STOP: begin
        if (uart_baud_done) begin
          next_state = WAIT;
        end
        
        else begin
          next_state = current_state;
        end
      end
      
      WAIT: begin
        if (uart_baud_done) begin
          next_state = IDLE;
        end
        
        else begin
          next_state = current_state;
        end
      end
      
      default: begin
        next_state = current_state;
      end
    endcase
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      current_state = IDLE;
    end
    
    else begin
      current_state = next_state;
    end
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      uart_tx_i <= TX_IDLE;
    end
    
    else begin
      case (next_state) 
        IDLE: begin
          uart_tx_i <= TX_IDLE;
        end
        
        START: begin
          uart_tx_i <= TX_START;
        end
        
        DATA: begin
          uart_tx_i <= uart_data_shift_buffer[0];
        end
        
        PARITY: begin
          uart_tx_i <= ^tx_data_i;
        end
        
        STOP: begin
          uart_tx_i <= TX_STOP;
        end
        
        WAIT: begin
          uart_tx_i <= TX_IDLE;
        end
        
      endcase
    end
  end
  
  assign tx_data_ready_i = (current_state == IDLE);
  assign tx_data_ready = tx_data_ready_i;
  assign UART_TX = uart_tx_i;
endmodule