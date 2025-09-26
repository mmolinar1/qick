// HMC HRL Clinic 25-26

// system verilog modeling for a 16 bit DAC
// based on a verilog-ams dac model

module dac(
    input  logic              clk,
    input  logic [bits-1:0]   s_axis_tdata,
    output real               aout
);
    parameter real vref = 5.0;
    parameter int bits = 16;    // DAC resolution - 16 bits
    real aout_reg;
    
    always_ff @(posedge clk) begin
            real ref_val;
            real new_val;

            new_val = 0;
            ref_val = vref;

            for (int i = 0; i < bits; i++) begin
                ref_val = ref_val/ 2.0;
                if (s_axis_tdata[i]) begin
                    new_val = new_val + ref_val;
                end
            end
            
            // new value
            aout_reg = new_val;

    end
    
    // connect internal register to output
    assign aout = aout_reg;
    
endmodule