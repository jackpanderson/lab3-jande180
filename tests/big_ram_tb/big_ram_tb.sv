// `timescale 1ns / 1ps


// module big_ram_tb;



//     logic clk = 0;
//     always #5 clk = ~clk; // 100 MHz

//     // Port A signals
//     logic         pA_wb_cyc_i, pA_wb_stb_i, pA_wb_we_i;
//     logic [10:0]  pA_wb_addr_i;
//     logic [31:0]  pA_wb_data_i;
//     logic [3:0]   pA_wb_sel_i;
//     logic         pA_wb_ack_o, pA_wb_stall_o;
//     logic [31:0]  pA_wb_data_o;

//     // Port B signals
//     logic         pB_wb_cyc_i, pB_wb_stb_i, pB_wb_we_i;
//     logic [10:0]  pB_wb_addr_i;
//     logic [31:0]  pB_wb_data_i;
//     logic [3:0]   pB_wb_sel_i;
//     logic         pB_wb_ack_o, pB_wb_stall_o;
//     logic [31:0]  pB_wb_data_o;

//     logic [31:0] data = 0;

//     // DUT instantiation


//         `ifdef USE_POWER_PINS
//     wire VPWR;
//     wire VGND;
//     assign VPWR=1;
//     assign VGND=0;

//     big_ram dut (
//         .VPWR(VPWR),
//         .VGND(VGND),
//         .clk_i(clk),
//         .pA_wb_cyc_i(pA_wb_cyc_i),
//         .pA_wb_stb_i(pA_wb_stb_i),
//         .pA_wb_we_i(pA_wb_we_i),
//         .pA_wb_addr_i(pA_wb_addr_i),
//         .pA_wb_data_i(pA_wb_data_i),
//         .pA_wb_sel_i(pA_wb_sel_i),
//         .pA_wb_ack_o(pA_wb_ack_o),
//         .pA_wb_stall_o(pA_wb_stall_o),
//         .pA_wb_data_o(pA_wb_data_o),
//         .pB_wb_cyc_i(pB_wb_cyc_i),
//         .pB_wb_stb_i(pB_wb_stb_i),
//         .pB_wb_we_i(pB_wb_we_i),
//         .pB_wb_addr_i(pB_wb_addr_i),
//         .pB_wb_data_i(pB_wb_data_i),
//         .pB_wb_sel_i(pB_wb_sel_i),
//         .pB_wb_ack_o(pB_wb_ack_o),
//         .pB_wb_stall_o(pB_wb_stall_o),
//         .pB_wb_data_o(pB_wb_data_o)
//     );
    
//     `else

//     big_ram dut (
//         .clk_i(clk),
//         .pA_wb_cyc_i(pA_wb_cyc_i),
//         .pA_wb_stb_i(pA_wb_stb_i),
//         .pA_wb_we_i(pA_wb_we_i),
//         .pA_wb_addr_i(pA_wb_addr_i),
//         .pA_wb_data_i(pA_wb_data_i),
//         .pA_wb_sel_i(pA_wb_sel_i),
//         .pA_wb_ack_o(pA_wb_ack_o),
//         .pA_wb_stall_o(pA_wb_stall_o),
//         .pA_wb_data_o(pA_wb_data_o),
//         .pB_wb_cyc_i(pB_wb_cyc_i),
//         .pB_wb_stb_i(pB_wb_stb_i),
//         .pB_wb_we_i(pB_wb_we_i),
//         .pB_wb_addr_i(pB_wb_addr_i),
//         .pB_wb_data_i(pB_wb_data_i),
//         .pB_wb_sel_i(pB_wb_sel_i),
//         .pB_wb_ack_o(pB_wb_ack_o),
//         .pB_wb_stall_o(pB_wb_stall_o),
//         .pB_wb_data_o(pB_wb_data_o)
//     );

//     `endif

//     // Dump waveforms
//     initial begin
//         $dumpfile("waveform.vcd");
//         $dumpvars(2, big_ram_tb);
//     end

//     initial #100000 $error("Timeout");

//     task write_to_portA(input [10:0] addr, input [31:0] data);
//         begin
//             @(posedge clk);
//             pA_wb_addr_i = addr;
//             pA_wb_data_i = data;
//             pA_wb_we_i = 1;
//             pA_wb_cyc_i = 1;
//             pA_wb_stb_i = 1;
//             pA_wb_sel_i = 4'hF;

//             wait (pA_wb_ack_o == 1);
//             @(posedge clk);

//             pA_wb_cyc_i = 0;
//             pA_wb_stb_i = 0;
//             pA_wb_we_i = 0;
//         end
//     endtask

//     task read_from_portA(input [10:0] addr, output [31:0] data);
//         begin
//             @(posedge clk);
//             pA_wb_addr_i = addr;
//             pA_wb_we_i = 0;
//             pA_wb_cyc_i = 1;
//             pA_wb_stb_i = 1;
//             pA_wb_sel_i = 4'hF;

//             wait (pA_wb_ack_o == 1);
//             data = pA_wb_data_o;
//             @(posedge clk);

//             pA_wb_cyc_i = 0;
//             pA_wb_stb_i = 0;
//         end
//     endtask

//     task write_to_portB(input [10:0] addr, input [31:0] data);
//         begin
//             @(posedge clk);
//             pB_wb_addr_i = addr;
//             pB_wb_data_i = data;
//             pB_wb_we_i = 1;
//             pB_wb_cyc_i = 1;
//             pB_wb_stb_i = 1;
//             pB_wb_sel_i = 4'hF;

//             wait (pB_wb_ack_o == 1);
//             @(posedge clk);

//             pB_wb_cyc_i = 0;
//             pB_wb_stb_i = 0;
//             pB_wb_we_i = 0;
//         end
//     endtask

//     task read_from_portB(input [10:0] addr, output [31:0] data);
//         begin
//             @(posedge clk);
//             pB_wb_addr_i = addr;
//             pB_wb_we_i = 0;
//             pB_wb_cyc_i = 1;
//             pB_wb_stb_i = 1;
//             pB_wb_sel_i = 4'hF;

//             wait (pB_wb_ack_o == 1);
//             data = pB_wb_data_o;
//             @(posedge clk);

//             pB_wb_cyc_i = 0;
//             pB_wb_stb_i = 0;
//         end
//     endtask

    
//     initial begin
//         pA_wb_cyc_i = 0; pA_wb_stb_i = 0; pA_wb_we_i = 0; pA_wb_addr_i = 0; pA_wb_data_i = 0;
//         pB_wb_cyc_i = 0; pB_wb_stb_i = 0; pB_wb_we_i = 0; pB_wb_addr_i = 0; pB_wb_data_i = 0;

//         #20;

//         // Write to RAM0
//         write_to_portA(11'b000_0000_0100, 32'hDEADBEEF);

//         // Write to RAM1
//         write_to_portB(11'b100_0000_0010, 32'hBEEFCAFE);

//         // Read back
        
//         read_from_portA(11'b100_0000_0100, data);
//         $display("Port A read back: %h", data);

//         read_from_portB(11'b000_0000_0010, data);
//         $display("Port B read back: %h", data);

//         #50

//         read_from_portA(11'b000_0000_0100, data);
//         $display("Port A read back: %h", data);

//         read_from_portB(11'b100_0000_0010, data);
//         $display("Port B read back: %h", data);

//         #50;

//         #50;
//         $finish;
//     end

// endmodule
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
        $dumpvars(0, big_ram_tb);
    end

    task automatic write_to_portA(input [10:0] addr, input [31:0] data, input [3:0] sel);
        begin
            @(posedge clk);
            pA_wb_addr_i <= addr;
            pA_wb_data_i <= data;
            pA_wb_sel_i  <= sel;
            pA_wb_we_i   <= 1;
            pA_wb_cyc_i  <= 1;
            pA_wb_stb_i  <= 1;
            wait (pA_wb_ack_o);
            @(posedge clk);
            pA_wb_cyc_i <= 0;
            pA_wb_stb_i <= 0;
            pA_wb_we_i  <= 0;
        end
    endtask

    task automatic write_to_portB(input [10:0] addr, input [31:0] data, input [3:0] sel);
        begin
            @(posedge clk);
            pB_wb_addr_i <= addr;
            pB_wb_data_i <= data;
            pB_wb_sel_i  <= sel;
            pB_wb_we_i   <= 1;
            pB_wb_cyc_i  <= 1;
            pB_wb_stb_i  <= 1;
            wait (pB_wb_ack_o);
            @(posedge clk);
            pB_wb_cyc_i <= 0;
            pB_wb_stb_i <= 0;
            pB_wb_we_i  <= 0;
        end
    endtask

    task automatic read_from_portA(input [10:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            pA_wb_addr_i <= addr;
            pA_wb_sel_i  <= 4'hF;
            pA_wb_we_i   <= 0;
            pA_wb_cyc_i  <= 1;
            pA_wb_stb_i  <= 1;
            wait (pA_wb_ack_o);
            data = pA_wb_data_o;
            @(posedge clk);
            pA_wb_cyc_i <= 0;
            pA_wb_stb_i <= 0;
        end
    endtask

    task automatic read_from_portB(input [10:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            pB_wb_addr_i <= addr;
            pB_wb_sel_i  <= 4'hF;
            pB_wb_we_i   <= 0;
            pB_wb_cyc_i  <= 1;
            pB_wb_stb_i  <= 1;
            wait (pB_wb_ack_o);
            data = pB_wb_data_o;
            @(posedge clk);
            pB_wb_cyc_i <= 0;
            pB_wb_stb_i <= 0;
        end
    endtask

    task sim_read_check(
        input [10:0] addrA, input [10:0] addrB,
        input [31:0] expectedA, input [31:0] expectedB
    );
        begin
            tests = tests + 1;
            fork
                begin
                    read_from_portA(addrA, read_valA);
                end
                begin
                    read_from_portB(addrB, read_valB);
                end
            join
            if (read_valA !== expectedA) begin
                $display("FAIL A@%0d: got %h, expected %h", addrA, read_valA, expectedA);
                errors = errors + 1;
            end else begin
                $display("PASS A@%0d", addrA);
            end
            if (read_valB !== expectedB) begin
                $display("FAIL B@%0d: got %h, expected %h", addrB, read_valB, expectedB);
                errors = errors + 1;
            end else begin
                $display("PASS B@%0d", addrB);
            end
        end
    endtask

    task automatic test_portA(
        input [10:0] addr,
        input [31:0] wdata,
        input [3:0] sel,
        input [31:0] expected
    );
        begin
            write_to_portA(addr, wdata, sel);
            read_from_portA(addr, read_valA);
            tests = tests + 1;
            if (read_valA !== expected) begin
                $display("FAIL A@%0d: got %h, expected %h", addr, read_valA, expected);
                errors = errors + 1;
            end else begin
                $display("PASS A@%0d", addr);
            end
        end
    endtask

    task automatic test_portB(
        input [10:0] addr,
        input [31:0] wdata,
        input [3:0] sel,
        input [31:0] expected
    );
        begin
            write_to_portB(addr, wdata, sel);
            read_from_portB(addr, read_valB);
            tests = tests + 1;
            if (read_valB !== expected) begin
                $display("FAIL B@%0d: got %h, expected %h", addr, read_valB, expected);
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

        // Run tests in tasks
        test_portA(11'd4,   32'hDEADBEEF, 4'hF, 32'hDEADBEEF);
        test_portB(11'd258, 32'hBEEFCAFE, 4'hF, 32'hBEEFCAFE);
        test_portA(11'd10,  32'hAABBCCDD, 4'hF,  32'hAABBCCDD);
        test_portA(11'd10,  32'h00001122, 4'b0011, {8'hAA,8'hBB,8'h11,8'h22});

        test_portA(11'd100, 32'h12345678, 4'hF, 32'h12345678);
        test_portB(11'd200, 32'hABCDEF01, 4'hF, 32'hABCDEF01);
        sim_read_check(11'd100, 11'd200, 32'h12345678, 32'hABCDEF01);

        // Summary
        #20;
        $display("==== Test Summary: %0d tests, %0d errors ====", tests, errors);
        if (errors > 0) $error("%0d failures detected", errors);
        else         $display("All tests passed!");
        #10 $finish;
    end

endmodule
