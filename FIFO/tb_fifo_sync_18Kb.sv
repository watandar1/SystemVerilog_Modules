/*
2026-06-18:
    testbench for synchronous FIFO fifo_sync_18Kb

*/

`timescale 1ns/1ps
module tb_fifo_sync_18Kb;


    localparam DATA_WIDTH = 18;
    localparam FIFO_DEPTH = 4;


    logic tb_clk;
    logic tb_rst_n;
    logic tb_wr_en;
    logic tb_rd_en;
    logic [DATA_WIDTH-1:0] tb_data_in;
    logic [DATA_WIDTH-1:0] tb_data_out;
    logic tb_full;
    logic tb_empty;
    logic [DATA_WIDTH-1:0] tb_random_number;


    // Instantiate the FIFO DUT
    fifo_sync_18Kb #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)

    )   DUT (
        .clk(tb_clk),
        .rst_n(tb_rst_n),
        .wr_en(tb_wr_en),
        .rd_en(tb_rd_en),
        .data_in(tb_data_in),
        .data_out(tb_data_out),
        .full(tb_full),
        .empty(tb_empty)
    );

    // Instanstiate LSFR to generate random data for testing
    my_LFSR #(
        .WIDTH(DATA_WIDTH)
    ) uut (
        .clk(tb_clk),
        .rst_n(tb_rst_n),
        .random_number(tb_random_number)
    );

    // Clock generation
    initial begin
        tb_clk = 0;
        forever #5 tb_clk = ~tb_clk; // 100 MHz clock
    end

    // task to write data into the FIFO
    task write_to_fifo (
        input logic [DATA_WIDTH-1:0] data
        ); begin
            @(negedge tb_clk); // wait for negative edge of clock
            tb_data_in = data; // set data input
            $display("Writing data: %h", data);
            tb_wr_en = 1; // enable write
            @(negedge tb_clk); // wait for next negative edge of clock
            tb_wr_en = 0; // disable write
        end
    endtask

    // task to read data from the FIFO
    task read_from_fifo(
        output logic [DATA_WIDTH-1:0] data
        ); begin
            @(negedge tb_clk); // wait for negative edge of clock
            tb_rd_en = 1; // enable read
            @(negedge tb_clk); // wait for next negative edge of clock
            data = tb_data_out; // capture data output
            $display("Read data: %h", data);
            $display("FIFO empty flag: %b", tb_empty);
            tb_rd_en = 0; // disable read
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        tb_rst_n = 0;
        tb_wr_en = 0;
        tb_rd_en = 0;
        tb_data_in = 0;

        // Apply reset
        #20;
        tb_rst_n = 1;

        #100; // Wait for some time after reset

        // write task, 4 address slot write 4 times to make the FIFO full
        write_to_fifo(tb_random_number); // write random data to FIFO
        #20; // wait for some time
        write_to_fifo(tb_random_number); // write random data to FIFO
        #20; // wait for some time
        
        write_to_fifo(tb_random_number); // write random data to FIFO
        #20; // wait for some time
        
        write_to_fifo(tb_random_number); // write random data to FIFO
        #20; // wait for some time
        

        // read task
        read_from_fifo(tb_data_out); // read data from FIFO
        #20; // wait for some time

        read_from_fifo(tb_data_out); // read data from FIFO
        #20; // wait for some time

        read_from_fifo(tb_data_out); // read data from FIFO
        #20; // wait for some time
        
        read_from_fifo(tb_data_out); // read data from FIFO
        #20; // wait for some time
        
        // try to read more than available slots
        read_from_fifo(tb_data_out); // read data from FIFO
        #20; // wait for some time
        
        read_from_fifo(tb_data_out); // read data from FIFO
        #20; // wait for some time

        // write again, so see its really circular, 
        write_to_fifo(tb_random_number); // write random data to FIFO
        #20; // wait for some time


        #10000;
        $finish; // End simulation
    end 

    // Dump waveforms, observe using GTKWave
    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_fifo_sync_18Kb);
    end

endmodule
