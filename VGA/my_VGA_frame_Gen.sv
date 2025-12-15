/*
this module should generate "frames" using counters
Output is Hsync and Vsync pixel position on a single frame. 
This is the core of VGA, with this we can determine the pixel position for every frame we generate
*/
`timescale 1ns/1ps
module my_VGA_frame_Gen #(
    parameter HSYNC_TOT = 800,
    parameter VSYNC_TOT = 525
) (
    // INPUTS:
    input logic i_CLK,
    input logic i_rst_n,

    // OUTPUTS:
    output logic [$clog2(HSYNC_TOT)-1:0] o_hsync_frame_pos,             //hsync pixel position
    output logic [$clog2(VSYNC_TOT)-1:0] o_vsync_frame_pos,             //vsync pixel position
    
    output wire o_w_frame_reset // shows when new frame starts
);
//wire frame_reset: Synchronous always sequential block
always_ff @(posedge i_CLK or negedge i_rst_n) begin
    // asynchrounous reset so that hsync and vsync can start with known values
    if (!i_rst_n) begin
        o_hsync_frame_pos <= 0;
        o_vsync_frame_pos <= 0;
    end else begin
        if (o_hsync_frame_pos == HSYNC_TOT-1) begin
            if (o_vsync_frame_pos == VSYNC_TOT-1) begin
                o_vsync_frame_pos <= 0;
            end else begin
            o_vsync_frame_pos <= o_vsync_frame_pos + 1;
            end
        o_hsync_frame_pos <= 0;
    end else begin
        o_hsync_frame_pos <= o_hsync_frame_pos + 1;
    end
    end
 
end

//assign frame start so other modules can use this to know when a new frame starts
assign o_w_frame_reset = ((o_vsync_frame_pos == VSYNC_TOT-1) && (o_hsync_frame_pos == HSYNC_TOT-1)) ? 1'b1 : 1'b0;
    
endmodule
