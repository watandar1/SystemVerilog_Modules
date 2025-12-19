/*
This module should output high when Hsync is in active area and Vsync high when it is in active area
*/

// For classic VGA 60 Hz 640 x 590 the timing is as follows 25MHz clock
/*  Horizontal timing
    Visible area = 640
    Front porch = 16
    Sync Pulse = 96
    Back porch = 48
    =================> totals = 800
*/

/*  Vertical timing
    Visible area = 480
    Front porch = 10
    Sync Pulse = 2
    Back porch = 33
    =================> totals = 525
*/
//for simulating with verilator add timescale `timescale 1ns/1ps
`timescale 1ns/1ps

module my_VGA_active_pulse_Gen #(
    parameter HSYNC_WIDTH = 800,
    parameter VSYNC_WIDTH = 525,
    parameter HSYNC_ACTIVE = 640,
    parameter VSYNC_ACTIVE = 480
) (
    //What inputs do we want? :/
    input logic i_clk,
    input logic i_rst_n,

    //Outputs
    output wire o_hsync_active,                                           // 1 bit signal either high or low depending if we are in visible are or not!
    output wire o_vsync_active,                                            // 1 bit signal either high or low depending if we are in visible are or not!

    //the counters are set as output 
    //so they can be used in other modules aswell
    output wire [$clog2(HSYNC_WIDTH)-1:0] o_hsync_frame_pos,           //dynamic counter will be able to count to HSYNC_WIDTH         
    output wire [$clog2(VSYNC_WIDTH)-1:0] o_vsync_frame_pos           //dynamic counter will be able to count to VSYNC_WIDTH
);

     my_VGA_frame_Gen #(
        .HSYNC_TOT(HSYNC_WIDTH),
        .VSYNC_TOT(VSYNC_WIDTH)
     ) frame_gen_for_sync (
        .i_CLK(i_clk),
        .i_rst_n(i_rst_n), // asynchronous reset for the counters
        .o_hsync_frame_pos(o_hsync_frame_pos),
        .o_vsync_frame_pos(o_vsync_frame_pos),
        .o_w_frame_reset()
    );

//visible area is 640 for Hsync and 480 for vsync
//we use the ternary operator ? -> (condition) ? (true expression) : (false expression)
assign o_hsync_active = (o_hsync_frame_pos < HSYNC_ACTIVE) ? 1'b1 : 1'b0;
assign o_vsync_active = (o_vsync_frame_pos < VSYNC_ACTIVE) ? 1'b1 : 1'b0;
    
endmodule
