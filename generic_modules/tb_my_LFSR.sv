/*

testbench for my_LFSR
date: 2026-02-06
comment: the testbench tests the LSFR, it does work but since at start the random number follows pattern
in real life scenario the system would be running and when the random number is "looked" at it would seem random
although its not really random and it does follow a pattern, 
but if other modules just look at the random number at random times it would seem random 
enough for our purposes, and it does not repeat until 65535 cycles which is good enough for our game

*/

`timescale 1ns/1ps // timescale for simulation

module tb_my_LFSR;

    logic tb_clk;
    logic [15:0] tb_random_number;
    logic tb_rst;

    my_LFSR #(
        .WIDTH(16)
    ) uut (
        .clk(tb_clk),
        .rst_n(tb_rst),
        .random_number(tb_random_number)
    );
    
    
    always begin
        #20;
        tb_clk <= ~tb_clk; // 25 MHz clock
    end

    initial begin
        tb_clk = 0;
        tb_rst = 0;
        
        #30;
        
        tb_rst = 1'b1;
        
        #3000;
        $finish;
    end
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_my_LSFR);
    end


endmodule