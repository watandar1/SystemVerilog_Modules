/*
VGA sync pulse generator test bench
*/
`timescale 1ns/1ps

module tb_my_VGA_active_pulse_Gen;

    logic tb_clk;

    logic tb_vsync;      
    logic tb_hsync;

    
    logic [$clog2(800)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(525)-1:0] tb_vsync_pulse_counter;  
        
    localparam HSYNC_WIDTH = 800;
    localparam VSYNC_WIDTH = 525;
    localparam HSYNC_ACTIVE = 640;
    localparam VSYNC_ACTIVE = 480;  

    my_VGA_active_pulse_Gen #(
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE)

    ) vga_active_pulse_tb (
        .i_clk(tb_clk),
        .o_hsync_active(tb_hsync),
        .o_vsync_active(tb_vsync),
        .o_hsync_active_counter(tb_hsync_pulse_counter),
        .o_vsync_active_counter(tb_vsync_pulse_counter)
    );                                      

    always begin
        #20; // 25 MHz clock
        tb_clk <= ~tb_clk;
    end


    initial begin
        tb_clk = 0;

        // Run long enough to see multiple frames
        #(HSYNC_WIDTH*VSYNC_WIDTH*2*40); // 2 frames worth of clock cycles
        $finish;
    end


    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_My_VGA_Sync_Pulse_Gen);
    end

endmodule
