/*
testbench for pixel_grid_gen.sv module
generate "active frame signals with frame_gen.sv"
*/
`timescale 1ns/1ps

    module tb_pixel_grid_gen;
        
    //Parameters
    localparam HSYNC_ACTIVE = 640;
    localparam VSYNC_ACTIVE = 480;
    
    localparam PIXEL_GRID_H = 16;
    localparam PIXEL_GRID_V = 16;

    
    localparam GRID_COLS = HSYNC_ACTIVE / PIXEL_GRID_H;  // 40 columns
    localparam GRID_ROWS = VSYNC_ACTIVE / PIXEL_GRID_V;  // 30 rows

    logic tb_clk;
    logic tb_rst_n;

    
    wire [$clog2(HSYNC_ACTIVE)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    wire [$clog2(VSYNC_ACTIVE)-1:0] tb_vsync_pulse_counter; 
    
    wire [$clog2(GRID_COLS)-1:0] tb_grid_col; // indicates if in active hsync area
    wire [$clog2(GRID_ROWS)-1:0] tb_grid_row;  // indicates if in active vsync area

    //generate active pulse signals, we actually dont need the "active pulse" signals for this testbench 
    // but we need the frame position counters 
        my_VGA_frame_Gen #(
        .HSYNC_TOT(HSYNC_ACTIVE),
        .VSYNC_TOT(VSYNC_ACTIVE)
    ) frame_gen (
        .i_CLK(tb_clk),
        .i_rst_n(tb_rst_n),
        .o_hsync_frame_pos(tb_hsync_pulse_counter),
        .o_vsync_frame_pos(tb_vsync_pulse_counter),
        .o_w_frame_reset()
    );

    // Instantiate the DUT
    pixel_grid_gen #(
        .PIXEL_GRID_H(PIXEL_GRID_H),
        .PIXEL_GRID_V(PIXEL_GRID_V),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),    
        .VSYNC_ACTIVE(VSYNC_ACTIVE)
    ) pixel_grid (
        .i_hsync_pos(tb_hsync_pulse_counter),
        .i_vsync_pos(tb_vsync_pulse_counter),
        .o_grid_col(tb_grid_col),
        .o_grid_row(tb_grid_row)
    );

    // Clock generation 25MHz clock
    always begin
        #20;
        tb_clk <= ~tb_clk;
    end


    initial begin
        tb_clk = 0;
        #40;
        tb_rst_n = 1'b1;
        #40;
        tb_rst_n = 0'b1;

        // Run long enough to see multiple frames
        #(HSYNC_ACTIVE*VSYNC_ACTIVE*2*40); // 2 frames worth of clock cycles
        $finish;
    end

    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_pixel_grid_gen);
    end

endmodule