`timescale 1ns/1ps

module register_banks_tb;
  logic clk, rst, w_en, r_en;
  logic [3:0] w_addr, r_addr;
  logic [15:0] data_in1, data_in2, data_out1, data_out2;
  
  register_banks DUT (.clk(clk), 
                      .rst(rst), 
                      .w_en(w_en), 
                      .r_en(r_en), 
                      .w_addr(w_addr), 
                      .r_addr(r_addr), 
                      .data_in1(data_in1),
                      .data_in2(data_in2),
                      .data_out1(data_out1),
                      .data_out2(data_out2)
                     );
  
  always #5 clk = ~clk;
  
  initial begin
    clk = 0; 
    rst = 1;
    w_en = 0; 
    r_en = 0;
    w_addr = 0; 
    r_addr = 0;
    data_in1 = 0; 
    data_in2 = 0;

    #12; 
    rst = 0; 

    #10;
    w_en = 1;
    r_en = 0;
    w_addr = 'd0; 
    data_in1 = 'd220; 
    data_in2 = 'd110; 

    #10;
    w_addr = 'd3; 
    data_in1 = 'd100; 
    data_in2 = 'd10; 

    #10;
    w_addr = 'd4; 
    data_in1 = 'd5; 
    data_in2 = 'd5; 

    #10;
    w_addr = 'd5; 
    data_in1 = 'd10; 
    data_in2 = 'd8; 

    #10;
    w_en = 0; 
    r_en = 1; 
    r_addr = 'd0; 

    #10;
    r_addr = 'd3; 

    #10;
    r_addr = 'd4; 

    #10;
    r_addr = 'd5; 

    #10;
    r_en = 0;

    #20;
    $finish;
  end
  
  
  
  
  initial begin
    $display("Tempo | P1_Pos | P2_Pos | Bola_X | Bola_Y | Ball_vel_X | Ball_vel_Y | Score_P1 | Score_P2 | Out1 | Out2");

    $monitor("%0t | %6d | %6d | %6d | %6d | %6d | %6d | %8d | %8d | %8d | %8d",
             $time,
             DUT.p1_pos,
             DUT.p2_pos,
             DUT.ball_pos[0],
             DUT.ball_pos[1],
             DUT.ball_vel[0],
             DUT.ball_vel[1],
             DUT.score[0],
             DUT.score[1],
             data_out1,
             data_out2
            );
  end
endmodule