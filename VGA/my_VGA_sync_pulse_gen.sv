/*
this module should generate Hsync and Vsync pulse for VGA 
it should have the blanking periods and generate Hsync and Vsync pulses
etc... etc...
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
`timescale 1ns/1ps

module my_VGA_sync_pulse_gen #(
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
    input wire i_active_hsync,
    input wire i_active_vsync,
    //Outputs
    output wire o_hsync_pulse,         // generates real sync pulse with front and back porch
    output wire o_vsync_pulse          // generates real sync pulse with front and back porch
 
);

    //choose wire instead of logic since we dont want to store it here, we are just passing it along
    wire [$clog2(HSYNC_WIDTH)-1:0] hsync_counter;              //dynamic counter will be able to count to HSYNC_WIDTH         
    wire [$clog2(VSYNC_WIDTH)-1:0] vsync_counter;              //dynamic counter will be able to count to VSYNC_WIDTH

     my_VGA_frame_Gen #(
        .HSYNC_TOT(HSYNC_WIDTH),
        .VSYNC_TOT(VSYNC_WIDTH)
     ) frame_gen_for_sync (
        .i_CLK(i_clk),
        .i_rst_n(i_rst_n), // asynchronous reset for the counters
        .o_hsync_frame_pos(hsync_counter),
        .o_vsync_frame_pos(vsync_counter),
        .o_w_frame_reset()
    );

//Generate real sync pulses with front and back porch
// I used an always_ff block first but it got a race condition since the counters are updated on posedge clk
// and the always_ff block also triggers on posedge clk
// so the counters would update after the always_ff block and cause wrong pulse generation
// so I changed it to continuous assignment which works fine here
assign o_hsync_pulse = ((hsync_counter >= (HSYNC_ACTIVE + HSYNC_FRONT)) && 
                        (hsync_counter <  (HSYNC_ACTIVE + HSYNC_FRONT + HSYNC_PULSE))) ? 1'b0 : 1'b1;

assign o_vsync_pulse = ((vsync_counter >= (VSYNC_ACTIVE + VSYNC_FRONT)) && 
                        (vsync_counter <  (VSYNC_ACTIVE + VSYNC_FRONT + VSYNC_PULSE))) ? 1'b0 : 1'b1;
    
endmodule

