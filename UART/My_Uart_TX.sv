/*
uart transmitt module without parity bit, baud rate = 115200, system clock is 100MHz
    AS OF 2025-09-20 22:40
    THIS MODULE WORKS FINE!

*/
`timescale 1ns/1ps

module My_Uart_TX #(
    parameter CLKS_PER_BIT = 868 //100MHz clock, baud rate 115200
) (
    input logic i_clk,
    input logic i_rst, 
    input logic [7:0] i_Tx_data_in,     // 8 bit data to push into the stream
    input logic i_TX_data_start,

    output logic o_TX_data_active,      // tx is busy?
    output logic o_Tx_serial_data,      // the stream line data
    output logic o_TX_data_done         //tx is busy
   
);

typedef enum logic [1:0] {IDLE, START, BITS, STOP} state_t;
state_t state;

//Declare counters
logic [$clog2(CLKS_PER_BIT)-1:0] clock_counter;
logic [2:0] bit_index;

logic [7:0 ]r_tx_data;

always_ff @(posedge i_clk or negedge i_rst) begin
    
    if (!i_rst) begin
        state <= IDLE;
        clock_counter <= 0;
        bit_index <= 0;
        r_tx_data <= 0;
        o_Tx_serial_data  <= 1'b1;
        o_TX_data_active  <= 1'b0;
        o_TX_data_done    <= 1'b0;
    end else begin

        unique case (state)
        //IDLE state, just wait for signal to send
        IDLE: begin
            clock_counter <= 0;
            bit_index <= 0;
            o_Tx_serial_data <= 1'b1; // Drive the bit stream serial data high 
            o_TX_data_active <= 1'b0;
            o_TX_data_done <= 1'b0;  // drive the data busy low, indicating the module is free

            if (i_TX_data_start == 1'b1) begin
                o_TX_data_active <= 1'b1;
                r_tx_data <= i_Tx_data_in;
                state <= START;
            end else begin
                state <= IDLE;
            end
            end
        // Start state. here according to timing the serial data stream should go low for one bit
        // so the code below should drive the serial data low for one bit clock cycle 
        START: begin

            o_Tx_serial_data <= 1'b0; //Drive the serial data stream low

            if (clock_counter == (CLKS_PER_BIT - 1)) begin
                clock_counter <= 0;
                state <= BITS;
            end else begin
                clock_counter <= clock_counter + 1;
                state <= START;
            end
            
        end

        // bit state, here drive the serial stream low or high depending on what the data in is
        BITS: begin
            
            if (clock_counter == (CLKS_PER_BIT - 1)) begin
                // Completed a full bit period
                if (bit_index == 7) begin // check if the last bit was just sent
                    bit_index <= 0;
                    clock_counter <= 0;
                    state <= STOP;
                end else begin
                    bit_index <= bit_index + 1;
                    clock_counter <= 0;
                    state <= BITS;
                end
            end else begin
                clock_counter <= clock_counter + 1;
                state <= BITS;
            end
        o_Tx_serial_data <= r_tx_data[bit_index];

                
        end

        //STOP state, drive the serial data line high for one bit period and its over :D
        STOP: begin
            o_Tx_serial_data <= 1'b1; //drive the serial high
            if (clock_counter < (CLKS_PER_BIT - 1)) begin
                clock_counter <= clock_counter + 1;
                state <= STOP;
            end else begin
                o_TX_data_done <= 1'b1;
                o_TX_data_active <= 1'b0;
                clock_counter <= 0;
                
                state <= IDLE;
            end
        end
        default: begin
                state <= IDLE;
        end
        endcase
    end
end

endmodule
