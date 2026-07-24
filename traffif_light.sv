/*

*/

module traffif_light #(
    // global parameterized light cycles for each state
    parameter RED_CYCLE = 8
    parameter GREEN_CYCLE = 10  // green has highest since green was 1 cycle longer than others in requirement
    parameter YELLOW_CYCLE = 6
) (
    input logic i_clk,      //clock input
    input logic i_rst_n,    // asynchronous reset

    output logic [1:0] o_light    //output logic state
);

// =====================================================
// declare MOORE FSM state encoding
typedef enum logic [1:0] {RED, GREEN, YELLOW  } state_t;
state_t state, next_state;

// declare counter for counting the cycles in each state
logic [$clog2(GREEN_CYCLE)-1:0] counter; // counter with WIDTH from highest state cycle


// =====================================================
// use 3 always block rule

// =====================================================
// always sequential block for next state transition
// =====================================================

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        //reset everything so initialize starts safely
        state <= RED;
        counter <= '0;
    end else begin
        // trigger state if condition
        if (state == next_state) begin
            // state is equal to next state so we stay at current state
            counter <= counter + 1;
            state <= state;
        end else begin
            counter <= '0;
            // state is different from next state, state gets next state
            state <= next_state;
        end
    end
end
// =====================================================



// =====================================================
// always combinational block for next state transition
// =====================================================
always_comb begin
    next_state = state;
    case (state)
        RED:begin
            if (counter == RED_CYCLE-1) begin
                next_state = GREEN;
            end
        end
        GREEN:begin
            if (counter == GREEN_CYCLE-1) begin
                next_state = YELLOW;
            end
        end
        YELLOW:begin
            if (counter == YELLOW_CYCLE-1) begin
                next_state = RED;
            end
        end
        default: begin
            next_state = RED;
        end
    endcase
end
// =====================================================


// =====================================================
// always combinational block for output
// =====================================================
always_comb begin
    o_light = '0;
    case (state)
        RED: o_light = RED;
        GREEN: o_light = GREEN;
        YELLOW: o_light = YELLOW;        
        default: o_light = RED;
    endcase
end
// =====================================================

endmodule
