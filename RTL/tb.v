`timescale 1ns / 1ps

module tb;

    // clock
    reg clk;
    reg rst;

    // output from DUT
    wire complete;

    // instantiate DUT
    top #(
        .H_in(256),
        .W_in(256),
        .H_out(512),
        .W_out(512),
        .CHANNEL(3)
    ) dut (
        .clk(clk),
        .rst(rst),
        .complete(complete)
    );

    // clock generation: 100 MHz (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // reset generation
    initial begin
        rst = 1'b1;
        #20;
        rst = 1'b0;
    end

    initial begin
        forever #10 $display(
            " STATE %d x %d  y %d  debug1 %d ",
            dut.state,
            dut.x_out,
            dut.y_out,
            dut.t1.acc
        );
    end
    // simulation control
    // finish when done
    initial begin
        @(posedge complete);
        $display("Simulation finished at time %0t", $time);
        $finish;
    end

endmodule
