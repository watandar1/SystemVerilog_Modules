/*
test bench to test if the vga frame generator works correctly, i.e. the hsync and vsync counters
*/


`timescale 1ns/1ps

module tb_my_VGA_frame_Gen;

    logic clk;  
    logic tb_rst_n;           
    logic hsync;
    logic vsync;
    logic o_hsync; // not used here with frame gen
    logic o_vsync; // not used here with frame gen
    logic o_frame_reset;
    
    logic [$clog2(800)-1:0] hsync_frame_pos;             //hsync frame counter
    logic [$clog2(525)-1:0] vsync_frame_pos;             //vsync frame counter

    my_VGA_frame_Gen #(
        .HSYNC_TOT(800),
        .VSYNC_TOT(525)
    ) frame_gen (
        .i_CLK(clk),
        .i_rst_n(tb_rst_n),
        .o_hsync_frame_pos(hsync_frame_pos),
        .o_vsync_frame_pos(vsync_frame_pos),
        .o_w_frame_reset(o_frame_reset)
    );

    always begin
        #20; //25MHz clock
        clk <= ~clk;
    end

    initial begin
        clk = 0;
        #40;
        tb_rst_n = 1'b1;
        #40;
        tb_rst_n = 0'b1;


        #50000000;
        $finish;
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_my_clk_divider);
    end

endmodule
