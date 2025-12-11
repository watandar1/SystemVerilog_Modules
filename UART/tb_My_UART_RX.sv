/*
testbench for uart rx module
*/
`timescale 1ns/1ps

module tb_My_UART_RX;

    logic tb_clk;

    logic tb_serial_data; //data to send

    logic tb_rx_busy;
    logic tb_rx_data_valid;
    logic [7:0] tb_rx_data;


    always begin
        #5;                    //25MHz clock
        tb_clk = ~tb_clk;       //generate clock
    end 

    //emulate sending data! 8bit data
    task send_bits(input [7:0] data);
        //Send start bit 
        tb_serial_data = 1'b0;
        #8680;
        //send data bits
        for (int i = 0 ; i < 8 ; i++ ) begin
            tb_serial_data = data[i];
            #8680; //217 clks per bit one clock is 40 -> total becomes 217*40 =8680
        end

        //send stop bit
        tb_serial_data = 1'b1;
        #8680;

    endtask

    //Instantiate the clock¨
    My_UART_RX #(
        .CLKS_PER_BIT(868)      //217 clks per bit for 25 MHz clock
    ) uart_inst (
        .i_clk(tb_clk),
        .i_serial_data(tb_serial_data), // data is sent and module is receiving it
        .o_rx_busy(tb_rx_busy),
        .o_rx_data_valid(tb_rx_data_valid),
        .o_rx_data(tb_rx_data)
    );

    initial begin
        tb_clk = 0;
        #40;

        send_bits(8'hAA);

        #50000;
        $finish;
    end


    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0,tb_My_UART_RX);
    end

endmodule
