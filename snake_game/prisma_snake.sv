`timescale 1ns/1ps

module snake #(
    parameter GRID_WIDTH = 40,
    parameter GRID_HEIGHT = 30
) (
    // --- System Inputs ---
    input logic i_clk,
    input logic i_rst_n,

    // --- Game Control Inputs ---
    input logic i_game_start,
    input logic i_game_tick,
    input logic i_turn_left,
    input logic i_turn_right,

    // --- External State Inputs ---
    input logic [5:0] i_food_pos_x, // The current location of the food
    input logic [4:0] i_food_pos_y,

    // --- Rendering Outputs ---
    // The snake module is now the "source of truth" for the grid.
    input  logic [5:0] i_render_query_x,  // Renderer asks "what's at this X?"
    input  logic [4:0] i_render_query_y,  // Renderer asks "what's at this Y?"
    output logic [1:0] o_cell_type,       // Snake module answers with the cell type.

    // --- Game State Outputs ---
    output logic [5:0] o_snake_head_x,      // Still useful for drawing eyes on the head
    output logic [4:0] o_snake_head_y,
    output logic [10:0] o_snake_length,     // Current length of the snake
    output logic o_request_new_food, // Signal to the food spawner that food was eaten
    output logic o_game_over
);

    // =========================================================================
    //  Type and State Declarations
    // =========================================================================
    typedef enum logic [1:0] { EMPTY, SNAKE_BODY, FOOD } cell_type_t;
    typedef enum logic [1:0] { IDLE, MOVE, COLLISION_STATE } state_t; // Simplified FSM
    typedef enum logic [1:0] { UP, DOWN, LEFT, RIGHT } direction_t;

    state_t state;
    direction_t direction_reg;

    // --- The Game Grid BRAM ---
    (* ram_style = "block" *)
    cell_type_t game_grid [0:GRID_WIDTH-1][0:GRID_HEIGHT-1];

    // --- Snake Position Tracking ---
    logic [5:0] head_x_reg, tail_x_reg;
    logic [4:0] head_y_reg, tail_y_reg;
    logic [10:0] snake_length_reg;
    logic is_growing_flag; // A 1-tick flag to prevent tail erasure

    // =========================================================================
    //  Combinational Logic (The "Thinking" Part)
    // =========================================================================
    
    // 1. Calculate the next head position based on current direction
    logic [5:0] next_head_x;
    logic [4:0] next_head_y;
    always_comb begin
        next_head_x = head_x_reg;
        next_head_y = head_y_reg;
        unique case (direction_reg)
            UP:    next_head_y = head_y_reg + 1;
            DOWN:  next_head_y = head_y_reg - 1;
            LEFT:  next_head_x = head_x_reg - 1;
            RIGHT: next_head_x = head_x_reg + 1;
        endcase
    end

    // 2. Read from the grid to see what's at the next position
    cell_type_t next_cell_type = game_grid[next_head_x][next_head_y];

    // 3. Determine game events based on what we read
    logic is_collision = (next_cell_type == SNAKE_BODY); // Hitting our own body
    logic is_food_eaten = (next_head_x == i_food_pos_x && next_head_y == i_food_pos_y);

    // 4. Output to the renderer (this is the read port for the renderer)
    assign o_cell_type = game_grid[i_render_query_x][i_render_query_y];
    
    // 5. Connect internal state to outputs
    assign o_snake_head_x = head_x_reg;
    assign o_snake_head_y = head_y_reg;
    assign o_snake_length = snake_length_reg;
    assign o_game_over = (state == COLLISION_STATE);
    
    // =========================================================================
    //  Sequential Logic (The "Action" Part)
    // =========================================================================
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            // --- Reset State ---
            state <= IDLE;
            direction_reg <= RIGHT;
            head_x_reg <= 6'd10; // Start in a safe position
            head_y_reg <= 5'd10;
            tail_x_reg <= 6'd10; // Tail starts at the same spot as the head
            tail_y_reg <= 5'd10;
            snake_length_reg <= 11'd1;
            is_growing_flag <= 1'b0;
            o_request_new_food <= 1'b0;

            // Initialize the entire grid to EMPTY
            for (int x = 0; x < GRID_WIDTH; x++) begin
                for (int y = 0; y < GRID_HEIGHT; y++) begin
                    game_grid[x][y] <= EMPTY;
                end
            end
            
        end else begin
            // --- Default Assignments (important to avoid latches) ---
            o_request_new_food <= 1'b0;
            if (is_growing_flag) is_growing_flag <= 1'b0; // Flag is only active for one cycle

            // --- FSM Logic ---
            unique case (state)
                IDLE: begin
                    if (i_game_start) begin
                        // Place the initial snake segment on the grid
                        game_grid[head_x_reg][head_y_reg] <= SNAKE_BODY;
                        state <= MOVE;
                    end
                end

                MOVE: begin
                    // --- Handle Turn Inputs ---
                    if (i_turn_left) begin
                        unique case (direction_reg)
                            UP: direction_reg <= LEFT; DOWN: direction_reg <= RIGHT;
                            LEFT: direction_reg <= DOWN; RIGHT: direction_reg <= UP;
                        endcase
                    end else if (i_turn_right) begin
                        unique case (direction_reg)
                            UP: direction_reg <= RIGHT; DOWN: direction_reg <= LEFT;
                            LEFT: direction_reg <= UP; RIGHT: direction_reg <= DOWN;
                        endcase
                    end

                    // --- Handle Game Tick ---
                    if (i_game_tick) begin
                        // Check for events BEFORE moving
                        if (is_collision) begin
                            state <= COLLISION_STATE;
                        end else begin
                            // It's safe to move, update the head position
                            head_x_reg <= next_head_x;
                            head_y_reg <= next_head_y;

                            // Write the new head position to the grid
                            game_grid[next_head_x][next_head_y] <= SNAKE_BODY;

                            if (is_food_eaten) begin
                                // --- Grow Logic ---
                                is_growing_flag <= 1'b1; // Set flag to prevent tail erasure
                                snake_length_reg <= snake_length_reg + 1;
                                o_request_new_food <= 1'b1; // Tell food spawner to make new food
                            end else begin
                                // --- Move Logic (No Growth) ---
                                // Erase the old tail from the grid
                                game_grid[tail_x_reg][tail_y_reg] <= EMPTY;
                                
                                // To find the new tail, we need to know where the old tail's
                                // "next" segment was. This is tricky! For now, let's assume
                                // you have a way to find it. The simplest way is a FIFO/queue.
                                // For this example, let's simplify and assume we can calculate it.
                                // (This is where a FIFO of body segments would be ideal).
                                // This part needs a proper tail-following implementation.
                                // Let's leave it as a placeholder for the next step.
                                // tail_x_reg <= new_tail_x;
                                // tail_y_reg <= new_tail_y;
                            end
                        end
                    end
                end

                COLLISION_STATE: begin
                    // Game is over. Wait for reset.
                    if (i_game_start == 0) begin // A way to exit the game over screen
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule