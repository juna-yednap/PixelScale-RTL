`timescale 1ns / 1ps

// Image transform module: performs interpolation for resampling
module transform #(
    parameter N         = 8,  // X coordinate bit width
    parameter M         = 8,  // Y coordinate bit width
    parameter precision = 16, // Number of fractional bits
    parameter W_in      = 200,// Input image width
    parameter H_in      = 200,// Input image height
    parameter CHANNEL   = 1   // Number of channels
)(
    input                  clk,      // System clock
    input  [N - 1:0]        x_0,     // Integer X coordinate
    input  [M - 1:0]        y_0,     // Integer Y coordinate
    input  [precision - 1:0] a,      // Fractional X
    input  [precision - 1:0] b,      // Fractional Y
    input  [1:0]            counter, // Channel selector
    input  [2:0]            counter1,// Interpolation step selector
    output [7:0]            v        // Output pixel value
);
    parameter x_bit_in = $clog2(W_in) + 1;

    // Image memory (flattened 2D array)
    reg [7:0] image [0:W_in * H_in * CHANNEL - 1];

    // Load image from file at start
    initial begin
        $readmemh("image.hex", image);
        acc = 0;
    end

    // All-ones constant for weight calculations
    wire [2 * precision - 1:0] one = ({2 * precision{1'b1}});

    // Neighboring pixel coordinates (handle edge cases)
    wire [N - 1:0] x1 = (x_0 == W_in - 1) ? x_0 - 1 : x_0 + 1;
    wire [N - 1:0] y1 = (y_0 == H_in - 1) ? y_0 - 1 : y_0 + 1;

    // Compute row addresses for interpolation
    wire [M + x_bit_in - 1:0] addr0;
    wire [M + x_bit_in - 1:0] addr2;
    mul #(
        .N(M),
        .R(x_bit_in),
        .precision(0)
    ) mul1 (
        .out(addr0),
        .a(y_0),
        .b(W_in)
    );
    mul #(
        .N(M),
        .R(x_bit_in),
        .precision(0)
    ) mul2 (
        .out(addr2),
        .a(y1),
        .b(W_in)
    );

    // Fetch 2x2 pixel neighborhood for bilinear interpolation
    wire [7:0] p00 = image[(addr0 + x_0) * CHANNEL + counter];
    wire [7:0] p10 = image[(addr0 + x1) * CHANNEL + counter];
    wire [7:0] p01 = image[(addr2 + x_0) * CHANNEL + counter];
    wire [7:0] p11 = image[(addr2 + x1) * CHANNEL + counter];


    wire [2 * precision - 1:0] a_ex = a << precision;
    wire [2 * precision - 1:0] b_ex = b << precision;
    wire [2 * precision - 1:0] ab;

    // Multiply fractional parts for corner weight
    mul #(
        .N(precision),
        .R(precision),
        .precision(0)
    ) mul3 (
        .out(ab),
        .a(a),
        .b(b)
    );

    // Select pixel and weight for current interpolation step
    wire [7:0] p;
    wire [2 * precision - 1:0] weight;
    wire [2 * precision + 7:0] temp;
    assign p = (counter1 == 0) ? p00 :
               (counter1 == 1) ? p01 :
               (counter1 == 2) ? p10 :
               (counter1 == 3) ? p11 :
               p00;
    assign weight = (counter1 == 0) ? (one - a_ex - b_ex + ab) :
                    (counter1 == 1) ? (b_ex - ab) :
                    (counter1 == 2) ? (a_ex - ab) :
                    (counter1 == 3) ? ab :
                    ab;

    // Multiply pixel value by weight
    mul #(
        .N(2 * precision),
        .R(8),
        .precision(0)
    ) mul4 (
        .out(temp),
        .a(weight),
        .b(p)
    );

    // Accumulator for interpolation sum
    reg [2 * precision + 7:0] acc;
    always @(posedge clk) begin
        // Accumulate weighted pixel values
        // if (counter1 > 0 && counter1 < 5) acc <= acc + temp;
        if (counter1 > 0) acc <= acc + temp;
        if (counter1 == 0) acc <= temp;
    end

    // Output: normalized sum (with rounding)
    assign v =
        (acc + temp + (1 << (2 * precision - 1)))
        >> (2 * precision);

endmodule
