
`timescale 1ns / 1ps

// Fixed-point multiplier module
// Computes out = a * b in fixed-point format
module mul #(
    parameter N         = 16,  // Width of input a
    parameter M         = 16,  // Output width (not used in this version)
    parameter R         = 8,   // Integer part width of b
    parameter precision = 16   // Number of fractional bits in b
) (
    output [precision + N + R - 1:0] out, // Product output
    input  [N - 1:0]                 a,   // Multiplicand
    input  [R + precision - 1:0]     b    // Multiplier (fixed-point)
);
    // Direct multiplication (no rounding/truncation)
    assign out = a * b;

endmodule
