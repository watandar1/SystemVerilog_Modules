/*
This module generates a pixel grid for VGA display based on parameters defining the grid size and active display area.
It uses counters from my_VGA_frame_Gen.sv to determine the grid lines' positions within the active display area.

Does it work: YES, tested with tb_pixel_grid_gen.sv. Date: 2025-12-19
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
    input wire [$clog2(HSYNC_ACTIVE)-1:0] i_hsync_pos,           //dynamic counter will be able to count to HSYNC_WIDTH         
    input wire [$clog2(VSYNC_ACTIVE)-1:0] i_vsync_pos,           //dynamic counter will be able to count to VSYNC_WIDTH

    //outputs:
    output logic [$clog2(GRID_COLS)-1:0] o_grid_col, // indicates if in active hsync area
    output logic [$clog2(GRID_ROWS)-1:0] o_grid_row  // indicates if in active vsync area
);

localparam pixel_h = $clog2(PIXEL_GRID_H);
localparam pixel_v = $clog2(PIXEL_GRID_V);
// Generates grid position from the frame gen counters
// have $clog2 to avoid verilator warnings about WIDTH Truncation
// its hard here, since I want to simualate this with verilator but I get truncation error
// it should not be a problem in real hardware since the parameters are set correctly
// but for simulation we need it so we can be certain that it works
// The current solution is to use $clog2(GRID_COLS) and $clog2(GRID_ROWS) for output widths
// and use bitwise right shift to divide by PIXEL_GRID_H and PIXEL_GRID_V respectively
// but this only works if PIXEL_GRID_H and PIXEL_GRID_V are powers of 2 :( 
always_comb begin
    o_grid_col = $clog2(GRID_COLS)'(i_hsync_pos >>> pixel_h);
    o_grid_row = $clog2(GRID_ROWS)'(i_vsync_pos >>> pixel_v);
end

endmodule
