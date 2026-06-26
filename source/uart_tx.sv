module uart_transmitter (
    input logic clk,
    input logic rst,
    input logic tx_en,
    input logic tx_data_valid,
    input logic [7:0] data_in,
    output logic tx,
    output logic busy

);

    enum logic [2:0] {IDLE, START, DATA, PARITY, STOP, WAIT} current_state, next_state;

    logic [7:0] data_buffer;
    logic [7:0] shift_buffer;
    logic [2:0] data_counter;
    logic tx_data_ready_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_data_ready_reg <= 1'b0;
        end else begin
            if (tx_data_valid) begin
                tx_data_ready_reg <= 1'b1;
            end else if (current_state == IDLE && tx_en && tx_data_ready_reg) begin
                tx_data_ready_reg <= 1'b0;
            end
        end
    end

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
                if (tx_data_ready_reg && tx_en) begin
                    next_state = START;
                end
            end

            START: begin
                if (tx_en) begin
                    next_state = DATA;
                end
            end

            DATA: begin
                if (tx_en & data_counter == 3'd7) begin
                    next_state = PARITY;
                end
            end

            PARITY: begin
                if (tx_en) begin
                    next_state = STOP;
                end
            end

            STOP: begin
                if (tx_en) begin
                    next_state = WAIT;
                end
            end

            WAIT: begin
                if (tx_en) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            data_counter <= 3'd0;
            shift_buffer <= 8'd0;
            data_buffer <= 8'd0;
        end

        else begin
            if (current_state == IDLE && tx_data_ready_reg && tx_en) begin
                data_buffer <= data_in;
                shift_buffer <= data_in;
                data_counter <= 3'd0;
            end

            if (tx_en) begin
                if (current_state == DATA) begin
                    data_counter <= data_counter + 3'd1;
                    shift_buffer <= shift_buffer >> 1;
                end
            end
        end
    end

    always_comb begin
        case (current_state)
            IDLE: begin
                tx = 1'b1;
            end

            START: begin
                tx = 1'b0;
            end

            DATA: begin
                tx = shift_buffer[0];
            end

            PARITY: begin
                tx = ^data_buffer;
            end

            STOP: begin
                tx = 1'b1;
            end

            WAIT: begin
                tx = 1'b1;
            end

            default: begin
                tx = 1'b1;
            end
        endcase
    end 

    assign busy = (current_state != IDLE);
endmodule