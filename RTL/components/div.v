
// Fixed-point divider module
// Computes q = a / b in fixed-point format with P fractional bits
module div #(
    parameter IN_W = 16,   // Input integer width
    parameter P    = 8     // Number of fractional bits
)(
    input                   clk,   // System clock
    input                   start, // Start signal
    input  [IN_W - 1:0]     a,     // Dividend (positive integer)
    input  [IN_W - 1:0]     b,     // Divisor  (positive integer)

    output reg [IN_W + P - 1:0] q, // Fixed-point quotient output
    output reg              done   // High when division is complete
);

    // Internal registers for division algorithm
    reg [IN_W + P - 1:0] dividend;   // Shifted dividend
    reg [IN_W + P - 1:0] quotient;   // Accumulated quotient
    reg [IN_W + P:0]     remainder;  // Remainder
    reg [$clog2(IN_W + P + 1) - 1:0] count; // Bit counter

    reg busy; // Busy flag

    reg [IN_W + P:0] temp;  // Temporary for subtraction
    reg [IN_W + P:0] temp1; // (Unused, reserved)

    // Initialization
    initial begin
        busy  = 0;
        done  = 0;
        temp  = 0;
        temp1 = 0;
    end

    // Main division process (shift-and-subtract algorithm)
    always @(posedge clk) begin
        if (start && !busy) begin
            // Start division: initialize registers
            dividend  <= (a << P); // Shift dividend for fixed-point
            quotient  <= 0;
            remainder <= 0;
            count     <= IN_W + P + 1;
            busy      <= 1'b1;
            done      <= 1'b0;
        end else if (start && busy) begin
            // Division in progress: shift and subtract
            dividend  <= (dividend << 1'b1);
            // Compare remainder and subtract divisor if possible
            if (remainder >= b) begin
                remainder <= {temp[IN_W + P - 1:0], dividend[IN_W + P - 1]};
                quotient  <= {quotient[IN_W + P - 2:0], 1'b1};
            end else begin
                remainder <= {remainder[IN_W + P - 1:0], dividend[IN_W + P - 1]};
                quotient  <= {quotient[IN_W + P - 2:0], 1'b0};
            end

            count <= count - 1;

            // If all bits processed, output result
            if (count == 0) begin
                q    <= quotient;
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end

    // Combinational: compute subtraction for next step
    always @(*) begin
        temp = remainder - b;
    end

endmodule
