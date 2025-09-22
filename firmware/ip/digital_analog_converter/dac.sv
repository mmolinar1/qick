// HMC HRL Clinic 25-26

// system verilog modeling for a 32 bit DAC
// based on a verilog-ams dac model

module dac(
    input  logic              clk,
    input  logic [bits-1:0]   digital_in,
    input  real               vref,
    output real               aout
);
    
    parameter int bits = 32;    // DAC resolution - 32 bits
    parameter time td = 1ns;    // Processing delay of DAC
    real aout_reg;
    
    always_ff @(posedge clk) begin
        real ref_val;
        real new_val;
        
        new_val = 0;
        ref_val = vref;
        
        for (int i = 0; i < bits; i++) begin
            ref_val = ref_val / 2.0;
            if (digital_in[i])
                new_val = new_val + ref_val;
        end
        
        // new value w/ delay
        #(td) aout_reg = new_val;
    end
    
    // connect internal register to output
    assign aout = aout_reg;
    
endmodule