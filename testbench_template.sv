/*
template for testbench for any systemverilog module
should be used for functionality testing


*/

`timescale 1ns/1ps
//change the testbench name
module tb_NAME_OF_MODULE;

//=================================================================
// declare the parameter if needed
localparam GENERIC_PARAMETER = 16;


//=================================================================
// declare wires and registers
logic tb_clk;
logic tb_rst_n;



//=================================================================
// instantiate other modules needed for this testbench



//=================================================================
// instantiate the DUT



//=================================================================
// define the clock
// 100 MHz clock
initial begin
    tb_clk = 0;
    forever #5 tb_clk = ~tb_clk;
end

//=================================================================
// Define tasks to be used in testbench

// generic task 1
task generic_input_task(
    //declare input
    input logic i_input
); begin
    //Do something with the input
end
endtask

// generic task 2
task generic_output_task(
    output logic o_output
); begin
    //Do something with the output
end
    
endtask

// always block triggering on rising edge of arbitrary logic
always @(posedge /*ENTER DESIRED POSEDGE TRIGGER*/) begin
    $display("[%0t ns] X = %d, Y = %d", $time, /*variable X*/, /*variable Y*/);
    // POSEDGE TRIGGER
    // DO SOMETHING

end


//=================================================================
// here is the testbench body, use display and tasks

initial begin
    $display("====== name of testbench, TITLE");
    $display("================================");




    //declare desired amout of time for simulation
    // timeunit is 1ns, and precision is 1ps
    #1000
    $display("\n=== Done ===");
    $finish;
end


//=================================================================
// Dump waveforms, observe using GTKWave
initial begin
        $dumpfile("Waveform.vcd");
        $dumpvars(0, /*INSERT TESTBENCH NAME HERE*/ );
end
    
endmodule