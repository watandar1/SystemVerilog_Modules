/*
Clock divider, it divides the clock by div

AS OF 20250920 22:40
    THIS MODULE WORKS FINE!

AS OF 20251215 07:40
    THIS MODULE WORKS FINE!

*/

//for simulating with verilator add timescale `timescale 1ns/1ps
`timescale 1ns/1ps

module my_clk_divider#(
    parameter div = 4 //to divided by
) (
    input logic i_CLK,  //input clock to divide
    input logic i_rst_n,
    output logic o_CLK  // output clock that is divided
);

logic [(div/2):0] counter = 0;      // create counter to be able to divide, divide it by 2 since we dont need to allocate that much here

//we need to trigger on negedge so it can count as a period. if posedge then the counter goes up at half period
always_ff @(negedge i_CLK or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_CLK <= 0;
        counter <= 0;
    end else begin
         if (counter == (div/2 - 1)) begin
            o_CLK <= ~o_CLK;
            counter <= 0;
        end else begin
            counter <= counter + 1'b1;
        end
    end
end    
endmodule

