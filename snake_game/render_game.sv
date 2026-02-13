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

    // Game input signals
    //========================================================================================================
    input logic i_game_tick, // signal from game tick module
    input logic i_game_start, // signal to indicate game has started, rendering should start after

    input logic [5:0] grid_width, // width of the game grid, can be used for rendering and collision detection
    input logic [4:0] grid_height, // height of the game grid, can be used for rendering and collision detection
    //========================================================================================================

    // VGA input signals
    //========================================================================================================
    // do we really need to input VGA singal?, its should just be output we dont care about timing here?
    input logic [3:0] i_vga_red, // red color signal from VGA active pulse generator
    input logic [3:0] i_vga_green, // green color signal from VGA active pulse generator
    input logic [3:0] i_vga_blue, // blue color signal from VGA active pulse generator
    input logic i_vga_hsync, // horizontal sync signal from VGA active pulse generator
    input logic i_vga_vsync, // vertical sync signal from VGA active pulse generator
    input logic i_vga_frame_reset, // signal from VGA active pulse generator to indicate start
    //========================================================================================================


    // Snake input signals
    //========================================================================================================
    // signal from snake module indicating snake head and body coordinates and snake length for rendering
    input logic [5:0] i_snake_body_x [1199:0], // x position of the snake's body segments, can be observed in the testbench
    input logic [4:0] i_snake_body_y [1199:0], // y position of the snake's body segments, can be observed in the testbench
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

    // Game output signals
    //========================================================================================================

    
    //========================================================================================================

    // VGA output signals
    //========================================================================================================
    output logic [3:0] o_vga_red, // red color signal to VGA
    output logic [3:0] o_vga_green, // green color signal to VGA
    output logic [3:0] o_vga_blue, // blue color signal to VGA

    //========================================================================================================

    // Snake output signals
    //========================================================================================================
    output logic o_snake_collision, // signal to indicate snake has collided with itself or wall
    output logic o_food_eaten, // signal to indicate snake has eaten food

    //========================================================================================================

    // Food output signals
    //========================================================================================================
    output logic o_food_consumed,
    output logic o_food_place_ok,

    //========================================================================================================

);

//local parameters:

//internal signals:

always_comb begin
    
end

// Render logic:
// use combinational logic to determine the color of each pixel based on the snake and food coordinates
// use the VGA sync signals to determine when to output the color signals


endmodule