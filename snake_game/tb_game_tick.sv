/*
testing game tick 
*/
`timescale 1ns/1ps

module tb_game_tick;

    logic tb_clk;
    logic tb_rst_n;

    logic tb_vsync;      
    logic tb_hsync;

    logic tb_frame_reset;
    logic tb_game_tick;

    
    logic [$clog2(HSYNC_WIDTH)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(VSYNC_WIDTH)-1:0] tb_vsync_pulse_counter;  
    //changed the parameters so the signals can be observed better

    // Hsync pulse 8 bits and Vsync pulse 2 bits
    localparam HSYNC_WIDTH = 56;
    localparam VSYNC_WIDTH = 35;
    localparam HSYNC_ACTIVE = 40;
    localparam VSYNC_ACTIVE = 30;
    localparam HSYNC_FRONT = 4;
    localparam VSYNC_FRONT = 1;
    localparam HSYNC_BACK = 4;
    localparam VSYNC_BACK = 2;
    localparam HSYNC_PULSE = 8;
    localparam VSYNC_PULSE = 2;
    

    my_VGA_active_pulse_Gen #(
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE)

    ) vga_active_pulse_tb (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .o_hsync_active(tb_hsync),
        .o_vsync_active(tb_vsync),
        .o_w_frame_reset(tb_frame_reset),
        .o_hsync_frame_pos(tb_hsync_pulse_counter),
        .o_vsync_frame_pos(tb_vsync_pulse_counter)
    );      
    
    game_tick #(
        .FRAMES_PER_TICK(5)
    ) game_tick_dut (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .frame_start(tb_frame_reset),
        .o_game_tick(tb_game_tick)
    );

    always begin
        #20; // 25 MHz clock
        tb_clk <= ~tb_clk;
    end


    initial begin
        tb_clk = 0;
        #40;
        tb_rst_n = 1'b1;
        #40;
        tb_rst_n = 0'b1;

        // Run long enough to see multiple frames
        #(HSYNC_WIDTH*VSYNC_WIDTH*14*40); // 14 frames worth of clock cycles
        $finish;
    end


    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_game_tick);
    end

endmodule
