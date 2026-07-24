/*
parameterized and reuseable RTL code for multiplexer, NUM_INPUTS and DATA_width

*/
// below was my attempt
module par_mux #(
    parameter NUM_INPUTS = 4,
    parameter DATA_WIDTH = 2,
) (
    input logic i_clk, // clock not needed, mux is combinational
    input logic i_rst_n, // dont think I need reset here

    // what was I thinking here, the i_serial_inputs are exactly like i_select,
    input logic [$clog2(NUM_INPUTS)-1:0] i_serial_inputs,
    
    input logic [$clog2(NUM_INPUTS)-1:0] i_select,

    output logic [DATA_WIDTH-1:0] o_dataOut
);

always_comb begin
    
    o_dataOut = '0; // to avoid uninteded latch

    // usually I make MUX with case statements, but this time since the inputs and select are parameterized case doesnt work
    // some type of for loop should work here
    for (i = 0 ; i<NUM_INPUTS ;i++ ) begin
        if(select[i]) begin
            o_dataOut[i] = i_serial_inputs[i];
        end
    end
end

    
endmodule

// actual answer is alot simpler than I thought
module par_mux #(
    parameter NUM_INPUTS = 4,
    parameter DATA_WIDTH = 8
) (
    // array indexing, !!! very important, I have not used this alot before, should use it more often
    input  logic [DATA_WIDTH-1:0]           i_data [NUM_INPUTS],
    input  logic [$clog2(NUM_INPUTS)-1:0]   i_select,
    output logic [DATA_WIDTH-1:0]           o_data_out
);
/*
Key takeaways:
Unpacked arrays (i_data [NUM_INPUTS]) are synthesizable and very useful for parameterized designs.
When you're stuck on parameterized logic, think about array indexing before loops — it's often cleaner and more synthesis-friendly.
*/
    assign o_data_out = i_data[i_select];

endmodule
