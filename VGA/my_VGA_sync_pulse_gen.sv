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
    parameter VSYNC_BACK = 33
) (
    //What inputs do we want? :/
    input logic i_clk,
    input logic i_active_hsync,
    input logic i_active_vsync,
    //Outputs
    output logic o_hsync_pulse,         // generates real sync pulse with front and back porch
    output logic o_vsync_pulse          // generates real sync pulse with front and back porch
 
);


    logic [$clog2(HSYNC_WIDTH)-1:0] hsync_counter;              //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(VSYNC_WIDTH)-1:0] vsync_counter;               //dynamic counter will be able to count to VSYNC_WIDTH

     my_VGA_frame_Gen #(
        .HSYNC_TOT(HSYNC_WIDTH),
        .VSYNC_TOT(VSYNC_WIDTH)
     ) frame_gen_for_sync (
        .i_CLK(i_clk),
        .o_hsync_frame_pos(hsync_counter),
        .o_vsync_frame_pos(vsync_counter),
        .o_w_frame_reset()
    );

    // Generate real sync pulses with front and back porch, 
    // the -2 is for one clock cycle delay, it should be -1 theoretical but here it is delay somehwere I cant find it
    always_ff @(posedge i_clk) begin
        //create Hsync pulse
        if ((hsync_counter <= (HSYNC_ACTIVE + HSYNC_FRONT -2 )) || 
        (hsync_counter >= HSYNC_WIDTH - HSYNC_BACK-1)) begin
            o_hsync_pulse <= 1'b1;
        end 
        else begin
            o_hsync_pulse <= i_active_hsync;
        end
        //create Vsync pulse
        if ((vsync_counter <= (VSYNC_ACTIVE + VSYNC_FRONT - 1)) || 
        (vsync_counter >= (VSYNC_WIDTH - VSYNC_BACK ))) begin
            o_vsync_pulse <= 1'b1;
        end 
        else begin
            o_vsync_pulse <= i_active_vsync;
        end
    end

    
endmodule

