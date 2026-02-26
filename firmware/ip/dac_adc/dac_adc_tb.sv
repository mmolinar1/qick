// HMC HRL Clinic 25-26
// testbench for DAC-ADC waveform visualization

`timescale 1ps/1ps

module dac_adc_tb();

    // Parameters
    parameter integer BITS = 16;   
    parameter real V_REF = 1.0;
    parameter integer N_DAC = 16;
    parameter integer N_ADC = 8;

    // Clks
    parameter time DAC_FS_CLK = 104;                    // ~9.6 GHz
    parameter time DAC_CLK    = DAC_FS_CLK * N_DAC;     // = 1664 ps (~600 MHz)
    parameter time ADC_FS_CLK = 408;                    // ~2.4510 GHz (made an even period to avoid rounding issues)
    parameter time ADC_CLK    = ADC_FS_CLK * N_ADC;     // = 3264 ps (~306.4 MHz)

    // Signals
    logic dac_clk = 0;
    logic adc_clk = 0;
    logic dac_fs_clk = 0;
    logic adc_fs_clk = 0;
    
    logic s_axis_tvalid;
    logic [N_DAC*BITS-1:0] s_axis_tdata;
    
    logic m_axis_tvalid;
    logic [N_ADC*BITS-1:0] m_axis_tdata;
    
    logic signed [15:0] ramp_val;
    integer i;

    // DUT
    dac_adc_loop #(
        .BITS(BITS),
        .V_REF(V_REF),
        .N_DAC(N_DAC),
        .N_ADC(N_ADC)
    ) dut (
        .dac_clk(dac_clk),
        .adc_clk(adc_clk),
        .dac_fs_clk(dac_fs_clk),
        .adc_fs_clk(adc_fs_clk),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );

    // try 2 independent clocks and derive the other clocks based on these clocks
    // Clock Generation
    always begin
        dac_clk = 1; #(DAC_CLK / 2);
        dac_clk = 0; #(DAC_CLK / 2);
    end

    always begin
        dac_fs_clk = 1; #(DAC_FS_CLK / 2);
        dac_fs_clk = 0; #(DAC_FS_CLK / 2);
    end

    always begin
        adc_clk = 1; #(ADC_CLK / 2);
        adc_clk = 0; #(ADC_CLK / 2);
    end

    always begin
        adc_fs_clk = 1; #(ADC_FS_CLK / 2);
        adc_fs_clk = 0; #(ADC_FS_CLK / 2);
    end

    // Unpack ADC output to display the individual 16-bit samples
    wire signed [15:0] adc_out_0 = m_axis_tdata[0*16 +: 16];
    wire signed [15:0] adc_out_1 = m_axis_tdata[1*16 +: 16];
    wire signed [15:0] adc_out_2 = m_axis_tdata[2*16 +: 16];
    wire signed [15:0] adc_out_3 = m_axis_tdata[3*16 +: 16];
    wire signed [15:0] adc_out_4 = m_axis_tdata[4*16 +: 16];
    wire signed [15:0] adc_out_5 = m_axis_tdata[5*16 +: 16];
    wire signed [15:0] adc_out_6 = m_axis_tdata[6*16 +: 16];
    wire signed [15:0] adc_out_7 = m_axis_tdata[7*16 +: 16];

    // Test
    initial begin
        // Waveform dumping
        $dumpfile("dac_adc_waves.vcd");
        $dumpvars(0, dac_adc_tb);

        // Initialize
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        
        #1000;
        s_axis_tvalid = 1;

        // Testing with sine wave
        for (int i = 0; i < 1000; i++) begin
            for (int k = 0; k < N_DAC; k++) begin
                // Calculate the sine wave for each sample
                // i is the slow clock index, k is the fast clock sample index
                ramp_val = $rtoi(32000.0 * $sin(2.0 * 3.14159 * (i * N_DAC + k) / (16.0 * N_DAC)));  // make faster period
                s_axis_tdata[k*BITS +: BITS] = ramp_val;
            end
            @(posedge dac_clk);
        end

        #1000;
        // Testing with constant signal
        ramp_val = 16'h4000;
        s_axis_tdata = {N_DAC{ramp_val}};

        repeat(100) @(posedge dac_clk);

        // End simulation
        $finish;
    end

endmodule
