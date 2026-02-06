/*
this module should handle collision detection between the snake and the food items 
and the snake and the walls or itself it should signal when a collision occurs

*/

`timescale 1ns/1ps // timescale for simulation

module collision_detection #(
    //Global parameters
) (
    //Inputs:

    // clock input

    // reset input

    // snake position input

    // food position input

    // wall positions input

    //Outputs:

    // signal indicating collision with food

    // signal indicating collision with wall or self
);

//local parameters:

//internal signals:


//  use combinational logic to detect collisions 
//  since if using sequential logic there will be delays which are not desirable for collision detection
//  White 4'hf is background color and any other color indicates presence of an object

endmodule
