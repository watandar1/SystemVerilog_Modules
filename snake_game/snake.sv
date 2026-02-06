/*
2026-01-30: This module should be finite state machine to control the snake 
It should handle the snake's movement, growth, and collision detection.
*/

`timescale 1ns/1ps // timescale for simulation

module snake #(
    //Global parameters
) (
    //Inputs:

    input logic i_clk, // clock input

    input logic i_rst_n, // active low reset input (not might be needed here)



    // control inputs: left or right turn

    //Outputs:

);


//local parameters:


//internal signals:

 logic [10:0] snake_head_x; // x position of the snake's head
 logic [10:0] snake_head_y; // y position of the snake's head


//FSM states definitionm use typedef enum logic
typedef enum logic [1:0] {
    IDLE, // waiting for start signal
    MOVE, // snake is moving 
    GROW, // snake is growing
    COLLISION // snake has collided with itself or wall
} state_t;
state_t snake; // state register for the FSM

typedef enum logic [1:0] {
    UP,
    DOWN,
    LEFT,
    RIGHT
} direction_t;
direction_t snake_direction; // register to hold the current direction of the snake

//FSM state register, use 

always_ff @(posedge i_clk) begin

    unique case (snake)
        IDLE: begin
            // Initialize the snake's position and state
            snake_head_x <= 11'd320; // Start in the middle of the screen
            snake_head_y <= 11'd240;
            // Wait for a start signal to transition to MOVE state
        end

        MOVE: begin
            // Code to move the snake based on control inputs (not implemented yet)
            // Update snake_head_x and snake_head_y based on the current direction
            unique case (snake_direction)
                UP: begin
                    snake_head_y <= snake_head_y - 1; // Move up
                end
                DOWN: begin
                    snake_head_y <= snake_head_y + 1; // Move down
                end
                LEFT: begin
                    snake_head_x <= snake_head_x - 1; // Move left
                end
                RIGHT: begin
                    snake_head_x <= snake_head_x + 1; // Move right
                end
                default: begin
                    // Default case to handle unexpected direction values
                end
            endcase
        end

        GROW: begin
            // Code to grow the snake (not implemented yet)
            // This would involve adding a new segment to the snake's body
        end

        COLLISION: begin
            // Code to handle collision (not implemented yet)
            // This could involve resetting the game or ending it
        end

        default: begin
            state <= IDLE; // Default state
        end
    endcase
    
end
    
endmodule
