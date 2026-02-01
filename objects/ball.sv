/*
640x480@60Hz
2026-01-08: this module should display a black ball fixed in the center of the screen
it should not drive the VGA outputs directly, but instead output a signal o_ball_on
in future add feature for moveable ball (with velocity)
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
    //input logic [3:0] background,

    input logic i_clk,
    input logic i_rst_n,
    input logic i_frame_start,

    input logic [$clog2(HSYNC_WIDTH)-1:0] o_hsync_frame_pos,           //dynamic counter will be able to count to HSYNC_WIDTH         
    input logic [$clog2(VSYNC_WIDTH)-1:0] o_vsync_frame_pos,           //dynamic counter will be able to count to VSYNC_WIDTH

    // OUTPUTS:
    output logic o_ball_on,
    output logic [3:0] o_ball_color
    
);

    localparam ball_center_x = HSYNC_ACTIVE / 2;
    localparam ball_center_y = VSYNC_ACTIVE / 2;
    
    logic signed [11:0] dy;
    logic signed [11:0] dx;

    // Code for moving the ball
    // We need to change the center of the ball so it can move
    
    always_comb begin
        // if frame start move the ball
        // if not keep ball at current center point
        if (i_frame_start) begin
            
        end else begin
            
        end
    end

    // CODE for fixed ball 
    /*

    assign dx = $signed(o_vsync_frame_pos) - $signed(ball_center_y);
    assign dy = $signed(o_hsync_frame_pos) - $signed(ball_center_x);

    */

    // Pythagorean theorem to determine if pixel is within the ball radius
    // Using ternary operator to set o_ball_on
    assign o_ball_on = (((dx * dx) + (dy * dy)) < (BALL_RADIUS * BALL_RADIUS)) ? 1'b1 : 1'b0;
    assign o_ball_color = 4'h0; // black ball


endmodule
