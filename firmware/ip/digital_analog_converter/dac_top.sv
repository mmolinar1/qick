// HMC HRL Clinic 25-26

// system verilog modeling for a DAC
// that takes in a 256-bit word

module dac_top #(
    parameter int bits = 256,       // Total DAC resolution
    parameter int N_DDS = 16        // Number of DDS channels
)(
    input  logic              clk,
    input  logic [bits-1:0]   s_axis_tdata,
    input  logic              s_axis_tvalid,
    output logic [bits-1:0]   dac_out
);

    generate
        genvar i;

        for (i = 0; i < N_DDS; i = i + 1) begin : dds_loop
            logic [15:0] aout;  // Local output of each DAC

            dac dac_inst (
                .clk(clk),
                .s_axis_tdata(s_axis_tdata[i*16 +: 16]),
                .aout(aout)
            );

            assign dac_out[i*16 +: 16] = aout;
        end
    endgenerate

endmodule
