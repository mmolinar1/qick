// HMC HRL Clinic 25-26
// SystemVerilog behavioral model of ADC

module adc_model #(
    parameter integer BITS = 16,          // ADC Resolution in bits
    parameter real V_REF = 1.0          // reference voltage
) (
    input  logic clk,                   // Clock signal
    input  real    analog_in,           // Analog input
    output logic [BITS-1:0] digital_out  // Digital output
);

    // internal signals
    real quantization_step;
    real scaled_input;
    int digital_out_reg;

    initial begin
        quantization_step = (2.0 * V_REF) / (1 << BITS);
    end

    // Behavioral model of ADC
    always @(negedge clk) begin

        // Scale input to a value between 0 and (2^BITS - 1)
        scaled_input = analog_in + V_REF;

        // Quantize value to the nearest integer
        digital_out_reg = $rtoi(scaled_input / quantization_step);

        // Clip result to ensure it stays within: 0 to 2^BITS - 1
        if (digital_out_reg >= (1 << BITS)) begin
            digital_out_reg = (1 << BITS) - 1;
        end else if (digital_out_reg < 0) begin
            digital_out_reg = 0;
        end

        // Output signal
        digital_out = digital_out_reg;
    end

endmodule
