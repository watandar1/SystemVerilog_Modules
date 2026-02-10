/*

LFSR module for random number generation
date: 2026-02-06
comment: the testbench tests the LSFR, it does work but since at start the random number follows pattern
in real life scenario the system would be running and when the random number is "looked" at it would seem random
although its not really random and it does follow a pattern, 
but if other modules just look at the random number at random times it would seem random 
enough for our purposes, and it does not repeat until 65535 cycles which is good enough for our game


*/
`timescale 1ns/1ps // timescale for simulation

module my_LFSR #(
    // Global parameter
    parameter WIDTH = 16 // width of the LFSR

) (
    // Inputs:
    input logic clk, // clock input
    input logic rst_n, // active low reset input

    // Outputs:
    output logic [WIDTH-1:0] random_number // random number output with WIDTH bits
);

// Local parameters:

// Internal signals:

// Implement the LSFR logic here

always_ff @(posedge clk) begin
    if (!rst_n) begin
        random_number <= {WIDTH{1'b1}}; 
    end else begin
        random_number <= {random_number[WIDTH-2:0], random_number[WIDTH-1] ^ random_number[WIDTH-3] ^ random_number[WIDTH-4] ^ random_number[WIDTH-6]};
    end
end

    
endmodule