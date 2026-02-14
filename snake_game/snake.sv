/*
2026-01-30: This module should be finite state machine to control the snake 
It should handle the snake's movement, growth, and collision detection.
2026-02-12: the snake movement works and changing directions works.
now we need to stora body data somehow and move the body correctly
2026-02-13: added body storage logic, the module sends an entire "full snake" to the render module as well as a
score "snake_length" to indicate how many segments to display. this way we have a snake that can eat and "grow"
but it doesnt actually grow except the visible length increases, creating the illusion of growth
the design is bad because it takes to much resources and doesnt actually grow
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
    // for now have packed shift registers to store the body segments
    // it uses 1200*6 = 7200 bits to store X coordinates
    // and 1200*5 = 6000 bits to store the Y coordinates
    // in total of 13200 bits to store the snakes body, which is roughly around 10% of ARTY A7-100T logic resource

    // the "body" contains of all coordinates possible and it follows the head
    // the render module should only display the number of segments equal to the snake length, 
    // this way we can create the illusion of growth without actually having to add segments
    output logic [5:0] o_snake_body_x [110:0], // x position of the snake's body segments, can be observed in the testbench
    output logic [4:0] o_snake_body_y [110:0], // y position of the snake's body segments, can be observed in the testbench
    // the "player"
    output logic [5:0] o_snake_head_x,          // x position of the snake's head
    output logic [4:0] o_snake_head_y,           // y position of the snake's head

    // length of the snake, the render module should use this to determine how many segments to display
    // essentially this acts as a score board for the player
    output logic [10:0] o_snake_length,

    // flag to indicate game is over
    output logic o_game_over

);

//local parameters:

//internal signals:

logic [7:0] game_tick_counter; // counter for game ticks, use this to count for seconds 120 ticks is 10 seconds,


//FSM states definitionm use typedef enum logic
// these states are not really usefull as of 2026-02-13 but in future if one want to add or create more...
typedef enum logic [1:0] {
    IDLE, // waiting for start signal
    MOVE, // snake is moving 
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
        //o_body_grow <= 0; // body should not grow at reset
        // initialize body segments to 0
        for (int i = 0; i < 12; i++) begin
            o_snake_body_x[i] = 6'b000000; // initialize body segment x positions to 0
            o_snake_body_y[i] = 5'b00000; // initialize body segment y positions to 0
        end

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
                            UP: direction <= RIGHT;     // turn right from UP to RIGHT
                            DOWN: direction <= LEFT;    // turn right from DOWN to LEFT
                            LEFT: direction <= UP;      // turn right from LEFT to UP
                            RIGHT: direction <= DOWN;   // turn right from RIGHT to DOWN
                        endcase
                    end
                    
                    // looping through 1200 segments is too much and power consuming
                    // the snake length is the limiter to moving the segments, this is order to "save power"
                    for (int i = 110; i > 0; i--) begin
                        //if (i < o_snake_length) begin // only update body segments that are within the current length of the snake
                        o_snake_body_x[i] = o_snake_body_x[i-1]; // update body segment X coordinate to follow the previous segment
                        o_snake_body_y[i] = o_snake_body_y[i-1]; // update body segment Y coordinate to follow the previous segment
                        //end
                    end
                    // this section actually moves the head, it should also move the body
                    unique case (direction)
                        UP:begin
                            if (o_snake_head_y == 29) begin
                                o_snake_head_y <= 0;
                            end else begin
                                o_snake_head_y <= o_snake_head_y - 5'b00001; // move up by increasing y coordinate
                            end
                        end 
                        DOWN: begin
                            if (o_snake_head_y == 29) begin
                                o_snake_head_y <= 0;
                            end else begin
                                o_snake_head_y <= o_snake_head_y + 5'b00001; // move up by increasing y coordinate
                            end
                        end    
                        LEFT: begin
                            if (o_snake_head_x == 39) begin
                                o_snake_head_x <= 0;
                            end else begin
                                o_snake_head_x <= o_snake_head_x - 6'b000001; // move left by decreasing x coordinate
                            end
                        end 
                        RIGHT: begin
                            if (o_snake_head_x == 39) begin
                                o_snake_head_x <= 0;
                            end else begin
                                o_snake_head_x <= o_snake_head_x + 6'b000001; // move left by decreasing x coordinate
                            end
                        end 
                    endcase

                    o_snake_body_x[0] <= o_snake_head_x; // update first body segment X coordinate, so the tail follows
                    o_snake_body_y[0] <= o_snake_head_y; // update first body segment Y coordinate, so the tail follows


                    if(i_food_eaten) begin
                        if (o_snake_length < 110 ) begin
                            o_snake_length <= o_snake_length + 1; // increase snake length by 1 when food is eaten
                        end
                        // Add logic for if the snake has reached max length
                    end 

                    if (i_collision) begin
                        state <= COLLISION;
                    end
                    end
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
