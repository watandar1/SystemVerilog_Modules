/*
This module should act as a game menu
it should pause and start the game and reset the game and check for victory conditions
it should instantiate the player and the objects and events needed for the game

*/

`timescale 1ns/1ps // timescale for simulation

module game_menu #(
    //Global Parameters: (since this is game menu, probaly this is top module)
) (
    // INPUTS:

    // outputs:
);

//local parameters:


//FSM states definition, use typedef enum logic
/*
 state 1: MENU: waiting for player to start game
 state 2: PLAY: game is in progress
 state 3: PAUSE: game is paused
    state 4: GAME_OVER: game has ended (either won or lost)
 state 5: VICTORY: player has won the game

*/
    
endmodule