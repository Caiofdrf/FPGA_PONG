module processing_unit (
	  input logic clk,
  	input logic rst,
    input logic new_moves,
    input logic uart_tx_busy,
    input logic [15:0] ram_data [0:2][0:2],
    output logic w_en,
    output logic uart_tx_valid,
    output logic [15:0] ram_write [0:2][0:2],
    output logic [7:0] uart_out
);

`define P1_MOV   temp_ram[0][0]     
`define P2_MOV   temp_ram[0][1]     
`define BALL_X   temp_ram[0][2]
`define P1_POS   temp_ram[1][0]     
`define P2_POS   temp_ram[1][1]     
`define BALL_Y   temp_ram[1][2]
`define P1_SCORE temp_ram[2][0]     
`define P2_SCORE temp_ram[2][1]     
`define STR_RST  temp_ram[2][2] 

`define CIMA   16'd2
`define PARADO 16'd1
`define BAIXO  16'd0

localparam logic signed [15:0] VAR_VEL           = 16'd2;
localparam logic signed [15:0] PLAYER_VEL        = 16'd5;
localparam logic signed [15:0] PLAYER_MID_LENGHT = 16'd24;
localparam logic signed [15:0] SCREEN_H          = 16'd206;
localparam logic signed [15:0] SCREEN_TOP        = 16'd25;
localparam logic signed [15:0] SCREEN_BOTTOM     = 16'd231; 
localparam logic signed [15:0] SCREEN_W          = 16'd512; 

logic [2:0] byte_index; 
logic [1:0] tx_sub_state;
logic data_sent;
logic signed [15:0] ball_vel_x;
logic signed [15:0] ball_vel_y;

logic game_over;
logic p_wins;


/*
Matriz da memória RAM:

P1_MOV     |      P2_MOV      |      BALL_X
P1_POS     |      P2_POS      |      BALL_Y
P1_SCORE   |      P2_SCORE    |     START/RST

*/
logic [15:0] temp_ram [0:2][0:2];

enum logic [2:0] {IDLE, GET_DATA, POS_CALC, COLS_VER, SAVE_DATA, SEND_DATA} current_state, next_state;

assign game_over = (`P1_SCORE == 16'd5 || `P2_SCORE == 16'd5);
assign p_wins   = (`P1_SCORE == 16'd5);

always_ff @(posedge clk) begin
  if (rst) begin
    current_state <= IDLE;
  end

  else begin
    current_state <= next_state;
  end
end


always_comb begin
  next_state = current_state;

  case (current_state)
    IDLE: begin
      if (new_moves) begin
        next_state = GET_DATA;
      end
    end

    GET_DATA: begin
      next_state = POS_CALC;
    end

    POS_CALC: begin
      next_state = COLS_VER;
    end

    COLS_VER: begin
        next_state = SAVE_DATA;
    end

    SAVE_DATA: begin
        next_state = SEND_DATA;
    end

    SEND_DATA: begin
      if (data_sent) begin
        next_state = IDLE;
      end
    end
  endcase
end

always_ff @(posedge clk) begin
  if (rst) begin
    w_en <= 1'd0;
    ball_vel_x <= 16'd5;
    ball_vel_y <= 16'd0;
    byte_index <= 3'd0;
    uart_tx_valid <= 1'b0;
    data_sent <= 1'b0;
    tx_sub_state <= 2'd0;
  end
  else begin
    w_en <= 1'd0;
    uart_tx_valid <= 1'b0;

    case (current_state)
      IDLE: begin
        byte_index <= 3'd0;
        data_sent  <= 1'b0;
        tx_sub_state <= 2'd0;
      end
      
      GET_DATA: begin
        temp_ram <= ram_data;
      end

      POS_CALC: begin
        if (`P1_MOV == `BAIXO) begin                        // Se P1 move para BAIXO
          if (`P1_POS + PLAYER_VEL + PLAYER_MID_LENGHT <= SCREEN_BOTTOM) begin
            `P1_POS <= `P1_POS + PLAYER_VEL;
          end
          else begin
            `P1_POS <= SCREEN_BOTTOM - PLAYER_MID_LENGHT;
          end
        end
        else if (`P1_MOV == `CIMA) begin                   // Se P1 move para CIMA
          if (`P1_POS - PLAYER_VEL - PLAYER_MID_LENGHT >= SCREEN_TOP) begin
            `P1_POS <= `P1_POS - PLAYER_VEL;      
          end
          else begin
            `P1_POS <= SCREEN_TOP + PLAYER_MID_LENGHT;
          end
        end

        if (`P2_MOV == `BAIXO) begin                        // Se P2 move para BAIXO 
          if (`P2_POS + PLAYER_VEL + PLAYER_MID_LENGHT <= SCREEN_BOTTOM) begin
            `P2_POS <= `P2_POS + PLAYER_VEL;
          end
          else begin
            `P2_POS <= SCREEN_BOTTOM - PLAYER_MID_LENGHT;
          end
        end
        else if (`P2_MOV == `CIMA) begin                   // Se P2 move para CIMA
          if (`P2_POS - PLAYER_VEL - PLAYER_MID_LENGHT >= SCREEN_TOP) begin
            `P2_POS <= `P2_POS - PLAYER_VEL;      
          end
          else begin
            `P2_POS <= SCREEN_TOP + PLAYER_MID_LENGHT;
          end
        end

        `BALL_X <= `BALL_X + ball_vel_x;
        `BALL_Y <= `BALL_Y + ball_vel_y;
      end

      COLS_VER: begin
        if (`BALL_X <= 16'd0 && 
            ~(`BALL_Y <= `P1_POS + PLAYER_MID_LENGHT &&
              `BALL_Y >= `P1_POS - PLAYER_MID_LENGHT)) begin          // Gol do player 2
          `P2_SCORE <= `P2_SCORE + 16'd1; 

          // Retornar bola para centro da quadra
          `BALL_X <= 16'd256;  // `BALL_X
          `BALL_Y <= 16'd128;  // `BALL_Y
          ball_vel_x <= 16'd5; 
          ball_vel_y <= 16'd0;
        end
        else if (`BALL_X >= 16'd512 && 
            ~(`BALL_Y <= `P2_POS + PLAYER_MID_LENGHT &&
              `BALL_Y >= `P2_POS - PLAYER_MID_LENGHT)) begin    // Gol do player 1
          `P1_SCORE <= `P1_SCORE + 16'd1; 
          
          // Retornar bola para centro da quadra
          `BALL_X <= 16'd256;  // `BALL_X
          `BALL_Y <= 16'd128;  // `BALL_Y
          ball_vel_x <= -16'd5; 
          ball_vel_y <= 16'd0;
        end

        else begin                            // Colisão com teto, chão ou jogador
          if (`BALL_Y <= SCREEN_TOP) begin
            `BALL_Y <= SCREEN_TOP + 16'd2;
            ball_vel_y <= -ball_vel_y;
          end
          else if (`BALL_Y >= SCREEN_BOTTOM) begin
            `BALL_Y <= SCREEN_BOTTOM - 16'd2;
            ball_vel_y <= -ball_vel_y;
          end
          else begin
            if ((`BALL_X < 16'd13) && 
                (`BALL_Y <= `P1_POS + PLAYER_MID_LENGHT && `BALL_Y >= `P1_POS - PLAYER_MID_LENGHT)) begin // Se bola está próxima do player 1

              if (`P1_MOV == `BAIXO && ball_vel_y <= 0) begin
                ball_vel_y <= -ball_vel_y - VAR_VEL;
                ball_vel_x <= -ball_vel_x - VAR_VEL;
              end
              else if (`P1_MOV == `CIMA && ball_vel_y >= 0) begin
                ball_vel_y <= -ball_vel_y + VAR_VEL;
                ball_vel_x <= -ball_vel_x - VAR_VEL;
              end
              else if (`P1_MOV == `CIMA && ball_vel_y <= 0) begin
                ball_vel_y <= ball_vel_y - VAR_VEL;
                ball_vel_x <= -ball_vel_x + VAR_VEL;
              end
              else if (`P1_MOV == `BAIXO && ball_vel_y >= 0) begin
                ball_vel_y <= ball_vel_y + VAR_VEL;
                ball_vel_x <= -ball_vel_x + VAR_VEL;
              end
              else begin
                ball_vel_x <= -ball_vel_x;
              end
            end

            else if ((`BALL_X > 16'd499) && 
                (`BALL_Y <= `P2_POS + PLAYER_MID_LENGHT && `BALL_Y >= `P2_POS - PLAYER_MID_LENGHT)) begin // Se bola está próxima do player 2

              if (`P2_MOV == `BAIXO && ball_vel_y <= 0) begin
                ball_vel_y <= -ball_vel_y - VAR_VEL;
                ball_vel_x <= -ball_vel_x + VAR_VEL;
              end
              else if (`P2_MOV == `CIMA && ball_vel_y >= 0) begin
                ball_vel_y <= -ball_vel_y + VAR_VEL;
                ball_vel_x <= -ball_vel_x + VAR_VEL;
              end
              else if (`P2_MOV == `CIMA && ball_vel_y <= 0) begin
                ball_vel_y <= ball_vel_y - VAR_VEL;
                ball_vel_x <= -ball_vel_x - VAR_VEL;
              end
              else if (`P2_MOV == `BAIXO && ball_vel_y >= 0) begin
                ball_vel_y <= ball_vel_y + VAR_VEL;
                ball_vel_x <= -ball_vel_x - VAR_VEL;
              end
              else begin
                ball_vel_x <= -ball_vel_x;
              end
            end
          end
        end 
      end

      SAVE_DATA: begin
        w_en <= 1'd1;
        ram_write <= temp_ram;
      end

      SEND_DATA: begin
        case (tx_sub_state)
          2'd0: begin // Passo 0: Dispara o sinal de válido
            uart_tx_valid <= 1'b1;
            tx_sub_state  <= 2'd1;
            
            // Define o dado de saída baseado no índice
            case(byte_index)
              3'd0: uart_out <= `P1_POS[7:0];
              3'd1: uart_out <= `P2_POS[7:0];
              3'd2: uart_out <= `BALL_X[15:8];
              3'd3: uart_out <= `BALL_X[7:0];
              3'd4: uart_out <= `BALL_Y[7:0];
              3'd5: uart_out <= {game_over, p_wins, `P1_SCORE[2:0], `P2_SCORE[2:0]};
              default: uart_out <= 8'd0;
            endcase
          end

          2'd1: begin
            if (uart_tx_busy) begin
              tx_sub_state <= 2'd2;
            end
          end

          2'd2: begin
            if (!uart_tx_busy) begin
              if (byte_index == 3'd5) begin
                data_sent <= 1'b1; // Enviou todos os 6 bytes!
              end
              else begin
                byte_index   <= byte_index + 3'd1;
                tx_sub_state <= 2'd0;
              end
            end
          end
          
          default: tx_sub_state <= 2'd0;
        endcase
      end
    endcase
  end
end
endmodule