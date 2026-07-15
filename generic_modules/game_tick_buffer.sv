/*
game tick buffer to be used in snake game
we need to align the button press with the game tick logic 
so the game can register/remember/understand that the button was pressed
*/


module game_tick_buffer (
    input logic i_clk,
    input logic i_rst_n,
    input logic i_debounced_btn, 
    input logic i_game_tick,     
    
    output logic o_action_req  
);

    // 1. Edge Detection Logic
    logic btn_prev;
    logic btn_pulse;

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            btn_prev <= 1'b0;
        end else begin
            btn_prev <= i_debounced_btn; 
        end
    end

    assign btn_pulse = i_debounced_btn & ~btn_prev;


    // 2. Sticky Register (Input Buffer)
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_action_req <= 1'b0;
        end else if (btn_pulse) begin
            o_action_req <= 1'b1; // Button pressed! Remember it. For the game tick
        end else if (i_game_tick) begin
            o_action_req <= 1'b0; // Game tick happened! Clear the memory.
        end
    end

endmodule