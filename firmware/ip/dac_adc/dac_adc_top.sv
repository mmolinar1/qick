// HMC HRL Clinic 25-26
// Connection between the DAC and ADC models with linear interpolation
// This is a simple and behavioral model used to characterize the connection between
// the DAC and ADC, so it is not 100 percent accurate.

module dac_adc_loop #(
    parameter integer BITS = 16,         // Bit resolution
    parameter real V_REF = 1.0,          // Reference voltage
    parameter integer N_DAC = 16         // Number of DAC channels
) (
    input  logic        dac_clk,         // DAC clock (430.08 MHz)
    input  logic        adc_clk,         // ADC clock (307.20 MHz)
    input  logic [N_DAC*BITS-1:0] s_axis_tdata, // Input data for DAC
    input  logic        s_axis_tvalid,   // Valid signal for DAC
    output logic [BITS-1:0] adc_out      // Output data from ADC
);
    // Internal Signals
    real dac_out [N_DAC-1:0];
    real interpolated_analog = 0.0;
    real t_adc;
    real delta_t;
    real delta_sample;
    real fraction;
    real result;

    // Buffer for linear interpolation
    real sample_prev = 0.0;
    real sample_curr = 0.0;
    real time_prev = 0.0;
    real time_curr = 0.0;
    
    // DAC model
    dac_top #(
        .bits(N_DAC * BITS),
        .N_DAC(N_DAC)
    ) dac_inst (
        .clk(dac_clk),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .dac_out(dac_out)
    );

    // ADC model
    adc_model #(
        .BITS(BITS),
        .V_REF(V_REF)
    ) adc_inst (
        .clk(adc_clk),
        .analog_in(interpolated_analog),
        .digital_out(adc_out)
    );

    // Store samples with timestamps in DAC clk domain
    always @(posedge dac_clk) begin
        // Shift current sample to previous
        sample_prev <= sample_curr;
        time_prev <= time_curr;
        
        // Capture new sample and timestamp
        sample_curr <= dac_out[0];  // Using channel 0
        time_curr <= $realtime;
    end

    // Linear interpolation in ADC clk domain
    always @(posedge adc_clk) begin
        
        // Get current ADC sample time
        t_adc = $realtime;
        
        // Calculate time difference between DAC samples
        delta_t = time_curr - time_prev;
        
        // Linear interpolation
        if (delta_t > 0.0) begin
            // Interpolate between two samples
            delta_sample = sample_curr - sample_prev;
            fraction = (t_adc - time_prev) / delta_t;
            result = sample_prev + (fraction * delta_sample);
        end else begin
            // No time difference yet
            result = sample_curr;
        end
        
        // Clamp result to valid range [-V_REF, V_REF]
        if (result > V_REF) begin
            interpolated_analog <= V_REF;
        end else if (result < -V_REF) begin
            interpolated_analog <= -V_REF;
        end else begin
            interpolated_analog <= result;
        end
    end

endmodule
