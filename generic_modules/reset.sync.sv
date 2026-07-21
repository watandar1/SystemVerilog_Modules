/*
a reset sync module.
This is a reset synchronizer module
basically synchronized reset with given clock

*/

module reset_sync (
    input logic i_clk,
    input logic i_async_reset_n,    // raw asynchronous reset, active low reset. this is what is used normally
    output logic o_sync_reset       // sync reset with active low reset.
);

logic rst_meta; // simple register// D_FF for reset holder

always_ff @(posedge i_clk or negedge i_async_reset_n) begin
    if (!i_async_reset_n) begin
        rst_meta <= 1'b0;
        o_sync_reset <= 1'b0;
    end else begin
        rst_meta <= 1'b1;
        o_sync_reset <= rst_meta;
    end
    
end

/*
2027-07-20, comments for code above, explaining what it does:
// should do testbenc with verilator and obersve waveform with GTKWave

The above always_ff block has output o_sync_reset.
this output is the reset that will be used for other modules. 
its a synchronized active low reset. 
when reset is pressed, the sequential block is triggered,
then the if condition is triggered
then rst_meta gets assigned 0 and o_sync_reset also gets assigned 0.
on the next clock posedge trigger, the if condition is not triggered.
the else part is triggered, o_sync_reset gets assigned rst_meta, which is still 0, since last
at same time here rst_meta gets assigned 1'b1.
on next clock trigger, the else part is triggered and o_sync_reset gets assigned rst_meta which is high and rst_meta is assigned high.

what happened above is our output reset is assigned 0 for at least 2 whole clock triggers
this allows us to use the output reset signal o_sync_reset as follows:

always_ff(posedge clk, negedge o_sync_reset) begin
    if (!o_sync_reset) begin
        //reset stuff, treat this as normal async reset
    end else begin
        // else of your code
    end
end


*/
    
endmodule