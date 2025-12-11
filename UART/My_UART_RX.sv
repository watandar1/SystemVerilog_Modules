/*
Uart RX, no parity bit, baud rate 115200, sysyem clock is 100MHZ
    AS OF 2025-09-20 22:40
    THIS MODULE WORKS FINE!

*/

`timescale 1ns/1ps
module My_UART_RX #(
    parameter CLKS_PER_BIT = 868
) (
    input logic i_clk,
    input logic i_serial_data,
    output logic o_rx_busy,
    output logic o_rx_data_valid,
    output logic [7:0] o_rx_data
);

typedef enum logic [1:0] {IDLE, START, BITS, STOP } state_t;
state_t state;

//Declare counters
logic [$clog2(CLKS_PER_BIT)-1:0] clock_counter;
logic [2:0] bit_index;

//register
logic [7:0] r_rx_data; // reg to store 8 bit data

always_ff @(posedge i_clk) begin        
    
    unique case (state)
    //IDLE state wait for the 
    IDLE: begin
        clock_counter <= 0;
        bit_index <= 0;
        o_rx_busy <= 0;
        o_rx_data_valid <= 0;
        
        if (i_serial_data == 1'b0) begin
            state <= START;
        end else begin
            state <= IDLE;
        end
    end
    
    START: begin
        o_rx_busy <= 1'b1;
        // if we are in the middle of start bit
        if (clock_counter == (CLKS_PER_BIT/2 - 1)) begin
            // if serial data stream line is still 0
            if (i_serial_data == 1'b0) begin
                state <= BITS;
                clock_counter <= 0;
            end else begin
                state <=  IDLE;
            end
        end else begin
            clock_counter <= clock_counter + 1;
            state <= START;
        end

    end
    BITS: begin
        o_rx_busy <= 1'b1;
        // are we in th middle of a bit
        if (clock_counter == (CLKS_PER_BIT-1)) begin
            
            r_rx_data[bit_index] <= i_serial_data;  //sample the bit
            //are the at the end of the bits
            if (bit_index < 7) begin
                bit_index <= bit_index + 1; //increment the bit index
                clock_counter <= 0;         //reset counter
                state <= BITS;              // go to BITS state
            end else begin
                bit_index <= 0;
                clock_counter <= 0;
                state <= STOP;
            end
        end else begin
            clock_counter <= clock_counter + 1;
            state <= BITS;
        end

    end
    STOP: begin
        o_rx_busy <= 1'b1; 

        if (clock_counter == (CLKS_PER_BIT -1)) begin
            if (i_serial_data == 1'b1) begin
                clock_counter <= 0;
                o_rx_data_valid <= 1'b1;
                o_rx_data <= r_rx_data;
                state <= IDLE;
            end else begin
                clock_counter <= 0;
                o_rx_data_valid <= 1'b0;
                state <= IDLE;
            end
        end else begin
            clock_counter <= clock_counter + 1;
            state <= STOP;
        end

    end
    default: begin
        state <= IDLE;
    end
    endcase
end
    
endmodule
