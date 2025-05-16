`timescale 1ns / 1ps

module big_ram_tb;

    // Clock
    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Port A signals
    reg          pA_wb_cyc_i, pA_wb_stb_i, pA_wb_we_i;
    reg  [10:0]  pA_wb_addr_i;
    reg  [31:0]  pA_wb_data_i;
    reg  [3:0]   pA_wb_sel_i;
    wire         pA_wb_ack_o, pA_wb_stall_o;
    wire [31:0]  pA_wb_data_o;

    // Port B signals
    reg          pB_wb_cyc_i, pB_wb_stb_i, pB_wb_we_i;
    reg  [10:0]  pB_wb_addr_i;
    reg  [31:0]  pB_wb_data_i;
    reg  [3:0]   pB_wb_sel_i;
    wire         pB_wb_ack_o, pB_wb_stall_o;
    wire [31:0]  pB_wb_data_o;

    // Test counters
    integer errors = 0;
    integer tests  = 0;
    reg [31:0] read_valA, read_valB;

    // DUT instantiation
`ifdef USE_POWER_PINS
    wire VPWR = 1;
    wire VGND = 0;
    big_ram dut (
        .VPWR(VPWR), .VGND(VGND),
        .clk_i(clk),
        .pA_wb_cyc_i(pA_wb_cyc_i), .pA_wb_stb_i(pA_wb_stb_i), .pA_wb_we_i(pA_wb_we_i),
        .pA_wb_addr_i(pA_wb_addr_i), .pA_wb_data_i(pA_wb_data_i), .pA_wb_sel_i(pA_wb_sel_i),
        .pA_wb_ack_o(pA_wb_ack_o), .pA_wb_stall_o(pA_wb_stall_o), .pA_wb_data_o(pA_wb_data_o),
        .pB_wb_cyc_i(pB_wb_cyc_i), .pB_wb_stb_i(pB_wb_stb_i), .pB_wb_we_i(pB_wb_we_i),
        .pB_wb_addr_i(pB_wb_addr_i), .pB_wb_data_i(pB_wb_data_i), .pB_wb_sel_i(pB_wb_sel_i),
        .pB_wb_ack_o(pB_wb_ack_o), .pB_wb_stall_o(pB_wb_stall_o), .pB_wb_data_o(pB_wb_data_o)
    );
`else
    big_ram dut (
        .clk_i(clk),
        .pA_wb_cyc_i(pA_wb_cyc_i), .pA_wb_stb_i(pA_wb_stb_i), .pA_wb_we_i(pA_wb_we_i),
        .pA_wb_addr_i(pA_wb_addr_i), .pA_wb_data_i(pA_wb_data_i), .pA_wb_sel_i(pA_wb_sel_i),
        .pA_wb_ack_o(pA_wb_ack_o), .pA_wb_stall_o(pA_wb_stall_o), .pA_wb_data_o(pA_wb_data_o),
        .pB_wb_cyc_i(pB_wb_cyc_i), .pB_wb_stb_i(pB_wb_stb_i), .pB_wb_we_i(pB_wb_we_i),
        .pB_wb_addr_i(pB_wb_addr_i), .pB_wb_data_i(pB_wb_data_i), .pB_wb_sel_i(pB_wb_sel_i),
        .pB_wb_ack_o(pB_wb_ack_o), .pB_wb_stall_o(pB_wb_stall_o), .pB_wb_data_o(pB_wb_data_o)
    );
`endif

    // Waveform dump
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(2, big_ram_tb);
    end

    // Write to Port A (sel driven)
    task automatic write_to_portA(input [10:0] addr, input [31:0] data, input [3:0] sel);
    begin
        @(posedge clk);
        pA_wb_addr_i <= addr;
        pA_wb_data_i <= data;
        pA_wb_sel_i  <= sel;
        pA_wb_we_i   <= 1;
        pA_wb_cyc_i  <= 1;
        pA_wb_stb_i  <= 1;
        @(posedge clk);
        wait (pA_wb_ack_o);
        @(posedge clk);
        pA_wb_cyc_i <= 0;
        pA_wb_stb_i <= 0;
        pA_wb_we_i  <= 0;
    end
    endtask

    // Read from Port A (extra cycle for data)
    task automatic read_from_portA(input [10:0] addr, output [31:0] data);
    begin
        @(posedge clk);
        pA_wb_addr_i <= addr;
        pA_wb_sel_i  <= 4'hF;
        pA_wb_we_i   <= 0;
        pA_wb_cyc_i  <= 1;
        pA_wb_stb_i  <= 1;
        @(posedge clk);
        wait (pA_wb_ack_o);
        data = pA_wb_data_o;
        @(posedge clk);
        pA_wb_cyc_i <= 0;
        pA_wb_stb_i <= 0;
    end
    endtask

    // Write to Port B
    task automatic write_to_portB(input [10:0] addr, input [31:0] data, input [3:0] sel);
    begin
        @(posedge clk);
        pB_wb_addr_i <= addr;
        pB_wb_data_i <= data;
        pB_wb_sel_i  <= sel;
        pB_wb_we_i   <= 1;
        pB_wb_cyc_i  <= 1;
        pB_wb_stb_i  <= 1;
        @(posedge clk);
        wait (pB_wb_ack_o);
        @(posedge clk);
        pB_wb_cyc_i <= 0;
        pB_wb_stb_i <= 0;
        pB_wb_we_i  <= 0;
    end
    endtask

    // Read from Port B (extra cycle)
    task automatic read_from_portB(input [10:0] addr, output [31:0] data);
    begin
        @(posedge clk);
        pB_wb_addr_i <= addr;
        pB_wb_sel_i  <= 4'hF;
        pB_wb_we_i   <= 0;
        pB_wb_cyc_i  <= 1;
        pB_wb_stb_i  <= 1;
        @(posedge clk);
        wait (pB_wb_ack_o);
        data = pB_wb_data_o;
        @(posedge clk);
        pB_wb_cyc_i <= 0;
        pB_wb_stb_i <= 0;
    end
    endtask
    

    task automatic sim_read_check(
    input logic [10:0] addr_a, addr_b,
    input logic [31:0] expected_data_a,
    input logic [31:0] expected_data_b
);
    bit got_ack_a = 0;
    bit got_ack_b = 0;
    bit deassert_a = 0;
    bit deassert_b = 0;
begin
    // Initiate both reads
    @(posedge clk);
    pA_wb_addr_i = addr_a;
    pA_wb_cyc_i = 1;
    pA_wb_stb_i = 1;
    pA_wb_we_i  = 0;

    pB_wb_addr_i = addr_b;
    pB_wb_cyc_i = 1;
    pB_wb_stb_i = 1;
    pB_wb_we_i  = 0;

    // Wait for both acks, independently
    while (!(got_ack_a && got_ack_b)) begin
        @(posedge clk);

        // Handle Port A ack
        if (!got_ack_a && pA_wb_ack_o) begin
            got_ack_a = 1;
            if (pA_wb_data_o !== expected_data_a) begin
                $display("ERROR: Port A read @ addr %0d: got 0x%08h, expected 0x%08h", addr_a, pA_wb_data_o, expected_data_a);
            end else begin
                $display("Port A read @ addr %0d OK: 0x%08h", addr_a, pA_wb_data_o);
            end
            // Schedule deassertion on next clock
            deassert_a = 1;
        end

        // Handle Port B ack
        if (!got_ack_b && pB_wb_ack_o) begin
            got_ack_b = 1;
            if (pB_wb_data_o !== expected_data_b) begin
                $display("ERROR: Port B read @ addr %0d: got 0x%08h, expected 0x%08h", addr_b, pB_wb_data_o, expected_data_b);
            end else begin
                $display("Port B read @ addr %0d OK: 0x%08h", addr_b, pB_wb_data_o);
            end
            // Schedule deassertion on next clock
            deassert_b = 1;
        end

        // Deassert signals after ack cycle
        @(posedge clk);
        if (deassert_a) begin
            pA_wb_cyc_i = 0;
            pA_wb_stb_i = 0;
            deassert_a = 0;
        end
        if (deassert_b) begin
            pB_wb_cyc_i = 0;
            pB_wb_stb_i = 0;
            deassert_b = 0;
        end
    end

    @(posedge clk); // allow cycle to settle
end
endtask


    // Test Port A (masked)
    task automatic test_portA(
        input [10:0] addr,
        input [31:0] wdata,
        input [3:0] sel,
        input [31:0] expected
    );
    begin
        logic [31:0] writeMask = {
            {8{sel[3]}},
            {8{sel[2]}},
            {8{sel[1]}},
            {8{sel[0]}}
        };

        write_to_portA(addr, wdata, sel);
        read_from_portA(addr, read_valA);
        tests = tests + 1;

        if ((read_valA & writeMask) !== (expected & writeMask)) begin
            $display("FAIL A@%0d: got %h, expected %h", addr,
                     (read_valA & writeMask), (expected & writeMask));
            errors = errors + 1;
        end else begin
            $display("PASS A@%0d", addr);
        end
        #10;
    end
    endtask

    // Test Port B (masked)
    task automatic test_portB(
        input [10:0] addr,
        input [31:0] wdata,
        input [3:0] sel,
        input [31:0] expected
    );
    begin
        logic [31:0] writeMask = {
            {8{sel[3]}},
            {8{sel[2]}},
            {8{sel[1]}},
            {8{sel[0]}}
        };

        write_to_portB(addr, wdata, sel);
        read_from_portB(addr, read_valB);
        tests = tests + 1;

        if ((read_valB & writeMask) !== (expected & writeMask)) begin
            $display("FAIL B@%0d: got %h, expected %h", addr,
                     (read_valB & writeMask), (expected & writeMask));
            errors = errors + 1;
        end else begin
            $display("PASS B@%0d", addr);
        end
    end
    endtask

    // Main Testbench
    initial begin
        // Reset signals
        {pA_wb_cyc_i, pA_wb_stb_i, pA_wb_we_i, pA_wb_addr_i, pA_wb_data_i, pA_wb_sel_i} = 0;
        {pB_wb_cyc_i, pB_wb_stb_i, pB_wb_we_i, pB_wb_addr_i, pB_wb_data_i, pB_wb_sel_i} = 0;
        #20;

        // Run tests
        test_portA(11'd4,   32'hDEADBEEF, 4'hF,   32'hDEADBEEF);
        test_portB(11'd260, 32'hBEEFCAFE, 4'hF,   32'hBEEFCAFE);
        test_portA(11'd8,   32'hAABBCCDD, 4'hF,   32'hAABBCCDD);
        test_portA(11'd48,  32'h00001122, 4'b0011, 32'h00001122);
        test_portA(11'd100, 32'h12345678, 4'hF,   32'h12345678);
        test_portB(11'd200, 32'hABCDEF01, 4'hF,   32'hABCDEF01);


        
        // Simultaneous-read check
        sim_read_check(11'd100, 11'd200, 32'h12345678, 32'hABCDEF01);

        #20;
        write_to_portA(11'd4, 32'hBEEFBEEF, 4'hF);
        write_to_portA(11'd260, 32'hFEFEFEFE, 4'hF);
        #40;

        sim_read_check(11'd4, 11'd260, 32'hBEEFBEEF, 32'hFEFEFEFE);

        


        // Summary
        #20;
        $display("==== Test Summary: %0d tests, %0d err ====", tests, errors);
        
        if (errors > 0) $error("%0d failures detected", errors);
        else             $display("All tests passed!");
        #10 $finish;
    end

endmodule