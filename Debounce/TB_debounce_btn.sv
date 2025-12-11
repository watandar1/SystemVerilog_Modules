/*
tb for debounce filter button
*/
`timescale 1ns / 1ps

module TB_debounce_btn(
logic tb_clk,
logic tb_btn,
logic tb_rst,
logic tb_led
    );
    
    // time unit 5 ns -> toggle it on and off meaning a period is 10ns -> 100MHz clock
    always #5 tb_clk = ~tb_clk; 
    
    //instantiate debounce filter module 
    //the debunce timer is 5 ms which is the time that a button press is acknowledged
    Debounce_btn uut (
        .i_clk(tb_clk),
        .i_rst(tb_rst),
        .i_btn(tb_btn),
        .o_led(tb_led)
    );

    initial begin
        tb_clk = 0;
        tb_btn = 0;
        tb_rst = 1;
        //Test sequence wait for initial stabilization
        //which is 10 us 
        #1000; tb_rst = 0;

        $display("glitch button press")
        //simulate glitches on the button, turn on the turn off the button for 100 us
        repeat (5) begin
            tb_btn = 1; #100000; tb_btn = 0; #100000;
        end

        $display("5ms button press")
        //push the button for exact 5ms
        tb_btn = 1; #5000000; tb_btn = 0; # 10000000;

        $display("Testing reset during 2 ms press");
        tb_btn = 1; #2000000; tb_rst = 1; #100; tb_rst = 0; #100000;


        $monitor("Time=%0t clk=%b btn=%b led=%h", $time, tb_clk, tb_btn, tb_led);

        #1000000 $finish;

    end
    
endmodule


