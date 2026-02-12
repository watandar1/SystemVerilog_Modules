/*
2026-02-12: bram module, this needs to be able to have 2 write and 1 read
design a prioritized logic since all three options cannot occur at the same time

*/

`timescale 1ns/1ps // timescale for simulation

module my_BRAM #(
    // GLOBAR PARAMETERS
    parameter GRID_WIDTH = 40,
    parameter GRID_HEIGHT = 30
) (
    // INPUTS:
    input logic i_clk, // clock input
    input logic i_rst_n, // active low reset input

    // Port 1: WRITE
    input logic i_port1_write_en, // write enable for port 1
    input logic [5:0] i_port1_write_x, // x position to write
    input logic [4:0] i_port1_write_y, // y position to write

    // Port 2: WRITE
    input logic i_port2_write_en, // write enable for port 2
    input logic [5:0] i_port2_write_x, // x position to write
    input logic [4:0] i_port2_write_y, // y position to write

    // Port 3: READ
    input logic i_port3_read_en, // read enable for port 3
    input logic [5:0] i_port3_read_x, // x position to read
    input logic [4:0] i_port3_read_y // y position to read
    // data read from the BRAM, 2 bits to represent the state of the cell (empty, food, snake)
    output logic [1:0] o_port3_read_data 

);

// LOCAL PARAMETERS:

// INTERNAL SIGNALS:

// Define the state of each cell in the GRID
typedef enum logic [1:0] {
    EMPTY, 
    IS_FOOD, 
    IS_SNAKE
} cell_state_t;
cell_state_t cell_state [GRID_WIDTH-1:0][GRID_HEIGHT-1:0]; // 2D array to represent the state of each cell in the grid

// combinational read logic for port 3, if read is enabled output the state of the cell at (X,Y), otherwise output 0
assign o_port3_read_data = (i_port3_read_en) ? cell_state[i_port3_read_x][i_port3_read_y] : 2'b00; // output the state of the cell at the read position when read enable is high, otherwise output 0

// Define the state of the BRAM operation prioritization logic
typedef enum logic [1:0] {
    PORT1_WRITE,
    PORT2_WRITE,
    PORT3_READ
} bram_state_t;
bram_state_t bram_state; // state register for the BRAM operation prioritization logic


    logic bram_write_en;            // Final write enable signal to the BRAM
    logic [5:0]  bram_write_x;      // Final write X-address to the BRAM
    logic [4:0]  bram_write_y;      // Final write Y-address to the BRAM
    logic [1:0]  bram_write_data;   // Final write data to the BRAM

    // Priority-based Arbitration:
    // If the snake wants to write, it ALWAYS wins. since it will only write when eating food
    // The food spawner only gets to write if the snake is NOT writing.
    always_comb begin
        if (i_snake_write_en) begin
            // Priority 1: Snake
            bram_write_en   = i_snake_write_en;
            bram_write_x    = i_snake_write_x;
            bram_write_y    = i_snake_write_y;
            bram_write_data = i_snake_write_data;
        end else if (i_food_write_en) begin
            // Priority 2: Food
            bram_write_en   = i_food_write_en;
            bram_write_x    = i_food_write_x;
            bram_write_y    = i_food_write_y;
            bram_write_data = i_food_write_data;
        end else begin
            // No one is writing
            bram_write_en   = 1'b0;
            bram_write_x    = '0; // Default values don't matter when write_en is low
            bram_write_y    = '0;
            bram_write_data = '0;
        end
    end

// Since the 3 modules cannot WRITE and read at the same time
// a prioritization logic is needed,
// Priority: Port 1 WRITE > Port 2 WRITE > Port 3 READ
// Question is, should snake have higher priority that food or the other way around


// BRAM logic
// BRAM grid storage 40x30 total cells 1200

    
endmodule