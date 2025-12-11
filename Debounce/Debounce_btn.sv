/*
debounce state machine for mechanical buttons

*/

module debounce_btn #(
    // debounce time limit, the limit the counter can count to, for 100MHz clk, 500000 = 5ms
    parameter c_DEBOUNCE_LIMIT = 500000
)(
    input logic i_clk,
    input logic i_rst, 
    input logic i_btn,
    output logic o_led
);

  
    // debounce time limit, the limit the counter can count to
 
    /*
    need to create a counter to count, there is 100MHz clock so the period is T = 1/f = 10 ns
    but what should the counter for the debounce be? 5ms? 10ns? :/ hmmmm
    lets calculate, first 5ms/10ns = 500 000, hmmm so we need a counter that can count to 500 000, -> 2^19 = 524 288 => a 19bit counter works
    */
    
    logic state_debounce = 1'b0; //initialize the state
    logic [18:0] counter_debounce = 0; // 19bit counter 2^19 = 524 288, we want a roughly 5ms debounce timer
    

always_ff @(posedge i_clk) begin

    if (i_rst) begin
        state_debounce <= 1'b0;
        counter_debounce <= 0;
    end else begin

        if (i_btn != state_debounce && counter_debounce < c_DEBOUNCE_LIMIT) begin
            counter_debounce <= counter_debounce + 1;
        end else if(counter_debounce == c_DEBOUNCE_LIMIT) begin
            counter_debounce <= 0;
            state_debounce <= i_btn;
        end
        else begin
            counter_debounce <=0;
        end
    end
end

assign o_led = state_debounce;

endmodule

