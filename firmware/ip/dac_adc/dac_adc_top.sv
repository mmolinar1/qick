// HMC HRL Clinic 25-26
// Connection between the DAC and ADC models with selectable interpolation
// This is a simple and behavioral model used to characterize the connection between
// the DAC and ADC, so it is not 100 percent accurate.

module dac_adc_loop #(
    parameter integer BITS = 16,
    parameter real V_REF = 1.0,
    parameter integer N_DAC = 16,
    parameter integer N_ADC = 8,
    parameter integer BUFFER_SIZE = 16,
    parameter integer USE_INTERPOLATION = 0   // 0 = ZOH, 1 = Linear Interpolation
) (
    input  logic        dac_clk,
    input  logic        adc_clk,
    input  logic        dac_fs_clk,
    input  logic        adc_fs_clk,

    input  logic [N_DAC*BITS-1:0] s_axis_tdata,
    input  logic                  s_axis_tvalid,
    output logic [N_ADC*BITS-1:0] m_axis_tdata,
    output logic                  m_axis_tvalid
);

    // Internal Signals
    reg [N_DAC*BITS-1:0]      dac_data_latched;
    logic [$clog2(N_DAC)-1:0] dac_samp_cnt = 0;
    logic [BITS-1:0]          dac_serial_data;
    logic                     dac_serial_valid;
    real                      dac_out;

    // Analog signal fed to the ADC
    real analog_to_adc;

    // Interpolation buffer signals
    real buffer_samples[BUFFER_SIZE];
    real buffer_times[BUFFER_SIZE];
    int  wr_ptr = 0;

    real t_adc;
    int  idx_curr;
    int  idx_prev;
    real t1, t2, y1, y2;

    logic [BITS-1:0]          adc_serial_out;
    logic [N_ADC*BITS-1:0]    adc_shift_reg;
    logic [$clog2(N_ADC)-1:0] adc_samp_cnt = 0;

    // DAC model
    dac #(
        .BITS(BITS),
        .V_REF(V_REF)
    ) dac_inst (
        .clk(dac_fs_clk),
        .s_axis_tdata(dac_serial_data),
        .s_axis_tvalid(dac_serial_valid),
        .aout(dac_out)
    );

    // ADC model
    adc_model #(
        .BITS(BITS),
        .V_REF(V_REF)
    ) adc_inst (
        .clk(adc_fs_clk),
        .analog_in(analog_to_adc),
        .digital_out(adc_serial_out)
    );

    //////////////// DAC ////////////////

    // Detect dac_clk rising edge in dac_fs_clk domain
    reg dac_clk_d;
    always @(posedge dac_fs_clk) begin
        dac_clk_d <= dac_clk;
    end
    wire dac_clk_rise = dac_clk && !dac_clk_d;

    // Serialize
    always @(posedge dac_fs_clk) begin
        if (dac_clk_rise) begin
            if (s_axis_tvalid)
                dac_data_latched <= s_axis_tdata;
            else
                dac_data_latched <= 0;

            if (s_axis_tvalid)
                dac_serial_data <= s_axis_tdata[0 +: BITS];
            else
                dac_serial_data <= 0;

            dac_samp_cnt <= 1;
        end else begin
            dac_serial_data <= dac_data_latched[BITS*dac_samp_cnt +: BITS];
            if (dac_samp_cnt == N_DAC - 1) dac_samp_cnt <= 0;
            else                           dac_samp_cnt <= dac_samp_cnt + 1;
        end
        dac_serial_valid <= 1'b1;
    end

    //////////////// Analog Connection ////////////////
    generate
        if (USE_INTERPOLATION == 0) begin : zoh_mode
            // ZOH
            assign analog_to_adc = dac_out;

        end else begin : interp_mode
            // Linear Interpolation: buffer recent DAC outputs and interpolate
            always @(negedge dac_fs_clk) begin
                buffer_samples[wr_ptr] = dac_out;
                buffer_times[wr_ptr]   = $realtime;
                wr_ptr = (wr_ptr + 1) % BUFFER_SIZE;
            end

            // Read from buffer and interpolate
            always @(posedge adc_fs_clk) begin
                t_adc    = $realtime;
                idx_curr = (wr_ptr + BUFFER_SIZE - 1) % BUFFER_SIZE;
                idx_prev = (wr_ptr + BUFFER_SIZE - 2) % BUFFER_SIZE;

                t1 = buffer_times[idx_prev];
                t2 = buffer_times[idx_curr];
                y1 = buffer_samples[idx_prev];
                y2 = buffer_samples[idx_curr];

                if (t2 != t1)
                    analog_to_adc = y1 + (t_adc - t1) * (y2 - y1) / (t2 - t1);
                else
                    analog_to_adc = y2;
            end
        end
    endgenerate

    //////////////// ADC ////////////////

    // Detect adc_clk rising edge in adc_fs_clk domain
    reg adc_clk_d;
    always @(posedge adc_fs_clk) begin
        adc_clk_d <= adc_clk;
    end
    wire adc_clk_rise = adc_clk && !adc_clk_d;

    // Deserialize ADC samples in adc_clk domain
    always @(posedge adc_fs_clk) begin
        if (adc_clk_rise) begin
            adc_samp_cnt <= 1;
            adc_shift_reg[0 +: BITS] <= adc_serial_out;
        end else begin
            adc_shift_reg[BITS*adc_samp_cnt +: BITS] <= adc_serial_out;
            if (adc_samp_cnt == N_ADC - 1) adc_samp_cnt <= 0;
            else                           adc_samp_cnt <= adc_samp_cnt + 1;
        end
    end

    always @(posedge adc_clk) begin
        m_axis_tdata  <= adc_shift_reg;
        m_axis_tvalid <= 1'b1;
    end

endmodule