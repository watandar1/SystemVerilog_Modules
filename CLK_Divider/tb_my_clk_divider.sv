/*
CHECKED 251215 AND WORKS
*/
`timescale 1ns/1ps

module tb_my_clk_divider;

    logic tb_clk;
    logic div4_clk;
    logic tb_rst;

    my_clk_divider div4 (
        .i_CLK(tb_clk),
        .i_rst_n(tb_rst),
        .o_CLK(div4_clk)
    );
    
    always begin
        #5;
        tb_clk <= ~tb_clk;
    end

    initial begin
        tb_clk = 0;
        tb_rst = 0;
        #30;
        
        tb_rst = 1'b1;
        #10
        
        #250;
        $finish;
    end
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_my_clk_divider);
    end


endmodule
