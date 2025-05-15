`timescale 1ns / 1ps

module big_ram_tb;

    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Port A signals
    logic         pA_wb_cyc_i, pA_wb_stb_i, pA_wb_we_i;
    logic [10:0]  pA_wb_addr_i;
    logic [31:0]  pA_wb_data_i;
    logic [3:0]   pA_wb_sel_i;
    logic         pA_wb_ack_o, pA_wb_stall_o;
    logic [31:0]  pA_wb_data_o;

    // Port B signals
    logic         pB_wb_cyc_i, pB_wb_stb_i, pB_wb_we_i;
    logic [10:0]  pB_wb_addr_i;
    logic [31:0]  pB_wb_data_i;
    logic [3:0]   pB_wb_sel_i;
    logic         pB_wb_ack_o, pB_wb_stall_o;
    logic [31:0]  pB_wb_data_o;

    logic [31:0] data;

    // DUT instantiation
    big_ram dut (
        .clk_i(clk),
        .pA_wb_cyc_i(pA_wb_cyc_i),
        .pA_wb_stb_i(pA_wb_stb_i),
        .pA_wb_we_i(pA_wb_we_i),
        .pA_wb_addr_i(pA_wb_addr_i),
        .pA_wb_data_i(pA_wb_data_i),
        .pA_wb_sel_i(pA_wb_sel_i),
        .pA_wb_ack_o(pA_wb_ack_o),
        .pA_wb_stall_o(pA_wb_stall_o),
        .pA_wb_data_o(pA_wb_data_o),
        .pB_wb_cyc_i(pB_wb_cyc_i),
        .pB_wb_stb_i(pB_wb_stb_i),
        .pB_wb_we_i(pB_wb_we_i),
        .pB_wb_addr_i(pB_wb_addr_i),
        .pB_wb_data_i(pB_wb_data_i),
        .pB_wb_sel_i(pB_wb_sel_i),
        .pB_wb_ack_o(pB_wb_ack_o),
        .pB_wb_stall_o(pB_wb_stall_o),
        .pB_wb_data_o(pB_wb_data_o)
    );

    // Dump waveforms
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, big_ram_tb);
    end

    task write_to_portA(input [10:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            pA_wb_addr_i = addr;
            pA_wb_data_i = data;
            pA_wb_we_i = 1;
            pA_wb_cyc_i = 1;
            pA_wb_stb_i = 1;
            pA_wb_sel_i = 4'hF;

            wait (pA_wb_ack_o == 1);
            @(posedge clk);

            pA_wb_cyc_i = 0;
            pA_wb_stb_i = 0;
            pA_wb_we_i = 0;
        end
    endtask

    task read_from_portA(input [10:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            pA_wb_addr_i = addr;
            pA_wb_we_i = 0;
            pA_wb_cyc_i = 1;
            pA_wb_stb_i = 1;
            pA_wb_sel_i = 4'hF;

            wait (pA_wb_ack_o == 1);
            data = pA_wb_data_o;
            @(posedge clk);

            pA_wb_cyc_i = 0;
            pA_wb_stb_i = 0;
        end
    endtask

    task write_to_portB(input [10:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            pB_wb_addr_i = addr;
            pB_wb_data_i = data;
            pB_wb_we_i = 1;
            pB_wb_cyc_i = 1;
            pB_wb_stb_i = 1;
            pB_wb_sel_i = 4'hF;

            wait (pB_wb_ack_o == 1);
            @(posedge clk);

            pB_wb_cyc_i = 0;
            pB_wb_stb_i = 0;
            pB_wb_we_i = 0;
        end
    endtask

    task read_from_portB(input [10:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            pB_wb_addr_i = addr;
            pB_wb_we_i = 0;
            pB_wb_cyc_i = 1;
            pB_wb_stb_i = 1;
            pB_wb_sel_i = 4'hF;

            wait (pB_wb_ack_o == 1);
            data = pB_wb_data_o;
            @(posedge clk);

            pB_wb_cyc_i = 0;
            pB_wb_stb_i = 0;
        end
    endtask

    
    initial begin
        pA_wb_cyc_i = 0; pA_wb_stb_i = 0; pA_wb_we_i = 0; pA_wb_addr_i = 0; pA_wb_data_i = 0;
        pB_wb_cyc_i = 0; pB_wb_stb_i = 0; pB_wb_we_i = 0; pB_wb_addr_i = 0; pB_wb_data_i = 0;

        #20;

        // Write to RAM0
        write_to_portA(11'b000_0000_0100, 32'hDEADBEEF);

        // Write to RAM1
        write_to_portB(11'b100_0000_0010, 32'hBEEFCAFE);

        // Read back
        
        read_from_portA(11'b100_0000_0100, data);
        $display("Port A read back: %h", data);

        read_from_portB(11'b000_0000_0010, data);
        $display("Port B read back: %h", data);

        #50

        read_from_portA(11'b000_0000_0100, data);
        $display("Port A read back: %h", data);

        read_from_portB(11'b100_0000_0010, data);
        $display("Port B read back: %h", data);

        #50;

        #50;
        $finish;
    end

endmodule
