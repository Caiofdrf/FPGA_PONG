module uart_receiver (
    input logic clk, 
    input logic rst,
    input logic rx,
    input logic rx_en,
    output logic ready,
    output logic uart_w_en,
    output logic [7:0] data_out
);

    enum logic [2:0] {IDLE, START, DATA_OUT, STOP} current_state, next_state;

    logic [3:0] sample_counter;
    logic [3:0] data_counter;
    logic [7:0] shift_register;

    assign uart_w_en = ready;
    
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
                if (rx == 1'b0) begin
                    next_state = START;
                end
            end

            START: begin
                if (rx_en && sample_counter == 4'd7) begin
                    if (rx == 1'b0) begin
                        next_state = DATA_OUT;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
            end

            DATA_OUT: begin
                if (rx_en && sample_counter == 4'd15 && data_counter == 3'd7) begin
                    next_state = STOP;
                end
            end

            STOP: begin
                if (rx_en && sample_counter == 15) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_counter <= 4'd0;
            data_counter <= 3'd0;
            shift_register <= 8'd0;
        end

        else if (rx_en) begin
            case (current_state)
                IDLE: begin
                    sample_counter <= 4'd0;
                    data_counter <= 3'd0;
                end

                START: begin
                    if (sample_counter == 4'd7) begin
                        sample_counter <= 4'd0;
                    end
                    else begin
                        sample_counter <= sample_counter + 4'd1;
                    end
                end

                DATA_OUT: begin
                    sample_counter <= sample_counter + 4'd1;
                    if (sample_counter == 4'd15) begin
                        shift_register <= {rx, shift_register[7:1]};
                        data_counter <= data_counter + 3'd1;
                    end
                end

                STOP: begin
                    sample_counter <= sample_counter + 4'd1;
                end
            endcase    
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            ready <= 1'b0;
            data_out <= 8'd0;
        end

        else begin
            if (ready) begin
                ready <= 1'd0; 
            end

            if (current_state == STOP && rx_en && sample_counter == 4'd15) begin
                data_out <= shift_register;
                ready <= 1'b1;
            end
        end
    end
endmodule