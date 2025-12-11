/*
this module should generate "frames" using counters,
*/
`timescale 1ns/1ps
module my_VGA_frame_Gen #(
    parameter HSYNC_TOT = 800,
    parameter VSYNC_TOT = 525
) (
    //INPUTS:
    input logic i_CLK,

    // counter to understand where in the frame we are
    output logic [$clog2(HSYNC_TOT)-1:0] o_hsync_frame_pos,             //hsync frame counter
    output logic [$clog2(VSYNC_TOT)-1:0] o_vsync_frame_pos,             //vsync frame counter
    
    output wire o_w_frame_reset
);

//wire frame_reset;

always_ff @(posedge i_CLK) begin
 
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

assign o_w_frame_reset = ((o_vsync_frame_pos == VSYNC_TOT-1) && (o_hsync_frame_pos == HSYNC_TOT-1)) ? 1'b1 : 1'b0;
    
endmodule
