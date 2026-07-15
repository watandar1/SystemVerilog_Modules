/*
writing par_shift_register.sv for mock interview
*/

module par_shift_register #(
    parameter WIDTH = 8
) (
    input logic clk,
    input logic i_rst_n, //async active low reset
    input logic serial_in,

    output logic serial_out,
    output logic [WIDTH-1:0] parallel_out

);

always_ff @(posedge clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        parallel_out <= '0;
    end else begin
        // shift register Shift syntax is wrong error 1
        //  parallel_out <= {serial_in, [WIDTH-1:0]};  // ← not valid syntax
        // You meant to shift the existing register and bring in the new bit. For a left shift (MSB out):
        parallel_out <= {parallel_out[WIDTH-2:0], serial_in};
    end
end

//error 2: did not assign serial out,serial_out never assigned in the else branch:
//You only assign it during reset. In normal operation, it should continuously output the MSB that's being shifted out:
assign serial_out = parallel_out[WIDTH-1];

    
endmodule
