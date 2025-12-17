/*
testbench for my_VGA_driver.sv
works fine with small timing parameters for faster simulation
has not been tested with real VGA timing parameters yet
2025-12-16
*/

`timescale 1ns/1ps
module tb_my_VGA_driver;
    logic tb_clk;
    logic tb_rst_n;

    logic tb_vsync_pulse;      
    logic tb_hsync_pulse;
    
    logic [$clog2(HSYNC_WIDTH)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(VSYNC_WIDTH)-1:0] tb_vsync_pulse_counter;
    
    localparam VIDEO_WIDTH = 4;
    // vga 640X480 @60 hz Timing spec
    /*
    localparam HSYNC_WIDTH = 800;
    localparam VSYNC_WIDTH = 525;
    localparam HSYNC_ACTIVE = 640;
    localparam VSYNC_ACTIVE = 480;
    localparam HSYNC_FRONT = 16;
    localparam VSYNC_FRONT = 10;
    localparam HSYNC_BACK = 48;
    localparam VSYNC_BACK = 33;
    localparam HSYNC_PULSE = 96;
    localparam VSYNC_PULSE = 2;
    */
    // VGA small timing for faster simulation
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


    //Instantiate the DUT
    my_VGA_driver #(
        .VIDEO_WIDTH(VIDEO_WIDTH),
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE),
        .HSYNC_FRONT(HSYNC_FRONT),
        .VSYNC_FRONT(VSYNC_FRONT),
        .HSYNC_BACK(HSYNC_BACK),
        .VSYNC_BACK(VSYNC_BACK),
        .HSYNC_PULSE(HSYNC_PULSE),
        .VSYNC_PULSE(VSYNC_PULSE)
    ) DUT (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .o_hsync_pulse(tb_hsync_pulse),
        .o_vsync_pulse(tb_vsync_pulse),
        .o_hsync_frame_pos(tb_hsync_pulse_counter),
        .o_vsync_frame_pos(tb_vsync_pulse_counter),
        .o_w_frame_reset()
    );

    
    always begin
        #20; // 25 MHz clock
        tb_clk <= ~tb_clk;
    end

    initial begin
        tb_clk = 0;
        #40;
        tb_rst_n = 1'b0;
        #40;
        tb_rst_n = 1'b1;

        // Run long enough to see multiple frames
        #(HSYNC_WIDTH*VSYNC_WIDTH*2*40); // 2 frames worth of clock cycles
        $finish;
    end


    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_My_VGA_Sync_Pulse_Gen);
    end

endmodule
