/*
testbench for food module
date: 2026-02-07

*/

`timescale 1ns/1ps // timescale for simulation

module tb_food;

    // Inputs:
    logic tb_clk;
    logic tb_rst_n;
    logic tb_food_consumed;
    logic tb_food_place_ok;
    logic tb_game_tick;
    logic tb_game_start;

    // Outputs:
    logic [5:0] tb_food_x;
    logic [4:0] tb_food_y;
    logic tb_spawn_food;

    logic tb_vsync;      
    logic tb_hsync;

    logic [6:0] tb_game_tick_counter; // counter to keep track of game ticks for testing purposes

    logic tb_frame_reset;

    
    logic [$clog2(HSYNC_WIDTH)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(VSYNC_WIDTH)-1:0] tb_vsync_pulse_counter;  
    //changed the parameters so the signals can be observed better
/*
    // Hsync pulse 8 bits and Vsync pulse 2 bits
    localparam HSYNC_WIDTH = 56;
    localparam VSYNC_WIDTH = 35;
    localparam HSYNC_ACTIVE = 40;
    localparam VSYNC_ACTIVE = 30;
    localparam HSYNC_FRONT = 4;
    localparam VSYNC_FRONT = 1;
    localparam HSYNC_BACK = 4;
    localparam VSYNC_BACK = 2;
    localparam HSYNC_PULSE = 8;
    localparam VSYNC_PULSE = 2;
    */
    
    // vga 640X480 @60 hz Timing spec
    localparam HSYNC_WIDTH = 800;
    localparam VSYNC_WIDTH = 525;
    localparam HSYNC_ACTIVE = 640;
    localparam VSYNC_ACTIVE = 480;
    localparam HSYNC_FRONT = 16;
    localparam VSYNC_FRONT = 10;
    localparam HSYNC_BACK = 48;
    localparam VSYNC_BACK = 33;
    localparam HSYNC_PULSE = 96;
    localparam VSYNC_PULSE = 2;
    
    
    // generate active signals and frame reset signal for game tick generation
    my_VGA_active_pulse_Gen #(
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE)

    ) vga_active_pulse_tb (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .o_hsync_active(tb_hsync),
        .o_vsync_active(tb_vsync),
        .o_w_frame_reset(tb_frame_reset),
        .o_hsync_frame_pos(tb_hsync_pulse_counter),
        .o_vsync_frame_pos(tb_vsync_pulse_counter)
    );      
    // Generate game tick signal based on frame reset signal from VGA active pulse generator
    game_tick #(
        .FRAMES_PER_TICK(5)
    ) game_tick_tb (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .frame_start(tb_frame_reset),
        .o_game_tick(tb_game_tick)
    );

    // Instantiate the food module
    food uut (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .i_food_consumed(tb_food_consumed),
        .i_food_place_ok(tb_food_place_ok),
        .i_game_tick(tb_game_tick),
        .i_game_start(tb_game_start),
        .o_food_x(tb_food_x),
        .o_food_y(tb_food_y),
        .o_spawn_food(tb_spawn_food)
    );

    // Clock generation
    initial begin
        tb_clk = 0;
        forever #20 tb_clk = ~tb_clk; // 40 ns period => 25 MHz clock
    end

    always @(posedge tb_spawn_food) begin
        $display("[%0t ns] Food Spawned at: X=%d, Y=%d", $time, tb_food_x, tb_food_y);
    
    // Automatic bounds check
        if (tb_food_x >= 40 || tb_food_y >= 30) begin
            $display("ERROR: Food spawned out of bounds!");
        end
    end

    always @(posedge tb_game_tick) begin
        // Use the hierarchical path: instance_name.internal_signal_name
        $display("[%0t ns] FSM state is: %s", $time, uut.state.name());

    end
    

    always @(posedge tb_game_tick) begin

        tb_game_tick_counter <= tb_game_tick_counter + 1; // increment game tick counter for testing purposes
        if (tb_game_tick_counter >= 120) begin
            $display("[%0t ns] Game Tick: %d", $time, tb_game_tick_counter);
            tb_game_tick_counter <= 0; // reset counter after 120 ticks (10 seconds)
        end 

    end


    // Test sequence
    initial begin
        // Initialize inputs
        tb_rst_n = 0;
        tb_food_consumed = 0;
        // assume we can place food at the start
        // change this later to test the case where food cannot be placed
        tb_food_place_ok = 1; 
        tb_game_start = 0;

        // Wait for a few clock cycles and then release reset
        #100;
        tb_rst_n = 1;

        // Start the game
        #100;
        tb_game_start = 1;

        // testbench logic to test uut




        
        #(HSYNC_WIDTH*VSYNC_WIDTH*3000000000*40); // 100000000 frames worth of clock cycles
        $finish; // end simulation
    end

    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_food);
    end

    endmodule
