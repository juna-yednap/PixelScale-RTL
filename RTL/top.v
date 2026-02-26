
`timescale 1ns / 1ps

// Top-level module for image transformation pipeline
module top #(
    parameter H_in    = 2,   // Input image height
    parameter W_in    = 2,   // Input image width
    parameter H_out   = 4,   // Output image height
    parameter W_out   = 4,   // Output image width
    parameter CHANNEL = 1    // Number of channels (e.g., RGB=3)
) (
    input  clk,              // System clock
    input  rst,              // System reset
    output complete          // High when processing is complete
);

// Internal parameter definitions for bit widths and precision
parameter x_bit_in  = $clog2(W_in) + 1;   // Bits for input X coordinate
parameter y_bit_in  = $clog2(H_in) + 1;   // Bits for input Y coordinate
parameter x_bit_out = $clog2(W_out) + 1;  // Bits for output X coordinate
parameter y_bit_out = $clog2(H_out) + 1;  // Bits for output Y coordinate
parameter precision = 8;                  // Fractional precision for fixed-point

// State machine states
parameter DIV = 2'b01; // Division state: calculate scaling ratios
parameter MAP = 2'b10; // Mapping state: process output pixels
reg [1:0] state, next_state; // FSM state registers
reg [1:0] counter;           // Channel counter
reg [1:0] counter1;          // Sub-pixel/step counter

// Control signals
wire en1, en2; // Division done signals

// Output result memory
reg [7:0] res [0:W_out * H_out * CHANNEL - 1]; // Output pixel buffer
reg com, start; // Completion and start flags

// Division results (scaling ratios)
wire [precision + x_bit_in - 1:0] r_W; // W_in / W_out (fixed-point)
wire [precision + y_bit_in - 1:0] r_H; // H_in / H_out (fixed-point)

// Division modules: compute scaling ratios for X and Y
div #(.IN_W(x_bit_out + x_bit_in), .P(precision)) div1 (
    .q(r_W),
    .done(en1),
    .a(W_in),
    .b(W_out),
    .clk(clk),
    .start(start)
);
div #(.IN_W(y_bit_out + y_bit_in), .P(precision)) div2 (
    .q(r_H),
    .done(en2),
    .a(H_in),
    .b(H_out),
    .clk(clk),
    .start(start)
);

// Fixed-point coordinates for mapping
wire [x_bit_in + precision - 1:0] x_in;
wire [y_bit_in + precision - 1:0] y_in;

// Output pixel coordinates
reg [x_bit_out - 1:0] x_out;
reg [y_bit_out - 1:0] y_out;

// Integer part of input coordinates
wire [x_bit_in - 1:0] x_0;
wire [y_bit_in - 1:0] y_0;

// Fractional part of input coordinates
wire [precision - 1:0] a;
wire [precision - 1:0] b; // 0.xxxxxxxxx (fractional)

// Output value from transform
wire [7:0] value;

// Assign fractional parts from fixed-point coordinates
assign a = x_in[precision - 1:0];
assign b = y_in[precision - 1:0];

// Assign integer parts from fixed-point coordinates
assign x_0 = x_in[x_bit_in + precision - 1:precision];
assign y_0 = y_in[y_bit_in + precision - 1:precision];

// Completion output
assign complete = com;

// Multiply output pixel index by scaling ratio to get input coordinate (X)
mul #(.N(x_bit_out), .M(x_bit_in), .R(x_bit_in), .precision(precision)) m1 (
    x_in,
    x_out,
    r_W
);
// Multiply output pixel index by scaling ratio to get input coordinate (Y)
mul #(.N(y_bit_out), .M(y_bit_in), .R(y_bit_in), .precision(precision)) m2 (
    y_in,
    y_out,
    r_H
);

// Transform module: performs interpolation and channel selection
transform #(
    .precision(precision),
    .W_in(W_in),
    .H_in(H_in),
    .N(x_bit_in),
    .M(y_bit_in),
    .CHANNEL(CHANNEL)
) t1 (
    clk,
    x_0,
    y_0,
    a,
    b,
    counter,
    counter1,
    value
);

// Initialization: set up state and wait for completion
initial begin
    next_state = DIV; // Start in division state
    state      = DIV;
    x_out      = 0;
    y_out      = 0;
    com        = 0;
    counter    = 0;
    counter1   = 0;
    wait (com); // Wait until processing is complete
    $writememh("res.hex", res); // Write output buffer to file
end

// Main state machine: controls division and mapping
always @(posedge clk) begin
    if (rst) begin
        // Synchronous reset of state and counters
        state    <= DIV;
        counter  <= 0;
        counter1 <= 0;
        x_out    <= 0;
        y_out    <= 0;
        com      <= 0;
    end else begin
        state <= next_state;
        // Reset sub-pixel counter in division state
        if (state == DIV) begin
            counter1 <= 0;
        end
        // Mapping state: process each output pixel/channel
        if (!com && state == MAP) begin
            if (counter1 == 3) begin // After 4 sub-steps
                counter1 <= 0;
                if (counter == CHANNEL - 1) begin // Last channel
                    counter <= 0;
                    if (x_out == W_out - 1) begin // Last column
                        x_out <= 0;
                        y_out <= y_out + 1; // Move to next row
                    end else begin
                        x_out <= x_out + 1; // Next column
                    end
                end else begin
                    counter <= counter + 1; // Next channel
                end
            end else begin
                counter1 <= counter1 + 1; // Next sub-step
            end
            // Check if all pixels/channels processed
            if (x_out == W_out - 1 && y_out == H_out - 1 && counter == CHANNEL - 1 && counter1 == 3) begin
                com <= 1; // Set completion flag
            end
        end
    end
end

// Combinational logic for state transitions and output buffer update
always @(*) begin
    if (rst) begin
        next_state = DIV;
        start      = 0;
    end else if (state == DIV && en1 && en2) begin
        // If division done, move to mapping state
        next_state = MAP;
        start      = 0;
    end else if (state == DIV) begin
        start = 1; // Start division
    end else if (state == MAP && counter1 == 3) begin
        // Store output value in result buffer after each pixel/channel
        res[((y_out * W_out + x_out) * CHANNEL) + counter] = value;
    end
end

endmodule