/*
simple sequence detector
detecting 1011 with overlapping function
*/

module sequence_detector (

    input logic i_clk,
    input logic i_rst_n, // use reset synchronizer with this reset
    input logic din, // 1 bit serial data in, sequence to detect is 1011

    output logic o_seq_found // flag high for detecting the sequence
);

// using binary to define the states
// should use hot-one bit instead to learn it
typedef enum logic [1:0] {IDLE, S1, S10, S101 } state_t;
state_t state, next_state;


// =====================================================
// always sequential block for next state transition
// =====================================================

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        // reset everything
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


// =====================================================
// always combinational block for next state transition
// just check what din is and go to next state that is relevant.
always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (din == 1'b1) begin
                next_state = S1;
            end else begin
                next_state = IDLE;
            end
        end
        S1: begin
            if (din == 1'b0) begin
                next_state = S10;
            end else begin
                next_state = S1;
            end
        end
        S10: begin
            if (din == 1'b1) begin
                next_state = S101;
            end else begin
                // here din == 0 and then we see 100, so we go to IDLE
                next_state = IDLE;
            end
        end
        S101: begin
            if (din == 1'b1) begin
                // full sequence detected, flag output to go high and go to S1
                next_state = S1;
            end else begin
                // if din is not 1'b1 here, means din == 0, means we got sequence 10 so we go to S10
                next_state = S10;
            end
        end
        default: begin
            next_state = IDLE;
        end
        endcase
end


// =====================================================
// always combinational block for output
//
// here we just output o_seq_found as 1'b0 unless we go to last state
// S101, then if din is 1'b1 we output o_seq_found as high 1'b1 otherwise 1'b0
always_comb begin
    o_seq_found = 1'b0;
    case (state)
        IDLE:       o_seq_found = 1'b0; 
        S1:         o_seq_found = 1'b0; 
        S10:        o_seq_found = 1'b0; 
        S101: begin
            if (din == 1'b1) begin
                o_seq_found = 1'b1;
            end else begin
                o_seq_found = 1'b0;
            end
        end       
        default:    o_seq_found = 1'b0; 
    endcase
end
    

endmodule