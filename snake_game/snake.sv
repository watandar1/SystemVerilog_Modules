/*
2026-01-30: This module should be finite state machine to control the snake 
It should handle the snake's movement, growth, and collision detection.
2026-02-12: the snake movement works and changing directions works.
now we need to stora body data in BRAM instead of logic arrays, and implement the body movement and growth logic
*/

`timescale 1ns/1ps // timescale for simulation

module snake #(
    //Global parameters
    GRID_WIDTH = 40,
    GRID_HEIGHT = 30
) (
    //Inputs:

    input logic i_clk, // clock input
    input logic i_rst_n, // active low reset input (not might be needed here)

    input logic i_game_start, // signal to start the game
    input logic i_game_tick, // signal to indicate a game tick
    input logic i_food_eaten, // signal to indicate the snake has eaten food
    input logic i_collision, // signal to indicate the snake has collided with itself or wall

    input logic i_turn_left, // signal to indicate a left turn
    input logic i_turn_right, // signal to indicate a right turn

    //Outputs:

    output logic [5:0] o_snake_head_x,          // x position of the snake's head
    output logic [4:0] o_snake_head_y,           // y position of the snake's head

    output logic [10:0] o_snake_length,          // length of the snake, can be used for rendering the snake's body segments

    output logic o_body_grow, // food was eaten, body should grow

    output logic o_game_over

);

//local parameters:

//internal signals:

logic [7:0] game_tick_counter; // counter for game ticks, use this to count for seconds 120 ticks is 10 seconds,

// Define cell types
typedef enum logic [1:0] {
    EMPTY,      // 2'b00
    SNAKE_BODY, // 2'b01
    FOOD,       // 2'b10
} cell_type_t;

// The game grid, inferred as BRAM
(* ram_style = "block" *)
cell_type_t game_grid [0:GRID_WIDTH-1][0:GRID_HEIGHT-1];

//FSM states definitionm use typedef enum logic
typedef enum logic [1:0] {
    IDLE, // waiting for start signal
    MOVE, // snake is moving 
    GROW, // snake is growing
    COLLISION // snake has collided with itself or wall
} state_t;
state_t state; // state register for the FSM

typedef enum logic [1:0] { 
    UP, 
    DOWN, 
    LEFT, 
    RIGHT
} direction_t;
direction_t direction; // direction register for the snake's movement

//FSM state register, use 

always_ff @(posedge i_clk) begin

    if (!i_rst_n) begin
        // reset everything to default values
        state <= IDLE;
        direction <= RIGHT; // default direction is right
        game_tick_counter <= 8'd0;
        // starting position of the snake, can be changed later
        o_snake_head_x <= 6'b000001;
        o_snake_head_y <= 5'b00001;
        o_game_over <= 0; // game is not over at reset
        o_snake_length <= 11'd0; // initial length of the snake is 0
        o_body_grow <= 0; // body should not grow at reset

    end else begin
         
        unique case (state)
            IDLE: begin
                // Initialize the snake's position and state
                o_game_over <= 0; // game is not over in IDLE state
                if (i_game_start) begin
                    state <= MOVE; // transition to MOVE state when game starts
                end else begin
                    state <= IDLE; // remain in IDLE state if game has not started
                end
            end

            MOVE: begin
            // Code to move the snake based on control inputs (not implemented yet)
            // Update snake_head_x and snake_head_y based on the current direction
                if (i_game_tick) begin
                    // Update snake position based on direction
                    if (i_turn_left) begin
                        // Update direction based on current direction and turn left input
                        unique case (direction)
                            UP: direction <= LEFT; // turn left from UP to LEFT
                            DOWN: direction <= RIGHT; // turn left from DOWN to RIGHT
                            LEFT: direction <= DOWN; // turn left from LEFT to DOWN
                            RIGHT: direction <= UP; // turn left from RIGHT to UP
                        endcase
                end else if (i_turn_right) begin
                        // Update direction based on current direction and turn right input
                        unique case (direction)
                            UP: direction <= RIGHT; // turn right from UP to RIGHT
                            DOWN: direction <= LEFT; // turn right from DOWN to LEFT
                            LEFT: direction <= UP; // turn right from LEFT to UP
                            RIGHT: direction <= DOWN; // turn right from RIGHT to DOWN
                        endcase
                end

                unique case (direction)
                    UP: o_snake_head_y <= o_snake_head_y + 5'b00001; // move up by increasing y coordinate
                    DOWN: o_snake_head_y <= o_snake_head_y - 5'b00001; // move down by decreasing y coordinate       
                    LEFT: o_snake_head_x <= o_snake_head_x - 6'b000001; // move left by decreasing x coordinate
                    RIGHT: o_snake_head_x <= o_snake_head_x + 6'b000001; // move right by increasing x coordinate
                endcase

                if (i_food_eaten) begin
                    state <= GROW; // transition to GROW state when food is eaten
                end else if (i_collision) begin
                    state <= COLLISION; // transition to COLLISION state when a collision is detected
                end else begin
                    state <= MOVE; // remain in MOVE state if no food is eaten and no collision is detected
                end
            end
            end

            GROW: begin
            // Code to grow the snake (not implemented yet)
            // This would involve adding a new segment to the snake's body
            // This state should write to the BRAM to update the snake's body segments
            
                state <= MOVE; // transition back to MOVE state after growing

            end
            
            COLLISION: begin
                // Code to handle collision (not implemented yet)
                // This could involve resetting the game or ending it
                o_game_over <= 1; // set game over signal when collision occurs
                state <= IDLE; // transition back to IDLE state after collision
            end

            default: state <= IDLE; // default case to handle unexpected states

        endcase
    end
end
endmodule
