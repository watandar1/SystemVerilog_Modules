/*
VGA driver 640X480 @60 hz
by Morteza Khedri

*/

`timescale 1ns/1ps
module my_VGA_driver #(
    parameter VIDEO_WIDTH = 4,
    parameter HSYNC_WIDTH = 800,
    parameter VSYNC_WIDTH = 525,
    parameter HSYNC_ACTIVE = 640,
    parameter VSYNC_ACTIVE = 480,
    parameter HSYNC_FRONT = 16,
    parameter VSYNC_FRONT = 10,
    parameter HSYNC_BACK = 48,
    parameter VSYNC_BACK = 33,
    parameter HSYNC_PULSE = 96,
    parameter VSYNC_PULSE = 2
) (
    //What inputs do we want? :/
    input logic i_clk,
    input logic i_rst_n,
    //Outputs
    output wire o_hsync_pulse,                                              // generates real sync pulse with front and back porch
    output wire o_vsync_pulse,                                              // generates real sync pulse with front and back porch
    output logic [$clog2(HSYNC_WIDTH)-1:0] o_hsync_frame_pos,               //hsync pixel position
    output logic [$clog2(VSYNC_WIDTH)-1:0] o_vsync_frame_pos,               //vsync pixel position
    output logic o_w_frame_reset // shows when new frame starts
    
);

always_ff @(posedge i_clk or negedge i_rst_n) begin
    // asynchrounous reset so that hsync and vsync can start with known values
    if (!i_rst_n) begin
        o_hsync_frame_pos <= 0;
        o_vsync_frame_pos <= 0;
    end else begin
        //Hsync and Vsync frame position counters
        if (o_hsync_frame_pos == HSYNC_WIDTH-1) begin
            if (o_vsync_frame_pos == VSYNC_WIDTH-1) begin
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

//Generate real sync pulses with front and back porch
assign o_hsync_pulse = ((o_hsync_frame_pos >= (HSYNC_ACTIVE + HSYNC_FRONT)) && 
                        (o_hsync_frame_pos <  (HSYNC_ACTIVE + HSYNC_FRONT + HSYNC_PULSE))) ? 1'b0 : 1'b1;

assign o_vsync_pulse = ((o_vsync_frame_pos >= (VSYNC_ACTIVE + VSYNC_FRONT)) && 
                        (o_vsync_frame_pos <  (VSYNC_ACTIVE + VSYNC_FRONT + VSYNC_PULSE))) ? 1'b0 : 1'b1;

//generate frame reset signal
assign o_w_frame_reset = ((o_vsync_frame_pos == VSYNC_WIDTH-1) && (o_hsync_frame_pos == HSYNC_WIDTH-1)) ? 1'b1 : 1'b0;

    
endmodule
