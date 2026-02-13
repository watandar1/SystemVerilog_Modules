/*
This module should spawn consumeable for the player
it should randomly place food items on the game field
it should signal when food is consumed by the snake
use Linear feedback shift register (LFSR) for random position generation
the module works, dont touch
*/

`timescale 1ns/1ps // timescale for simulation

module food #(
    //Global parameters
) (
    //Inputs:

    // clock input
    input logic i_clk,
    // reset input, not needed here, we have mealy fsm? or should I have reset, where do I reset though...
    input logic i_rst_n,

    // signal from snake module indicating food has been consumed, meaning new food can be spawned
    input logic i_food_consumed,

    // signal from collision detection module indicating food can be placed at new position
    // if low, keep changing food position until it is high, then spawn food at that position
    input logic i_food_place_ok,
    input logic i_game_tick, // signal from game tick module
    input logic i_game_start, // signal to indicate game has started, food should start spawning after game start

    //Outputs:

    output logic [5:0] o_food_x, // x position of the food 
    output logic [4:0] o_food_y, // y position of the food 
    output logic o_spawn_food    // command to spawn food
);

//local parameters:

//internal signals:
logic [15:0] random_number; // random number from LFSR
logic [6:0] game_tick_counter;  // counter to keep track of game ticks for food spawning logic,
                                // 256 counter, 10 second is 120 ticks


// use LFSR to generate random positions for the food
my_LFSR #(
    .WIDTH(16)
) uut (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .random_number(random_number)
);

// food spawning logic
// should use mealy FSM, the state is dependent on inputs, and the output is also dependent on the state and inputs

typedef enum logic [2:0] {IDLE, GET_FOOD_LOCATION, SPAWN_FOOD, HOLD_FOOD, FOOD_DELAY} state_t;
state_t state;

always_ff @(posedge i_clk) begin

    if (!i_rst_n) begin
        state <= IDLE;
        // set everything to default values which is 0
        o_food_x <= 0;
        o_food_y <= 0;
        o_spawn_food <= 1'b0;
        game_tick_counter <= 0; // reset counter

    end else begin    
    
        unique case (state)
            IDLE: begin
                // initialize everything to zero
                // it is already zero thanks to reset, but we can set it again just to be sure
                o_food_x <= 0;
                o_food_y <= 0;
                o_spawn_food <= 1'b0;
                game_tick_counter <= 0;

                if (i_game_start) begin
                    state <= GET_FOOD_LOCATION;
                end else begin
                    state <= IDLE;
                end
            end

            GET_FOOD_LOCATION: begin
                // get random position for food spawn, check if it is valid, if not get another random position until it is valid

                if (random_number[5:0] < 40 && random_number[10:6] < 30) begin
                    o_food_x <= random_number[5:0];
                    o_food_y <= random_number[10:6];
                    state <= SPAWN_FOOD;
                end else begin
                    state <= GET_FOOD_LOCATION; // try again to get food location
                end
            end

            SPAWN_FOOD: begin
                // spawn food at random position
                // check if the location is valid for food spawn
                // if it is valid, spawn food at that location, if not, get another random position until it is valid
                if (i_food_place_ok) begin
                    o_spawn_food <= 1'b1; // flag the rendering module to spawn food at location (o_food_x, o_food_y)
                    game_tick_counter <= 0; // reset counter
                    state <= HOLD_FOOD;
                end else begin
                    state <= GET_FOOD_LOCATION; // try again to spawn food with different random position
                end
            end

            HOLD_FOOD: begin
                // hold to food until it is consumed or 10 seconds has passed
                if (i_game_tick) begin
                    game_tick_counter <= game_tick_counter + 1;
                end else begin
                    game_tick_counter <= game_tick_counter; // hold the counter value until next game tick
                end
                //the i_food_consumed is high when snake collides with the food
                if (i_food_consumed || game_tick_counter > 120) begin // 120 game ticks = 10 seconds
                    game_tick_counter <= 0; // reset counter
                    state <= FOOD_DELAY;
                end else begin
                    state <= HOLD_FOOD;
                end
            end

            FOOD_DELAY: begin
                // after food is consumed, there should be a delay before new food is spawned, to give the player a sense of accomplishment and to make the game more enjoyable, also it gives the snake time to grow and makes the game more challenging
                // after 1 game tick or more go to state spawn food
                
                o_spawn_food <= 1'b0; // reset spawn food signal
                if (i_game_tick) begin
                    state <= GET_FOOD_LOCATION; // go to get food location state to spawn new food
                end else begin
                    state <= FOOD_DELAY;
                end
            end

            default: state <= IDLE;

        endcase
    end
end
endmodule
