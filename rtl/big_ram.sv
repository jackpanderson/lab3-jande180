module big_ram(
    input  logic        clk_i,
    input  logic        rst_i,

    // Port A Wishbone
    input  logic        pA_wb_cyc_i,
    input  logic        pA_wb_stb_i,
    input  logic        pA_wb_we_i,
    input  logic [10:0] pA_wb_addr_i,
    input  logic [31:0] pA_wb_data_i,
    input  logic [3:0]  pA_wb_sel_i,
    output logic        pA_wb_ack_o,
    output logic        pA_wb_stall_o,
    output logic [31:0] pA_wb_data_o,

    // Port B Wishbone
    input  logic        pB_wb_cyc_i,
    input  logic        pB_wb_stb_i,
    input  logic        pB_wb_we_i,
    input  logic [10:0] pB_wb_addr_i,
    input  logic [31:0] pB_wb_data_i,
    input  logic [3:0]  pB_wb_sel_i,
    output logic        pB_wb_ack_o,
    output logic        pB_wb_stall_o,
    output logic [31:0] pB_wb_data_o
);

    logic pAtoRAM0, pBtoRAM0; //For routing outputs from RAM modules
    logic [7:0] pAextractedAddr, pBextractedAddr;

    logic conflict;         //High when both ports conflict on bank
    logic headbutt_winner = 1'b0;
    logic pA_go, pB_go;

    logic [3:0] pA_write_mask, pB_write_mask; // Write-enable masks

    // RAM0 control signals
    logic        ram0_EN0;
    logic [3:0]  ram0_WE0;
    logic [7:0]  ram0_A0;
    logic [31:0] ram0_Di0, ram0_Do0;

    // RAM1 control signals
    logic        ram1_EN0;
    logic [3:0]  ram1_WE0;
    logic [7:0]  ram1_A0;
    logic [31:0] ram1_Di0, ram1_Do0;

    // Pipeline regs for control on the "next" cycle
    logic        pA_req;
    logic        pA_req_bank0;
    logic [7:0]  pA_req_addr;
    logic        pB_req;
    logic        pB_req_bank0;
    logic [7:0]  pB_req_addr;

    // Registers for delayed ack and gating
    logic pA_ack_r, pB_ack_r;

    assign pAtoRAM0 = ~pA_wb_addr_i[10];
    assign pBtoRAM0 = ~pB_wb_addr_i[10];
    assign pAextractedAddr = pA_wb_addr_i[9:2];
    assign pBextractedAddr = pB_wb_addr_i[9:2];

    // RAM macros
    DFFRAM256x32 ram0 (
        .CLK (clk_i),
        .WE0 (ram0_WE0),
        .EN0 (ram0_EN0),
        .A0  (ram0_A0),
        .Di0 (ram0_Di0),
        .Do0 (ram0_Do0)
    );

    DFFRAM256x32 ram1 (
        .CLK (clk_i),
        .WE0 (ram1_WE0),
        .EN0 (ram1_EN0),
        .A0  (ram1_A0),
        .Di0 (ram1_Di0),
        .Do0 (ram1_Do0)
    );

    always_comb begin
        

        conflict = pA_wb_stb_i && pB_wb_stb_i && (pAtoRAM0 == pBtoRAM0);

        pA_go = (!conflict) || headbutt_winner;
        pB_go = (!conflict) || !headbutt_winner;

        pA_wb_stall_o = conflict && !pA_go;
        pB_wb_stall_o = conflict && !pB_go;

        pA_write_mask = {4{pA_wb_we_i}} & pA_wb_sel_i;
        pB_write_mask = {4{pB_wb_we_i}} & pB_wb_sel_i;

        // Default RAM control
        ram0_EN0  = 1'b0;
        ram0_WE0  = 4'b0000;
        ram0_A0   = 8'd0;
        ram0_Di0  = 32'd0;

        ram1_EN0  = 1'b0;
        ram1_WE0  = 4'b0000;
        ram1_A0   = 8'd0;
        ram1_Di0  = 32'd0;

        if (pA_wb_stb_i && pA_go) begin
            if (pAtoRAM0) begin
                ram0_EN0  = 1'b1;
                ram0_WE0  = pA_write_mask;
                ram0_A0   = pAextractedAddr;
                ram0_Di0  = pA_wb_data_i;
            end else begin
                ram1_EN0  = 1'b1;
                ram1_WE0  = pA_write_mask;
                ram1_A0   = pAextractedAddr;
                ram1_Di0  = pA_wb_data_i;
            end
        end

        if (pB_wb_stb_i && pB_go) begin
            if (pBtoRAM0) begin
                ram0_EN0  = 1'b1;
                ram0_WE0  = pB_write_mask;
                ram0_A0   = pBextractedAddr;
                ram0_Di0  = pB_wb_data_i;
            end 
            else begin
                ram1_EN0  = 1'b1;
                ram1_WE0  = pB_write_mask;
                ram1_A0   = pBextractedAddr;
                ram1_Di0  = pB_wb_data_i;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_i)
        begin
            headbutt_winner <= 0;
            
        end

        if (conflict)
            headbutt_winner <= ~headbutt_winner;

        // Port A request latch
        if (pA_wb_stb_i && pA_go) begin
            pA_req        <= 1'b1;
            pA_req_bank0  <= pAtoRAM0;
            pA_req_addr   <= pA_wb_addr_i[9:2];
        end else if (pA_req) begin
            pA_req <= 1'b0;
        end

        // Port B request latch
        if (pB_wb_stb_i && pB_go) begin
            pB_req        <= 1'b1;
            pB_req_bank0  <= pBtoRAM0;
            pB_req_addr   <= pB_wb_addr_i[9:2];
        end else if (pB_req) begin
            pB_req <= 1'b0;
        end

        // Delayed ACK registers aligned with data output timing
        pA_ack_r <= pA_req && (!conflict || headbutt_winner);
        pB_ack_r <= pB_req && (!conflict || !headbutt_winner);

        // Output ACK signals delayed
        pA_wb_ack_o <= pA_ack_r;
        pB_wb_ack_o <= pB_ack_r;

        // Data output gated by delayed ACK to prevent loser port showing data
        pA_wb_data_o <= pA_ack_r ? (pA_req_bank0 ? ram0_Do0 : ram1_Do0) : 32'd0;
        pB_wb_data_o <= pB_ack_r ? (pB_req_bank0 ? ram0_Do0 : ram1_Do0) : 32'd0;
    end

endmodule
