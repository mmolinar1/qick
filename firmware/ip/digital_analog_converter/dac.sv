// HMC HRL Clinic 25-26

// system verilog modeling for a 32 bit DAC
// based on a verilog-ams dac model

module dac(
    input  logic              clk,
    input  logic [bits-1:0]   s_axis_tdata,
    input  logic              s_axis_tready,
    input  logic              s_axis_tvalid,
    output real               aout
);
    parameter real vref;
    parameter int bits = 16;    // DAC resolution - 32 bits
    parameter time td = 1ns;    // Processing delay of DAC
    real aout_reg;
    
    always_ff @(posedge clk) begin
        if(s_axis_tready) begin
            real ref_val;
            real new_val;

            new_val = 0;
            ref_val = val;

            for (int i = 0; i < bits; i++) begin
                ref_val = ref_val/ 2.0;
                if (s_axis_tdata[i]) begin
                    new_val = new_val + ref_val;
                end
            end
            
            // mew value w/ delay
            #(td) aout_reg = new_val;

        end
    end
    
    // connect internal register to output
    assign aout = aout_reg;
    
endmodule