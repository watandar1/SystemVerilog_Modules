/*
testbench for par_prio_encoder module
2026-07-10

*/

`timescale 1ns/1ps

module tb_par_prio_encoder;

    parameter WIDTH = 8;

    logic [WIDTH-1:0]       data_in;
    logic                   valid;
    logic [$clog2(WIDTH)-1:0] idx;
    logic [WIDTH-1:0]       grant;

    // Instantiate DUT
    par_prio_encoder #(.WIDTH(WIDTH)) dut (
        .data_in(data_in),
        .valid(valid),
        .idx(idx),
        .grant(grant)
    );

    initial begin
        $display("=== Priority Encoder Testbench ===");
        $display("data_in  | valid | idx | grant");
        $display("---------+-------+-----+--------");

        // Test 1: No bits set
        data_in = 8'b0000_0000;
        #10;
        $display("%b |   %0b   |  %0d  | %b", data_in, valid, idx, grant);

        // Test 2: Single bit set (LSB)
        data_in = 8'b0000_0001;
        #10;
        $display("%b |   %0b   |  %0d  | %b", data_in, valid, idx, grant);

        // Test 3: Single bit set (MSB)
        data_in = 8'b1000_0000;
        #10;
        $display("%b |   %0b   |  %0d  | %b", data_in, valid, idx, grant);

        // Test 4: Multiple bits — should pick highest index
        data_in = 8'b0010_1010;
        #10;
        $display("%b |   %0b   |  %0d  | %b", data_in, valid, idx, grant);

        // Test 5: All bits set — should pick index 7
        data_in = 8'b1111_1111;
        #10;
        $display("%b |   %0b   |  %0d  | %b", data_in, valid, idx, grant);

        // Test 6: Only bit 4
        data_in = 8'b0001_0000;
        #10;
        $display("%b |   %0b   |  %0d  | %b", data_in, valid, idx, grant);

        // Test 7: Sweep through all single-bit patterns
        $display("\n--- Single-bit sweep ---");
        for (int i = 0; i < WIDTH; i++) begin
            data_in = WIDTH'(1) << i;
            #10;
            if (idx != i[$clog2(WIDTH)-1:0] || grant != data_in || !valid)
                $display("FAIL: data_in=%b idx=%0d (expected %0d)", data_in, idx, i);
            else
                $display("PASS: data_in=%b idx=%0d grant=%b", data_in, idx, grant);
        end

        $display("\n=== Done ===");
        $finish;
    end


    // Dump waveforms, observe using GTKWave
    initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, tb_par_prio_encoder);
    end

endmodule