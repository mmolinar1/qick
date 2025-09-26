// HMC HRL Clinic 25-26

// system verilog modeling for a DAC
// that takes in a 256-bit word

module dac(
    input  logic              clk,
    input  logic [bits-1:0]   s_axis_tdata,
    input logic               s_axis_tvalid,
    output real               dac_out
);

    parameter int bits = 256;    // DAC resolution - 16 bits
    parameter int N_DDS = 16;

    generate
        genvar i;

        for (i=0; i<N_DDS, i=i+1) begin : dds_loop

            16bit_dac dac(
                .clk(clk),
                .s_axis_tdata(s_axis_tdata[i*16 +: 16]),
                .aout(aout)
                );
            dac_out[i*16 +: 16] = aout;
        end
    endgenerate
endmodule