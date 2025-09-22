// test bench for a DAC

`timescale 1ps/1ps

module dac_tb();

    logic              clk;
    logic [bits-1:0]   digital_in;
    real               vref;
    real               aout;
    logic [31:0]       errors;

    dac dut(
        .clk(clk),
        .digital_in(digital_in),
        .vref(vref),
        .aout(aout)
    );

    parameter int bits = dut.bits;    // DAC resolution in bits
    parameter time td = dut.td;       // Processing delay of DAC
    real aout_reg;

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        digital_in = 32'd0;
        errors = 0;
        vref = 5.0;

        #10;
        assert(dut.digital_in == 4'b0000) else begin
            $error("Input digital signal is not 0");
            errors++;
        end

        digital_in <= '1;// biggest input
         #50;
         real expected_out = vref * (real'(2**bits - 1)) / (real'(2**bits));
         assert($abs(aout - expected_out) < 1e-9) else begin
            $error("aout is not its expected value with a max input");
            errors++;

        // stop the simulation
        if (errors == 0)
            $display("All tests passed");
        else
            $display("%d tests failed", errors);

        $display("Tests completed ");
        $stop;
    end
endmodule