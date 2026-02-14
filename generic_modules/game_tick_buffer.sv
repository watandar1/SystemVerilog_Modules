


module game_tick_buffer (
    input logic i_clk,
    input logic i_rst_n,
    input logic i_debounced_btn, // From your debounce_btn module
    input logic i_game_tick,     // From your game_tick module
    
    output logic o_action_req    // Goes to your snake FSM (e.g., i_turn_left)
);

    // 1. Edge Detection Logic
    logic btn_prev;
    logic btn_pulse;

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            btn_prev <= 1'b0;
        end else begin
            btn_prev <= i_debounced_btn; // Remember the state from the last clock cycle
        end
    end

    // Pulse is high ONLY for 1 clock cycle when the button goes from 0 to 1
    assign btn_pulse = i_debounced_btn & ~btn_prev;


    // 2. Sticky Register (Input Buffer)
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_action_req <= 1'b0;
        end else if (btn_pulse) begin
            o_action_req <= 1'b1; // Button pressed! Remember it.
        end else if (i_game_tick) begin
            o_action_req <= 1'b0; // Game tick happened! Clear the memory.
        end
    end

endmodule