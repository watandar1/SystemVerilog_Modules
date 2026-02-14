/*
render module, this module should take in snake and food and render them correctly on the screen
it should use collision detection module to detect if collision will/has occured and signal relevant module about the collision
FOOD.sv module:
    takes in food (X,Y) coordinates, checks if the coordinate is valid, then either signals for new coord. or signals to spawn food at that location

SNAKE.sv module:
    takes in snake head (X,Y) coordinates and body coordinates, checks for collisions with itself or food,
    signals for growth when food is consumed, and signals for game over when collision with self
    uses snake length to determine how many body segments to display, this way we can create the illusion of growth without actually having to add segments

*/

`timescale 1ns/1ps // timescale for simulation

module render_game #(
    //Global parameters
) (
    //Inputs:

    // clock input
    input logic i_clk,
    // reset input,
    input logic i_rst_n,

    //========================================================================================================
    input logic i_game_tick, // signal from game tick module
    input logic i_game_start, // signal to indicate game has started, rendering should start after

    input logic [5:0] i_grid_col_x, // width of the game grid, can be used for rendering and collision detection
    input logic [4:0] i_grid_row_y, // height of the game grid, can be used for rendering and collision detection
   
    input logic i_video_on,
    //========================================================================================================


    // Snake input signals
    //========================================================================================================
    // signal from snake module indicating snake head and body coordinates and snake length for rendering
    input logic [5:0] i_snake_body_x [110:0], // x position of the snake's body segments, can be observed in the testbench
    input logic [4:0] i_snake_body_y [110:0], // y position of the snake's body segments, can be observed in the testbench
    input logic [5:0] i_snake_head_x,          // x position of the snake's head
    input logic [4:0] i_snake_head_y,           // y position of the snake's head
    input logic [10:0] i_snake_length,          // length of the snake, can be observed in the testbench
    //========================================================================================================

    // Food input signals
    //========================================================================================================
    // signal from food module indicating food coordinates for rendering
    input logic [5:0] i_food_x, // x position of the food 
    input logic [4:0] i_food_y, // y position of the food 
    //========================================================================================================


    //Outputs:

    // VGA output signals
    //========================================================================================================
    output logic [3:0] o_vga_red, // red color signal to VGA
    output logic [3:0] o_vga_green, // green color signal to VGA
    output logic [3:0] o_vga_blue, // blue color signal to VGA

    //========================================================================================================

    // Snake output signals
    //========================================================================================================
    output logic o_snake_collision, // signal to indicate snake has collided with itself or wall

    //========================================================================================================

    // Food output signals
    //========================================================================================================
    output logic o_food_consumed,
    output logic o_food_place_ok

    //========================================================================================================

);

// --- Object Detection Signals ---
logic is_apple;
logic is_head;
logic is_body;


// 1. Check if current grid matches the Apple
assign is_apple = (i_grid_col_x == i_food_x) && (i_grid_row_y == i_food_y);

// 2. Check if current grid matches the Snake Head

assign is_head  = (i_grid_col_x == i_snake_head_x) && (i_grid_row_y == i_snake_head_y);

// 3. Check if current grid matches ANY part of the Snake Body
always_comb begin
    is_body = 1'b0; // Default to 0
    // Loop through the maximum possible body size
    for (int i = 0; i < 120; i++) begin
        // Only check segments that actually exist based on current length
        if (i < i_snake_length) begin
            if ((i_grid_col_x == i_snake_body_x[i]) && (i_grid_row_y == i_snake_body_y[i])) begin
                is_body = 1'b1;
            end
        end
    end
end

// --- VGA RGB Color Driver ---
// We use if/else to create priority: Head > Body > Apple > Background
always_comb begin
    if (!i_video_on) begin
        // ALWAYS output 0 during the blanking interval to prevent monitor issues
        {o_vga_red, o_vga_green, o_vga_blue} = 12'h000; 
    end else if (is_head) begin
        {o_vga_red, o_vga_green, o_vga_blue} = 12'h0_F_0; // Head: Bright Green
    end else if (is_body) begin
        {o_vga_red, o_vga_green, o_vga_blue} = 12'h0_8_0; // Body: Dark Green
    end else if (is_apple) begin
        {o_vga_red, o_vga_green, o_vga_blue} = 12'hF_0_0; // Apple: Red
    end else begin
        {o_vga_red, o_vga_green, o_vga_blue} = 12'h1_1_1; // Background: Dark Gray
    end
end


// food consume logic
assign o_food_consumed = (i_snake_head_x == i_food_x) && (i_snake_head_y == i_food_y);
// Collision Detection Logic
    // We use "sticky" logic: Start at 0, if ANY match is found, stick to 1.
    always_comb begin
        o_snake_collision = 1'b0; // Default to no collision
        o_food_place_ok   = 1'b1; // Default to OK to place food
        
        // Check collision with the head (Self-Collision)
        for(int i = 0; i <= 110; i++) begin
            if (i < i_snake_length) begin
                // Check if Head hits Body
                if ((i_snake_head_x == i_snake_body_x[i]) && (i_snake_head_y == i_snake_body_y[i])) begin
                    o_snake_collision = 1'b1; 
                end
                
                // Check if Food is inside Body (for spawning safety)
                if ((i_food_x == i_snake_body_x[i]) && (i_food_y == i_snake_body_y[i])) begin
                    o_food_place_ok = 1'b0;
                end
            end
        end

        // Also ensure food is not on the head
        if ((i_food_x == i_snake_head_x) && (i_food_y == i_snake_head_y)) begin
            o_food_place_ok = 1'b0;
        end
    end

endmodule
