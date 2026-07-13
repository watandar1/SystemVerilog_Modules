/*
paramiterized prio encoder

*/

`timescale 1ns/1ps
module par_prio_encoder #(
    parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] data_in,

    output logic valid, 
    output logic [$clog2(WIDTH)-1:0] idx,
    output logic [WIDTH-1:0] grant
);

always_comb begin
    // set things to zero so no latches occur
    idx = '0;
    valid = 1'b0;
    grant = '0;
    
    for (int i = 0; i < WIDTH; i++) begin
        if (data_in[i]) begin
            idx = i[$clog2(WIDTH)-1:0];
            valid = 1'b1;

        end
    end

    if(valid) begin
        grant = WIDTH'(1'b1) << idx;
    end


end
endmodule
