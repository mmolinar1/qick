// HMC HRL Clinic 25-26
// testbench for DAC-ADC waveform visualization

`timescale 1ps/1ps

module dac_adc_tb();

    // Parameters
    parameter integer BITS = 16;       
    parameter real V_REF = 1.0;
    parameter integer N_DAC = 16;      
    parameter time DAC_CLK_P = 2325;   // ~430.08 MHz
    parameter time ADC_CLK_P = 3255;   // ~307.20 MHz

    // Signals
    logic dac_clk = 0;
    logic adc_clk = 0;
    logic s_axis_tvalid;
    logic [N_DAC*BITS-1:0] s_axis_tdata;
    logic [BITS-1:0] adc_out;
    logic signed [15:0] ramp_val;

    // DUT
    dac_adc_loop #(
        .BITS(BITS),
        .V_REF(V_REF),
        .N_DAC(N_DAC)
    ) dut (
        .dac_clk(dac_clk),
        .adc_clk(adc_clk),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .adc_out(adc_out)
    );

    // Clock Generation
    always begin
        dac_clk = 1; #(DAC_CLK_P / 2);
        dac_clk = 0; #(DAC_CLK_P / 2);
    end

    always begin
        adc_clk = 1; #(ADC_CLK_P / 2);
        adc_clk = 0; #(ADC_CLK_P / 2);
    end

    // Test
    initial begin
        // Waveform dumping
        $dumpfile("dac_adc_waves.vcd");
        $dumpvars(0, dac_adc_tb);

        // Initialize
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        
        #10000;
        s_axis_tvalid = 1;

        // 16-bit signed: 0x8000 (-32768) to 0x7FFF (+32767)
        // 512 steps × 128 = 65536
        for (int i = 0; i < 512; i++) begin
            
            ramp_val = -32768 + (i * 128);
            
            // Apply to all DAC channels
            s_axis_tdata = {N_DAC{ramp_val}};
            
            // Wait a few DAC cycles per step
            repeat(4) @(posedge dac_clk);
        end

        // Hold at max for a bit
        repeat(20) @(posedge dac_clk);
        $finish;
    end

endmodule
