/*

*/

`timescale 1ns/
module tb_my_VGA_sync_pulse_gen;

    logic tb_clk;

    logic tb_vsync_pulse;      
    logic tb_hsync_pulse;
    logic tb_vsync_active;      
    logic tb_hsync_active;
    logic tb_hsync_active_reg;
    logic tb_vsync_active_reg;

    
    logic [$clog2(800)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(525)-1:0] tb_vsync_pulse_counter;
    
    localparam CLKS_PER_BITS = 217;
    localparam VIDEO_WIDTH = 4; 
    // vga 640X480 @60 hz Timing spec     
    localparam HSYNC_WIDTH = 800;
    localparam VSYNC_WIDTH = 525;
    localparam HSYNC_ACTIVE = 640;
    localparam VSYNC_ACTIVE = 480;
    localparam HSYNC_FRONT = 16;
    localparam VSYNC_FRONT = 10;
    localparam HSYNC_BACK = 48;
    localparam VSYNC_BACK = 33;

      my_VGA_active_pulse_Gen #(
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE)

    ) vga_active_pulse_tb (
        .i_clk(tb_clk),
        .o_hsync_active(tb_hsync_active_reg),
        .o_vsync_active(tb_vsync_active_reg),
        .o_hsync_active_counter(tb_hsync_pulse_counter),
        .o_vsync_active_counter(tb_vsync_pulse_counter)
    );        

    my_VGA_sync_pulse_gen #(
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE),
        .HSYNC_FRONT(HSYNC_FRONT),
        .VSYNC_FRONT(VSYNC_FRONT),
        .HSYNC_BACK(HSYNC_BACK),
        .VSYNC_BACK(VSYNC_BACK)

    ) my_VGA_sync_pulse_gen (
        .i_clk(tb_clk),
        .i_active_hsync(tb_hsync_active_reg),
        .i_active_vsync(tb_vsync_active_reg),
        .o_hsync_pulse(tb_hsync_pulse),
        .o_vsync_pulse(tb_vsync_pulse)
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


    /*// Print when sync pulses occur
    initial begin
        $monitor("Time=%0t | HSync=%b VSync=%b | HCount=%0d VCount=%0d", 
                  $time, tb_hsync_pulse, tb_vsync_pulse,
                  tb_hsync_pulse_counter, tb_vsync_pulse_counter);
    end*/

endmodule
