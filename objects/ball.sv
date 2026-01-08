/*
640x480@60Hz
2026-01-08: this module should display a black ball fixed in the center of the screen
*/

module ball #(
    // PARAMETERS:
    parameter HSYNC_WIDTH = 800,
    parameter VSYNC_WIDTH = 525,
    parameter HSYNC_ACTIVE = 640,
    parameter VSYNC_ACTIVE = 480,
    parameter BALL_RADIUS = 8

) (
    // INPUTS:
    input logic [3:0] background,

    input logic i_clk,
    input logic i_rst_n,

    input logic [$clog2(HSYNC_WIDTH)-1:0] o_hsync_frame_pos,           //dynamic counter will be able to count to HSYNC_WIDTH         
    input logic [$clog2(VSYNC_WIDTH)-1:0] o_vsync_frame_pos,           //dynamic counter will be able to count to VSYNC_WIDTH

    // OUTPUTS:

    output logic [3:0] ball_color

);

    logic [$clog2(HSYNC_WIDTH)-1:0] ball_x,                    
    logic [$clog2(VSYNC_WIDTH)-1:0] ball_y,         
    
    // Code for the ball to be in the middle of the screen: 


endmodule
