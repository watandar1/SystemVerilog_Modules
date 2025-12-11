/*

testbench for uart tx
*/

`timescale 1ns/1ps
module tb_My_Uart_TX;

    logic tb_clk=0;
    logic tb_rst=0;

    logic tb_rx_serial;
    logic tb_start_tx;
    logic tb_tx_active = 0;
    logic tb_tx_serial;

    logic tb_tx_data_done;
    
    logic tb_rx_busy;
    logic tb_rx_data_valid;
    logic [7:0] tb_rx_data = 0;
    logic [7:0] tb_tx_data;

    always begin
        #5;                    //100MHz clock
        tb_clk = ~tb_clk;       //generate clock
    end 

    task send_byte(input [7:0] data); begin
    
        tb_tx_data = data;
        tb_start_tx = 1'b1;
        @(posedge tb_clk);
        tb_start_tx = 1'b0;
        wait(tb_tx_data_done);
        
        @(posedge tb_clk);

    end

endtask

  //Instantiate the clock¨
    My_UART_RX #(
        .CLKS_PER_BIT(868)      //217 clks per bit for 25 MHz clock
    ) uart_inst (
        .i_clk(tb_clk),
        .i_serial_data(tb_rx_serial), // data is sent and module is receiving it
        .o_rx_busy(tb_rx_busy),
        .o_rx_data_valid(tb_rx_data_valid),
        .o_rx_data(tb_rx_data)
    );

    //Instantiate the clock¨
    My_Uart_TX #(
        .CLKS_PER_BIT(868)      //217 clks per bit for 25 MHz clock
    ) uart_tx_inst (
        .i_clk(tb_clk),
        .i_rst(tb_rst),
        .i_Tx_data_in(tb_tx_data),
        .i_TX_data_start(tb_start_tx),
        .o_TX_data_active(tb_tx_active),
        .o_Tx_serial_data(tb_tx_serial),
        .o_TX_data_done(tb_tx_data_done)
    );

    assign tb_rx_serial = tb_tx_active ? tb_tx_serial: 1'b1;

    initial begin
        tb_clk = 0;
        tb_rst = 0;
        tb_start_tx = 1'b0;
        tb_tx_data = 8'h00;

        repeat(5) @(posedge tb_clk);
        tb_rst = 1'b1;

        send_byte(8'hAA);

        #400000;
        $finish;

    end
    


    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0,tb_My_Uart_TX);
    end

endmodule
