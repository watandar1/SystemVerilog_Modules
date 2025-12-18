/*
This module generates a pixel grid for VGA display based on parameters defining the grid size and active display area.
It uses counters from my_VGA_frame_Gen.sv to determine the grid lines' positions within the active display area.

Does it work: NOT TESTED. Date: 2025-12-18
*/

`timescale 1ns/1ps // timescale for simulation

module pixel_grid_gen #(
    parameter PIXEL_GRID_H = 16,
    parameter PIXEL_GRID_V = 16,
    parameter HSYNC_ACTIVE = 640,
    parameter VSYNC_ACTIVE = 480,
    parameter GRID_COLS = HSYNC_ACTIVE / PIXEL_GRID_H,  // 40 columns
    parameter GRID_ROWS = VSYNC_ACTIVE / PIXEL_GRID_V   // 30 rows
) (
    //Inputs:
    input wire [$clog2(HSYNC_ACTIVE)-1:0] o_hsync_pos,           //dynamic counter will be able to count to HSYNC_WIDTH         
    input wire [$clog2(VSYNC_ACTIVE)-1:0] o_vsync_pos,           //dynamic counter will be able to count to VSYNC_WIDTH

    //outputs:
    output logic [$clog2(GRID_COLS)-1:0] o_grid_col, // indicates if in active hsync area
    output logic [$clog2(GRID_ROWS)-1:0] o_grid_row,  // indicates if in active vsync area
);

// Generates grid position from the frame gen counters
always_comb begin
    o_grid_col = o_hsync_pos / PIXEL_GRID_H;
    o_grid_row = o_vsync_pos / PIXEL_GRID_V;
end

endmodule
