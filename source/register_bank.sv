`timescale 1ns/1ps

module register_banks (
	input logic clk,
	input logic rst,
  	input logic uart_w_en,
  	input logic w_en,
  	input logic r_en,
    input logic [1:0] w_addr,
    input logic [1:0] r_addr,
    input logic [7:0] uart_data_in,
    input logic [15:0] data_in1,
    input logic [15:0] data_in2,
    output logic [15:0] data_out1,
    output logic [15:0] data_out2
);
  
  // Case 0
  logic [15:0] p1_pos;
  logic [15:0] p2_pos;
  // Case 1
  logic [1:0] player_moves [1:0];
  // Case 3
  logic [15:0] ball_pos [1:0];
  // Case 5
  logic [15:0] score [1:0];
  
  always_ff @(posedge clk) begin
    if (rst) begin
      p1_pos <= 16'd128;
      p2_pos <= 16'd128;
      player_moves[0] <= 2'd1;
      player_moves[1] <= 2'd1;
      player_vel <= 16'd5;
      ball_pos[0] <= 16'd256;
      ball_pos[1] <= 16'd128;
      ball_vel[0] <= 16'd4;
      ball_vel[1] <= 16'd0;
      score[0] <= 16'd0;
      score[1] <= 16'd0;
    end
    
    else if (uart_w_en) begin
      player_moves[0] <= uart_data_in[1:0];
      player_moves[1] <= uart_data_in[3:2];
    end
    else if (w_en) begin
      case (w_addr)
        'd1: begin
            p1_pos <= data_in1;
            p2_pos <= data_in2;
        end
        'd2: begin
            ball_pos[0] <= data_in1;
            ball_pos[1] <= data_in2;
        end
        'd3: begin
            score[0] <= data_in1;
            score[1] <= data_in2;
        end
        default: begin
          
        end
      endcase
    end
  end
  
  always_comb begin
    if (r_en) begin 
      case (r_addr)
      	'd0: begin
          data_out1 = {14'd0, player_moves[0]};
          data_out2 = {14'd0, player_moves[1]};
        end
        
      	'd1: begin
          data_out1 = p1_pos;
          data_out2 = p2_pos;
        end
        
      	'd2: begin
          data_out1 = ball_pos[0];
          data_out2 = ball_pos[1];
        end
        
      	'd3: begin
          data_out1 = score[0];
          data_out2 = score[1];
        end
        
        default: begin
          data_out1 = 0;
          data_out2 = 0;	
        end
      endcase
    end
        
    else begin
      data_out1 = 0;
      data_out2 = 0;	    
    end
  end
  
endmodule