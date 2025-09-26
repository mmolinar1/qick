// test bench for a DAC

`timescale 1ps/1ps

module dac_tb();

    logic              clk;
    logic [bits-1:0]   s_axis_data;
    real               vref;
    real               aout;
    logic [31:0]       errors;

    
    dac dut(
        .clk(clk),
        .s_axis_tdata(s_axis_data),
        .aout(aout)
    );

    parameter int bits = dut.bits;    // DAC resolution in bits
    real expected_out;

    // Generate clock: 10 time units period (5 high, 5 low)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Start of test
    initial begin
        // Initialize inputs
        s_axis_data = 16'd0;
        errors = 0;
        vref = 5.0;

        #10;
        assert(s_axis_data == 4'b0000) else begin
            $error("Input digital signal is not 0");
            errors++;
        end

        s_axis_data <= '1;// biggest input
        
         #50;         
         expected_out = vref * (real'(2**bits - 1)) / (real'(2**bits));
         
         assert(((aout - expected_out) < 1e-9) ? -(aout - expected_out) : (aout - expected_out)) else begin
            $error("aout is not its expected value with a max input");
            errors++;
        end

        // stop the simulation
        if (errors == 0)
            $display("All tests passed");
        else
            $display("%d tests failed", errors);

        $display("Tests completed ");
        $stop;
    end
endmodule