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
    // no reset function! this module will be used inside another 

    //Outputs
    output logic o_hsync_active,                                           // 1 bit signal either high or low depending if we are in visible are or not!
    output logic o_vsync_active,                                            // 1 bit signal either high or low depending if we are in visible are or not!

    //the counters are set as output 
    //so they can be used in other modules aswell
    output logic [$clog2(HSYNC_WIDTH)-1:0] o_hsync_active_counter,           //dynamic counter will be able to count to HSYNC_WIDTH         
    output logic [$clog2(VSYNC_WIDTH)-1:0] o_vsync_active_counter           //dynamic counter will be able to count to VSYNC_WIDTH
);


always_ff @(posedge i_clk) begin
    if (o_hsync_active_counter == (HSYNC_WIDTH - 1)) begin
        o_hsync_active_counter <= 0;
        if (o_vsync_active_counter == (VSYNC_WIDTH - 1)) begin
            o_vsync_active_counter <= 0;
        end else begin
            o_vsync_active_counter <= o_vsync_active_counter + 1;
        end
        end else begin
            o_hsync_active_counter <= o_hsync_active_counter + 1;
        end
end

//visible area is 640 for Hsync and 480 for vsync
//we use the ternary operator ? -> (condition) ? (true expression) : (false expression)
assign o_hsync_active = (o_hsync_active_counter < HSYNC_ACTIVE) ? 1'b1 : 1'b0;
assign o_vsync_active = (o_vsync_active_counter < VSYNC_ACTIVE) ? 1'b1 : 1'b0;
    
endmodule
