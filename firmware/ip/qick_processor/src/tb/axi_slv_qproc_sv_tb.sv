// uses the following files
// sv: qick > firmware > ip > qick_processor > src > axi_slv_qproc_sv
// vhdl: qick > firmware > ip > qick_processor > src > axi_slv_qproc

module axi_slv_qproc_sv_tb #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 6) ();

    // Common Inputs
    logic aclk, aresetn, awvalid, wvalid, bready, arvalid, rready;
    logic [ADDR_WIDTH-1:0] awaddr, araddr;
    logic [2:0] awprot, arprot;
    logic [DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;

    logic [31:0] MEM_DT_O;
    logic [31:0] TPROC_R_DT1;
    logic [31:0] TPROC_R_DT2;
    logic [31:0] TIME_USR;
    logic [31:0] TPROC_STATUS;
    logic [31:0] TPROC_DEBUG; 

    // System Verilog Outputs
    logic awready_sv, wready_sv, bvalid_sv, aready_sv, rvalid_sv;
    logic [1:0] bresp_sv, rresp_sv;
    logic [DATA_WIDTH-1:0] rdata_sv;
    logic [15:0] TPROC_CTRL_sv, TPROC_CFG_sv, MEM_ADDR_sv, MEM_LEN_sv;
    logic [31:0] MEM_DT_I_sv, TPROC_W_DT1_sv, TPROC_W_DT2_sv;
    logic [7:0]  CORE_CFG_sv, READ_SEL_sv;

    // VHDL Outputs
    logic awready_vhdl, wready_vhdl, bvalid_vhdl, aready_vhdl, rvalid_vhdl;
    logic [1:0] bresp_vhdl, rresp_vhdl;
    logic [DATA_WIDTH-1:0] rdata_vhdl;
    logic [15:0] TPROC_CTRL_vhdl, TPROC_CFG_vhdl, MEM_ADDR_vhdl, MEM_LEN_vhdl;
    logic [31:0] MEM_DT_I_vhdl, TPROC_W_DT1_vhdl, TPROC_W_DT2_vhdl;
    logic [7:0]  CORE_CFG_vhdl, READ_SEL_vhdl;
    

    // System Verilog Module Inst
    axi_slv_qproc_sv #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
    sv_dut(
        .aclk(aclk), .aresetn(aresetn), .awaddr(awaddr), .awprot(awprot), .awvalid(awvalid), .awready(awready_sv),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready_sv), .bresp(bresp_sv), .bvalid(bvalid_sv), .bready(bready),
        .araddr(araddr), .arprot(arprot), .arvalid(arvalid), .arready(arready_sv), .rdata(rdata_sv), .rresp(rresp_sv),
        .rvalid(rvalid_sv), .rready(rready),

        .TPROC_CTRL(TPROC_CTRL_sv), .TPROC_CFG(TPROC_CFG_sv), .MEM_ADDR(MEM_ADDR_sv), .MEM_LEN(MEM_LEN_sv),
        .MEM_DT_I(MEM_DT_I_sv), .TPROC_W_DT1(TPROC_W_DT1_sv), .TPROC_W_DT2(TPROC_W_DT2_sv), .CORE_CFG(CORE_CFG_sv),
        .READ_SEL(READ_SEL_sv), .MEM_DT_O(MEM_DT_O), .TPROC_R_DT1(TPROC_R_DT1), .TPROC_R_DT2(TPROC_R_DT2),
        .TIME_USR(TIME_USR), .TPROC_STATUS(TPROC_STATUS), .TPROC_DEBUG(TPROC_DEBUG)
    );

    // VHDL Module Inst
    axi_slv_qproc #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
    vhdl_dut(
        .aclk(aclk), .aresetn(aresetn), .awaddr(awaddr), .awprot(awprot), .awvalid(awvalid), .awready(awready_vhdl),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready_vhdl), .bresp(bresp_vhdl), .bvalid(bvalid_vhdl), .bready(bready),
        .araddr(araddr), .arprot(arprot), .arvalid(arvalid), .arready(arready_vhdl), .rdata(rdata_vhdl), .rresp(rresp_vhdl),
        .rvalid(rvalid_vhdl), .rready(rready),

        .TPROC_CTRL(TPROC_CTRL_vhdl), .TPROC_CFG(TPROC_CFG_vhdl), .MEM_ADDR(MEM_ADDR_vhdl), .MEM_LEN(MEM_LEN_vhdl),
        .MEM_DT_I(MEM_DT_I_vhdl), .TPROC_W_DT1(TPROC_W_DT1_vhdl), .TPROC_W_DT2(TPROC_W_DT2_vhdl), .CORE_CFG(CORE_CFG_vhdl),
        .READ_SEL(READ_SEL_vhdl), .MEM_DT_O(MEM_DT_O), .TPROC_R_DT1(TPROC_R_DT1), .TPROC_R_DT2(TPROC_R_DT2),
        .TIME_USR(TIME_USR), .TPROC_STATUS(TPROC_STATUS), .TPROC_DEBUG(TPROC_DEBUG)
    );

    // Generate Clock
    always begin
        aclk = 1;
        #5;
        aclk = 0;
        #5;
    end

    // Pulse Reset and set some logic
    initial begin
        aresetn = 1;
        #22;
        aresetn = 0;
    end

    // randomize inputs
    /*
    always @(posedge aclk) begin
        if (aresetn) begin
            std::randomize(awvalid);
            std::randomize(wvalid);
            std::randomize(bready);
            std::randomize(arvalid);
            std::randomize(rready);
            std::randomize(awaddr);
            std::randomize(araddr);
            std::randomize(awprot);
            std::randomize(arprot);
            std::randomize(wdata);
            std::randomize(wstrb);
        end
    end*/

    // randomize inputs waiting for each transaction
    always @(posedge aclk) begin
        if (!aresetn) begin
            // Write Address
            // Hold the transaction if it's active and EITHER DUT is not ready
            if (awvalid && (!awready_sv || !awready_vhdl)) begin
                awvalid <= 1'b1; // Hold
            end else begin
                // new transaction
                std::randomize(awvalid, awaddr, awprot);
            end

            // Write Data
            if (wvalid && (!wready_sv || !wready_vhdl)) begin
                wvalid <= 1'b1;
            end else begin
                std::randomize(wvalid, wdata, wstrb);
            end

            // Read Address
            if (arvalid && (!aready_sv || !aready_vhdl)) begin
                arvalid <= 1'b1;
            end else begin
                std::randomize(arvalid, araddr, arprot);
            end

            std::randomize(bready, rready);
            
        end else begin
            // reset
            awvalid <= 0; awaddr <= 0; awprot <= 0;
            wvalid <= 0;  wdata <= 0;  wstrb <= 0;
            arvalid <= 0; araddr <= 0; arprot <= 0;
            bready <= 0;  rready <= 0;
            MEM_DT_O <= 0; TPROC_R_DT1 <= 0; TPROC_R_DT2 <= 0;
            TIME_USR <= 0; TPROC_STATUS <= 0; TPROC_DEBUG <= 0;
        end
    end

    // assert output equivalency on falling edge
    always @(negedge aclk) begin
        if (!aresetn) begin
            assert(awready_sv == awready_vhdl) else $error("awready mismatch: sv: %h, vhdl: %h", awready_sv, awready_vhdl);
            assert(wready_sv  == wready_vhdl)  else $error("wready mismatch: sv: %h, vhdl: %h", wready_sv, wready_vhdl);
            assert(bvalid_sv  == bvalid_vhdl)  else $error("bvalid mismatch: sv: %h, vhdl: %h", bvalid_sv, bvalid_vhdl);
            assert(bresp_sv   == bresp_vhdl)   else $error("bresp mismatch: sv: %h, vhdl: %h", bresp_sv, bresp_vhdl);
            assert(arready_sv == arready_vhdl) else $error("arready mismatch: sv: %h, vhdl: %h", arready_sv, arready_vhdl);
            assert(rvalid_sv  == rvalid_vhdl)  else $error("rvalid mismatch: sv: %h, vhdl: %h", rvalid_sv, rvalid_vhdl);
            assert(rdata_sv   == rdata_vhdl)   else $error("rdata mismatch: sv: %h, vhdl: %h", rdata_sv, rdata_vhdl);
            assert(rresp_sv   == rresp_vhdl)   else $error("rresp mismatch: sv: %h, vhdl: %h", rresp_sv, rresp_vhdl);

            assert(TPROC_CTRL_sv  == TPROC_CTRL_vhdl)  else $error("TPROC_CTRL mismatch: sv: %h, vhdl: %h", TPROC_CTRL_sv, TPROC_CTRL_vhdl);
            assert(TPROC_CFG_sv   == TPROC_CFG_vhdl)   else $error("TPROC_CFG mismatch: sv: %h, vhdl: %h", TPROC_CFG_sv, TPROC_CFG_vhdl);
            assert(MEM_ADDR_sv    == MEM_ADDR_vhdl)    else $error("MEM_ADDR mismatch: sv: %h, vhdl: %h", MEM_ADDR_sv, MEM_ADDR_vhdl);
            assert(MEM_LEN_sv     == MEM_LEN_vhdl)     else $error("MEM_LEN mismatch: sv: %h, vhdl: %h", MEM_LEN_sv, MEM_LEN_vhdl);
            assert(MEM_DT_I_sv    == MEM_DT_I_vhdl)    else $error("MEM_DT_I mismatch: sv: %h, vhdl: %h", MEM_DT_I_sv, MEM_DT_I_vhdl);
            assert(TPROC_W_DT1_sv == TPROC_W_DT1_vhdl) else $error("TPROC_W_DT1 mismatch: sv: %h, vhdl: %h", TPROC_W_DT1_sv, TPROC_W_DT1_vhdl);
            assert(TPROC_W_DT2_sv == TPROC_W_DT2_vhdl) else $error("TPROC_W_DT2 mismatch: sv: %h, vhdl: %h", TPROC_W_DT2_sv, TPROC_W_DT2_vhdl);
            assert(CORE_CFG_sv    == CORE_CFG_vhdl)    else $error("CORE_CFG mismatch: sv: %h, vhdl: %h", CORE_CFG_sv, CORE_CFG_vhdl);
            assert(READ_SEL_sv    == READ_SEL_vhdl)    else $error("READ_SEL mismatch: sv: %h, vhdl: %h", READ_SEL_sv, READ_SEL_vhdl); 
        end
    end
endmodule