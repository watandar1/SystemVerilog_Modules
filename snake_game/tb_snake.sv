/*
testbench for snake module
date: 2026-02-12

*/

`timescale 1ns/1ps // timescale for simulation

module tb_snake;

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

    logic [7:0] tb_game_tick_counter; // counter to keep track of game ticks for testing purposes

    logic tb_frame_reset;
    logic tb_game_counter;
    
    logic [$clog2(HSYNC_WIDTH)-1:0] tb_hsync_pulse_counter;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(VSYNC_WIDTH)-1:0] tb_vsync_pulse_counter;  
    //changed the parameters so the signals can be observed better


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
    /*
    
    
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
    */
    
    
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

    logic tb_collision; // signal to indicate collision, can be controlled in the testbench
    logic tb_turn_left; // signal to indicate turn left, can be controlled in the testbench
    logic tb_turn_right; // signal to indicate turn right, can be controlled in the testbench
    logic [5:0] tb_snake_body_x [1199:0]; // x position of the snake's body segments, can be observed in the testbench
    logic [4:0] tb_snake_body_y [1199:0]; // y position of the snake's body segments, can be observed in the testbench
    logic [5:0] tb_snake_head_x; // x position of the snake's head, can be
    logic [4:0] tb_snake_head_y; // y position of the snake's head, can be observed in the testbench
    logic tb_game_over; // signal to indicate game over, can be observed in the testbench

    logic [10:0] tb_snake_length; // length of the snake, can be observed in the testbench
    logic tb_body_grow; // signal to indicate body should grow, can be observed in the testbench

    // instantiate the snake module
    snake uut (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .i_game_start(tb_game_start),
        .i_game_tick(tb_game_tick),
        .i_food_eaten(tb_food_consumed), // connect food consumed signal to the snake module
        .i_collision(tb_collision), // for now, we can tie collision signal to 0, we will test collision later
        .i_turn_left(tb_turn_left), // for now, we can tie turn signals to 0, we will test turning later
        .i_turn_right(tb_turn_right),
        .o_snake_body_x(tb_snake_body_x), // we can leave these unconnected for now, we will test the snake's movement later
        .o_snake_body_y(tb_snake_body_y),
        .o_snake_head_x(tb_snake_head_x),
        .o_snake_head_y(tb_snake_head_y),
        .o_snake_length(tb_snake_length), // we can leave this unconnected for now, we will test the snake's length later
        .o_game_over(tb_game_over)
    );

    initial begin
        tb_clk = 0;
        forever #20 tb_clk = ~tb_clk; // 25 MHz clock (40ns period)
    end


    // display the the snakes state and movement state
    always @(posedge tb_game_tick) begin

        $display("[%0t ns] Snake head Spawned at: X=%d, Y=%d", $time, tb_snake_head_x, tb_snake_head_y);
        $display("[%0t ns] FSM state is: %s", $time, uut.state.name());
        $display("[%0t ns] snake direction is: %s", $time, uut.direction.name());
        $display("[%0t ns] snake length is: %d", $time, tb_snake_length);
        $display("[%0t ns] snake body x position is: %b", $time, tb_snake_body_x[0]); // display the x coordinate of the first body segment as an example, we can display more segments if needed
        $display("[%0t ns] snake body y position is: %b", $time, tb_snake_body_y[0]); // display the y coordinate of the first body segment as an example, we can display more segments if needed

    end

    //get a tick counter to do stuff with, is usefull
    always @(posedge tb_game_tick) begin

        tb_game_tick_counter <= tb_game_tick_counter + 1; // increment game tick counter for testing purposes
        if (tb_game_tick_counter >= 120) begin
            $display("[%0t ns] Game Tick: %d", $time, tb_game_tick_counter);
            tb_game_tick_counter <= 0; // reset counter after 120 ticks (10 seconds)
        end 

    end

    // turn left task, holds down the left turn signal for one game tick to ensure the turn is registered in the FSM
    task turn_left();
        begin
            @(posedge tb_game_tick); // wait for the next game tick to turn left, this ensures the turn is registered in the FSM at the right time
            tb_turn_left = 1;
            @(posedge tb_game_tick); // wait for the next game tick to reset the turn signal, this ensures the turn signal is only high for one game tick
            tb_turn_left = 0;
            $display("[%0t ns] Turned LEFT", $time);
        end
    endtask

    // turn right task, holds down the right turn signal for one game tick to ensure the turn is registered in the FSM
    task turn_right();
        begin
            @(posedge tb_game_tick); // wait for the next game tick to turn right, this ensures the turn is registered in the FSM at the right time
            tb_turn_right = 1;
            @(posedge tb_game_tick); // wait for the next game tick to reset the turn signal, this ensures the turn signal is only high for one game tick
            tb_turn_right = 0;
            $display("[%0t ns] Turned RIGHT", $time);
        end
    endtask

    task food_eaten();
        begin
            @(posedge tb_game_tick); // wait for the next game tick to simulate food consumption, this ensures the food consumption is registered in the FSM at the right time
            tb_food_consumed = 1; // simulate food consumption, this should trigger the snake to grow
            @(posedge tb_game_tick); // wait for the next game tick to reset the food consumed signal, this ensures the food consumed signal is only high for one game tick
            tb_food_consumed = 0;
            $display("[%0t ns] Food Eaten", $time);
        end
    endtask

     // Test sequence
    initial begin
        // Initialize inputs
        tb_rst_n = 0;
        tb_food_consumed = 0;
        tb_collision = 0;
        tb_turn_left = 0;
        tb_turn_right = 0;
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

        wait(tb_game_tick_counter == 10); // wait for 10 game ticks (about 1 second) before simulating food consumption
        turn_left(); // turn left at the first opportunity

        wait(tb_game_tick_counter == 20); // wait for 10 more game ticks (about 1 second) before simulating food consumption
        food_eaten(); // simulate food consumption to test snake growth

        
        #(HSYNC_WIDTH*VSYNC_WIDTH*100*40); //  frames worth of clock cycles
        $finish; // end simulation
    end

    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_snake);
    end

    endmodule