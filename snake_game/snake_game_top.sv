`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 17:44:57
// Design Name: 
// Module Name: snake_game_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module snake_game_top(

    input logic clk,                // 100 MHz clock
    input logic btn0,               // reset function
    
    input logic btn2,               // left
    input logic btn1,               // right
    
    input logic btn3,               // game start
    
    //ARTY Uart pins    
    
    //VGA
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_B,
    output logic [3:0] VGA_G,
    output logic VGA_HS_O,
    output logic VGA_VS_O
    
    );
    
    //baud rate 115200 clock 25MHz for uart
    localparam CLKS_PER_BITS = 217;
    // 4-bit RGB
    localparam VIDEO_WIDTH = 4; 
    // vga 640X480 @60 hz Timing spec     
    localparam HSYNC_WIDTH = 800;
    localparam VSYNC_WIDTH = 525;
    localparam HSYNC_ACTIVE = 640;
    localparam VSYNC_ACTIVE = 480;
    localparam HSYNC_FRONT = 16;
    localparam VSYNC_FRONT = 10;
    localparam HSYNC_BACK = 48;
    localparam VSYNC_BACK = 33;
    
    
    logic clk_25MHz;
    logic locked;
    logic left;
    logic right;
    logic game_start;
    
    // Instantiating the clock wizard IP
    clk_wiz_0 clock (
    .clk_out1(clk_25MHz),
    .resetn(~btn0),
    .locked(locked),
    .clk_in1(clk)
    );
    
    debounce_btn debounce_left (
    .i_clk(clk_25MHz),
    .i_rst_n(locked),
    .i_btn(btn2),
    .o_debounced(left)
    );
    logic left_buff;
    game_tick_buffer left_buffer (
    .i_clk(clk_25MHz),
    .i_rst_n(locked),
    .i_debounced_btn(left),
    .i_game_tick(game_tick),
    .o_action_req(left_buff)
    );
    
    
    
    debounce_btn game_start_debounce (
    .i_clk(clk_25MHz),
    .i_rst_n(locked),
    .i_btn(btn3),
    .o_debounced(game_start)
    );
    
    debounce_btn debounce_right (
    .i_clk(clk_25MHz),
    .i_rst_n(locked),
    .i_btn(btn1),
    .o_debounced(right)
    );
    logic right_buff;
    game_tick_buffer right_buffer (
    .i_clk(clk_25MHz),
    .i_rst_n(locked),
    .i_debounced_btn(right),
    .i_game_tick(game_tick),
    .o_action_req(right_buff)
    );
    
    logic w_hsync_active;
    logic w_vsync_active;
    
    logic w_hsync_puls;
    logic w_vsync_puls;
    
    // horizontal and vertical position
    //logic h_pos;
    //logic v_pos;
    logic [$clog2(HSYNC_WIDTH)-1:0] h_pos;           //dynamic counter will be able to count to HSYNC_WIDTH         
    logic [$clog2(VSYNC_WIDTH)-1:0] v_pos;
    
    logic o_w_frame_reset; // high for when frame is reset i.e. new frame starts use this for generating movement
    
    //VGA signals
 
    logic [VIDEO_WIDTH-1:0] w_Red_Video_TP;
    logic [VIDEO_WIDTH-1:0] w_Grn_Video_TP;
    logic [VIDEO_WIDTH-1:0] w_Blu_Video_TP;
    
    my_VGA_active_pulse_Gen #(
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),
        .VSYNC_ACTIVE(VSYNC_ACTIVE)
    ) vga_active_pulse_tb (
        .i_clk(clk_25MHz),
        .i_rst_n(locked),
        .o_hsync_active(w_hsync_active),
        .o_vsync_active(w_vsync_active),
        .o_w_frame_reset(o_w_frame_reset),
        .o_hsync_frame_pos(h_pos),
        .o_vsync_frame_pos(v_pos)
    );
    
    my_VGA_sync_pulse_gen #(
        .VIDEO_WIDTH(VIDEO_WIDTH),
        .HSYNC_WIDTH(HSYNC_WIDTH),
        .VSYNC_WIDTH(VSYNC_WIDTH),
        .HSYNC_ACTIVE(HSYNC_ACTIVE), 
        .VSYNC_ACTIVE(VSYNC_ACTIVE), 
        .HSYNC_FRONT(HSYNC_FRONT), 
        .VSYNC_FRONT(VSYNC_FRONT), 
        .HSYNC_BACK(HSYNC_BACK), 
        .VSYNC_BACK(VSYNC_BACK) 

    ) my_VGA_sync_pulse_gen (
        .i_clk(clk_25MHz),
        .i_rst_n(locked),
        .i_active_hsync(w_hsync_active),
        .i_active_vsync(w_vsync_active),
        .o_hsync_pulse(w_hsync_puls),
        .o_vsync_pulse(w_vsync_puls)
 
    );  
    
    assign VGA_HS_O = w_hsync_puls;
    assign VGA_VS_O = w_vsync_puls;
    
    //40x30 grid gen
    logic [$clog2(40)-1:0] grid_col_x;
    logic [$clog2(30)-1:0] grid_row_y; 
    pixel_grid_gen #(
        .PIXEL_GRID_H(16),
        .PIXEL_GRID_V(16),
        .HSYNC_ACTIVE(HSYNC_ACTIVE),    
        .VSYNC_ACTIVE(VSYNC_ACTIVE)
    ) pixel_grid (
        .i_hsync_pos(h_pos),
        .i_vsync_pos(v_pos),
        .o_grid_col(grid_col_x), // x grid position
        .o_grid_row(grid_row_y)  // y grid position 
    );
    logic game_tick;
    // Instantiate game tick module
    game_tick #(
        .FRAMES_PER_TICK(5)
    ) game_tick_inst (
        .i_clk(clk_25MHz),
        .i_rst_n(locked),
        .frame_start(o_w_frame_reset),
        .o_game_tick(game_tick)
    );
    
    logic food_consumed;
    logic food_place_ok = 1'b1;
    
    logic [5:0] food_x; // 40
    logic [4:0] food_y; // 30
    
    logic spawn_food;
    
    // Instantiate food spawn module
    food food_inst (
        .i_clk(clk_25MHz),
        .i_rst_n(locked),
        .i_food_consumed(food_consumed),
        .i_food_place_ok(food_place_ok),
        .i_game_tick(game_tick),
        .i_game_start(game_start),
        .o_food_x(food_x),
        .o_food_y(food_y),
        .o_spawn_food(spawn_food)
    );
    
    logic collision;
    logic [5:0] snake_head_x;
    logic [4:0] snake_head_y;
    logic [10:0] snake_length;
    logic [5:0] snake_body_x [110:0];
    logic [4:0] snake_body_y [110:0];
    
    snake snake_inst(
        .i_clk(clk_25MHz),
        .i_rst_n(locked),
        .i_game_start(game_start),
        .i_game_tick(game_tick),
        .i_food_eaten(food_consumed), // connect food consumed signal to the snake module
        .i_collision(collision), // for now, we can tie collision signal to 0, we will test collision later
        .i_turn_left(left_buff), // for now, we can tie turn signals to 0, we will test turning later
        .i_turn_right(right_buff),
        .o_snake_body_x(snake_body_x), // we can leave these unconnected for now, we will test the snake's movement later
        .o_snake_body_y(snake_body_y),
        .o_snake_head_x(snake_head_x),
        .o_snake_head_y(snake_head_y),
        .o_snake_length(snake_length), // we can leave this unconnected for now, we will test the snake's length later
        .o_game_over()
    );
    
    logic video_on;
    assign video_on = w_hsync_active && w_vsync_active;
    
    render_game render_game_inst(
    .i_clk(clk_25MHz),
    .i_rst_n(locked),
    .i_game_tick(game_tick),
    .i_game_start(game_start),
    .i_grid_col_x(grid_col_x),
    .i_grid_row_y(grid_row_y),
    .i_video_on(video_on),
    .i_snake_body_x(snake_body_x),
    .i_snake_body_y(snake_body_y),
    .i_snake_head_x(snake_head_x),
    .i_snake_head_y(snake_head_y),
    .i_snake_length(snake_length),
    .i_food_x(food_x),
    .i_food_y(food_y),
    .o_vga_red(VGA_R),
    .o_vga_green(VGA_G),
    .o_vga_blue(VGA_B),
    .o_snake_collision(collision),
    .o_food_consumed(food_consumed),
    .o_food_place_ok(food_place_ok)
    );
    
   
    
    
    // Check if we're in grid cell (1,1)
    /*
    logic apple;
    assign apple = (grid_col_x == food_x) && (grid_row_y == food_y);

    // Drive RGB signals
    assign VGA_R = video_on ? (apple ? 4'hf : 4'hf) : 4'h0;
    assign VGA_G = video_on ? (apple ? 4'h0 : 4'hf) : 4'h0;
    assign VGA_B = video_on ? (apple ? 4'h0 : 4'hf) : 4'h0;
    */
    
    /*
    // --- Object Detection Signals ---
logic is_apple;
logic is_head;
logic is_body;

// 1. Check if current grid matches the Apple
assign is_apple = (grid_col_x == food_x) && (grid_row_y == food_y);

// 2. Check if current grid matches the Snake Head
assign is_head  = (grid_col_x == snake_head_x) && (grid_row_y == snake_head_y);

// 3. Check if current grid matches ANY part of the Snake Body
always_comb begin
    is_body = 1'b0; // Default to 0
    // Loop through the maximum possible body size
    for (int i = 0; i < 1200; i++) begin
        // Only check segments that actually exist based on current length
        if (i < snake_length) begin
            if ((grid_col_x == o_snake_body_x[i]) && (grid_row_y == o_snake_body_y[i])) begin
                is_body = 1'b1;
            end
        end
    end
end

// --- VGA RGB Color Driver ---
// We use if/else to create priority: Head > Body > Apple > Background
always_comb begin
    if (!video_on) begin
        // ALWAYS output 0 during the blanking interval to prevent monitor issues
        {VGA_R, VGA_G, VGA_B} = 12'h000; 
    end else if (is_head) begin
        {VGA_R, VGA_G, VGA_B} = 12'h0_F_0; // Head: Bright Green
    end else if (is_body) begin
        {VGA_R, VGA_G, VGA_B} = 12'h0_8_0; // Body: Dark Green
    end else if (is_apple) begin
        {VGA_R, VGA_G, VGA_B} = 12'hF_0_0; // Apple: Red
    end else begin
        {VGA_R, VGA_G, VGA_B} = 12'h1_1_1; // Background: Dark Gray
    end
end
*/
    
endmodule
