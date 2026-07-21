/*
2026-06-18:
    synchronous FIFO implementation in SystemVerilog
    implemented to use fully utilize the 18 Kb block of Arty A7-100T, 
    with a data width of 18 bits and a depth of 1024 entries. 
    The FIFO supports synchronous reset, write enable, and read enable signals. 
    The full and empty flags are generated based on the count of items in the FIFO.

2026-07-01
    was tested with testbench real quick, worked properly
    also was synthesized with vivado on arty a7-100T -> was correctly assiged to ram block 18KB! :D

2026-07-03
    FIFO doesnt really work as memory since its desctructive, meaning that when you read from it, the data is lost.
    can be used as a buffer especially for streaming data, also for clock domain crossing

2026-07-21
    did some more testing with the FIFO, this is actually a Circular FIFO, sure once read that value 
    is destoryed, but once its destroyed, another slot is free. which means we can write to it again.
    testing this with 4 bit depth shows this very good. 
    All of this is possible thanks to the MSB, addind one more bit for the pointers allows for this
    

*/
`timescale 1ns/1ps
module fifo_sync_18Kb #(
    // 18 Kb FIFO for one 18Kb block for arty A7-100T
    parameter DATA_WIDTH = 18,
    parameter FIFO_DEPTH = 1024
) (
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic rd_en,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

logic [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0]; // FIFO memory array

// 11 bits pointer so we can use MSB flip trick to distinguish between full and empty states
logic [$clog2(FIFO_DEPTH):0] wr_ptr; // Write pointer
logic [$clog2(FIFO_DEPTH):0] rd_ptr; // Read pointer

//since this is sync FIFO, we use sync reset
always_ff @(posedge clk) begin
    if (!rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
    end else begin

        // Write operation
        if (wr_en && !full) begin
            fifo_mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= data_in; // Write data to FIFO
            wr_ptr <= wr_ptr + 1; // Increment write pointer
        end

        // Read operation
        if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]]; // Read data from FIFO
            rd_ptr <= rd_ptr + 1; // Increment read pointer
        end

    end 
end

// Full and empty flag generation

// FIFO is full when write pointer equals read pointer but MSB of write pointer is different
// 1. compare the adress, should be same
assign full = ((wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]) && 
                (wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)])); 


assign empty = (wr_ptr == rd_ptr); // FIFO is empty when write pointer equals read pointer


endmodule
