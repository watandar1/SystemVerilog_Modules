/*
this module should generate a tick for the snake game engine to run at
i.e. the snake moving forward, spawning food, spawning wall/posing, etc. etc.
tested with tb_game_tick.sv and it works 2026-02-07
*/

`timescale 1ns/1ps // timescale for simulation

module game_tick #(
    // Global parameters: 
    parameter FRAMES_PER_TICK = 5 // for snake this means how many cells it will move every second

) (
    // Inputs:
    input logic i_clk, // clock is 25 MHz, 
    input logic i_rst_n,

    input logic frame_start,

    // Outputs:
    output logic o_game_tick

);

// local parameter

// internal signals
// register to count
logic [5:0] frame_counter;

// game tick logic
// 20 ns trigger 25 Mhz clock
// 
always_ff @(posedge i_clk) begin
    if (!i_rst_n) begin
        frame_counter <= 0;
        o_game_tick   <= 1'b0;
    end else if (frame_start) begin
        if (frame_counter == (FRAMES_PER_TICK-1)) begin
            o_game_tick <= 1'b1;
            frame_counter <= 0;
        end else begin
            o_game_tick <= 1'b0;
            frame_counter <= frame_counter + 1;
        end
    end
    else begin
        o_game_tick <= 1'b0;
    end
end 
endmodule
