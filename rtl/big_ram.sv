// module big_ram(input logic         clk_i, //les clock

//                input logic         pA_wb_cyc_i, //True any time a wishbone transaction is taking place
//                input logic         pA_wb_stb_i, //True for any bus transaction request, when high, the other inputs are valid!
//                input logic         pA_wb_we_i, //True for any write requests
//                input logic [10:0]  pA_wb_addr_i, //contains addr of request
//                input logic [31:0]  pA_wb_data_i, //data we want to write
//                input logic [3:0]   pA_wb_sel_i, //4 bit sel asserted by TB, which bytes within word aligned wb_addr to read
               
//                output logic        pA_wb_ack_o, //Given by device indicating shit is done, high for only ONE cycle!
//                output logic        pA_wb_stall_o, //COntrols flow of data into slave, true on any cycle when the slave cannot accept any more inputs
//                output logic [31:0] pA_wb_data_o,
               

//                input logic         pB_wb_cyc_i, //True any time a wishbone transaction is taking place
//                input logic         pB_wb_stb_i, //True for any bus transaction request, when high, the other inputs are valid!
//                input logic         pB_wb_we_i, //True for any write requests
//                input logic [10:0]  pB_wb_addr_i, //contains addr of request
//                input logic [31:0]  pB_wb_data_i, //data we want to write
//                input logic [3:0]   pB_wb_sel_i,
               
//                output logic        pB_wb_ack_o, //Given by device indicating shit is done, high for only ONE cycle!
//                output logic        pB_wb_stall_o, //Controls flow of data into slave, true on any cycle when the slave cannot accept any more inputs
//                output logic [31:0] pB_wb_data_o
//                );


//     logic [3:0] ram0_WE0, ram1_WE0; //Write enable signals
//     logic ram0_EN0, ram1_EN0; // General Enable Signals
//     logic [7:0] ram0_addr, ram1_addr;

//     logic [31:0] ram0_data_in, ram0_data_out, ram1_data_in, ram1_data_out; //RAM Data in and out
    
//     logic pAtoRAM0, pAtoRAM1, pBtoRAM0, pBtoRAM1; //Collision detection
//     logic pATriumph, pBTriumph;
    
//     logic conflict;
//     logic headbutt_winner; //Last RAM to win the conflict...

//     logic [10:0] last_pA_addr, last_pB_addr;
//     logic last_pA_strobe, last_pB_strobe;

//     logic [3:0] pA_write_enable_mask, pB_write_enable_mask;

    
//     always_comb
//     begin
//        pA_write_enable_mask = {4{pA_wb_we_i}};
//        pB_write_enable_mask = {4{pB_wb_we_i}};

//         pAtoRAM0 = ~pA_wb_addr_i[10];
//         //pAtoRAM1 =  pA_i_wb_addr[10];
   
//         pBtoRAM0 = ~pB_wb_addr_i[10];
//         //pBtoRAM1 =  pB_i_wb_addr[10];

//         conflict = (pAtoRAM0 == pBtoRAM0 && pA_wb_stb_i && pB_wb_stb_i); //|| (pAtoRAM1 && pBtoRAM1); //Conflict if both ports are accessing same RAM macro

//         //Both can triumph at the same time!
//         pATriumph = ~conflict ||  headbutt_winner; //Triumph if no conflict or it is A's turn...
//         pBTriumph = ~conflict || ~headbutt_winner;  //Trumph is no conflict or it is B's turn..

//         pA_wb_stall_o = conflict & headbutt_winner;
//         pB_wb_stall_o = conflict & ~headbutt_winner;



//         //Defaults!

//         ram0_WE0     = 4'b0;
//         ram0_EN0     = 1'b0;
//         ram0_addr    = '0;
//         ram0_data_in = '0;

//         ram1_WE0     = 4'b0;
//         ram1_EN0     = 1'b0;
//         ram1_addr    = '0;
//         ram1_data_in = '0;

//         pA_wb_ack_o  = 1'b0;
//         pB_wb_ack_o  = 1'b0;
//         pA_wb_data_o = '0;
//         pB_wb_data_o = '0;

//         ///


// // For RAM0
// if (!conflict) begin
//     if (pATriumph && pAtoRAM0) begin
//         ram0_WE0     = (pA_write_enable_mask & pA_wb_sel_i);
//         ram0_EN0     = pA_wb_stb_i;
//         ram0_addr    = pA_wb_addr_i[9:2];
//         ram0_data_in = pA_wb_data_i;
//     end else if (pBTriumph && pBtoRAM0) begin
//         ram0_WE0     = (pB_write_enable_mask & pB_wb_sel_i);
//         ram0_EN0     = pB_wb_stb_i;
//         ram0_addr    = pB_wb_addr_i[9:2];
//         ram0_data_in = pB_wb_data_i;
//     end
// end

// // For RAM1
// if (!conflict) begin
//     if (pATriumph && !pAtoRAM0) begin
//         ram1_WE0     = (pA_write_enable_mask & pA_wb_sel_i);
//         ram1_EN0     = pA_wb_stb_i;
//         ram1_addr    = pA_wb_addr_i[9:2];
//         ram1_data_in = pA_wb_data_i;
//     end else if (pBTriumph && !pBtoRAM0) begin
//         ram1_WE0     = (pB_write_enable_mask & pB_wb_sel_i);
//         ram1_EN0     = pB_wb_stb_i;
//         ram1_addr    = pB_wb_addr_i[9:2];
//         ram1_data_in = pB_wb_data_i;
//     end
// end



//         pA_wb_ack_o = last_pA_strobe;
//         pB_wb_ack_o = last_pB_strobe;

//         pA_wb_data_o = last_pA_strobe ? (last_pA_addr[10] ? ram1_data_out : ram0_data_out) : 32'h0;

//         pB_wb_data_o = last_pB_strobe ? (last_pB_addr[10] ? ram1_data_out : ram0_data_out) : 32'h0;

    
//     end
    
     


//     DFFRAM256x32 ram0 (.CLK(clk_i),  //Handles lower half of mem space
//                         .WE0(ram0_WE0),
//                         .EN0(ram0_EN0),
//                         .A0(ram0_addr),
//                         .Di0(ram0_data_in),
//                         .Do0(ram0_data_out));
    
//     DFFRAM256x32 ram1 (.CLK(clk_i), //Handle upper half of memspace hello brian
//                         .WE0(ram1_WE0),
//                         .EN0(ram1_EN0),
//                         .A0(ram1_addr),
//                         .Di0(ram1_data_in),
//                         .Do0(ram1_data_out));


//     always_ff @ (posedge clk_i) 
//     begin
//         last_pA_addr <= pA_wb_addr_i;
//         last_pB_addr <= pB_wb_addr_i;
//         last_pA_strobe <= pA_wb_stb_i;
//         last_pB_strobe <= pB_wb_stb_i;

//         if (conflict) 
//         begin
//             headbutt_winner <= ~headbutt_winner; //If there was a conflict, flip the last winner!
//         end
//     end


// endmodule


module big_ram(
    input  logic        clk_i,

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

    
    logic pAtoRAM0, pBtoRAM0; //For routing outputs from RAM modules,

    
    logic conflict;         //High when both ports are trying o 
    logic headbutt_winner;
    logic pA_go, pB_go;
    
    logic [3:0] pA_write_mask, pB_write_mask; // Write-enable masks, sign extends

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
        pAtoRAM0 = ~pA_wb_addr_i[10];
        pBtoRAM0 = ~pB_wb_addr_i[10];

        
        conflict = pA_wb_stb_i && pB_wb_stb_i && (pAtoRAM0 == pBtoRAM0); //Conflict if both strobes are high and upper bit of each matches

        pA_go = (!conflict) || headbutt_winner; //"Go ahead" signals for solving conflicts
        pB_go = (!conflict) || !headbutt_winner;

        
        pA_wb_stall_o = conflict && !pA_go; //Stall the RAM that "lost"
        pB_wb_stall_o = conflict && !pB_go;

        
        //pA_write_mask = {4{pA_wb_we_i}} & pA_wb_sel_i; //
        //pB_write_mask = {4{pB_wb_we_i}} & pB_wb_sel_i;

        // Default RAM control
        ram0_EN0  = 1'b0;
        ram0_WE0  = 4'b0000;
        ram0_A0   = 8'd0;
        ram0_Di0  = 32'd0;

        ram1_EN0  = 1'b0;
        ram1_WE0  = 4'b0000;
        ram1_A0   = 8'd0;
        ram1_Di0  = 32'd0;

        // Port A drives whichever bank it goes to if win
        if (pA_wb_stb_i && pA_go) begin
            if (pAtoRAM0) begin
                ram0_EN0  = 1'b1;
                ram0_WE0  = pA_wb_sel_i;
                ram0_A0   = pA_wb_addr_i[9:2];
                ram0_Di0  = pA_wb_data_i;
            end else begin
                ram1_EN0  = 1'b1;
                ram1_WE0  = pA_wb_sel_i;
                ram1_A0   = pA_wb_addr_i[9:2];
                ram1_Di0  = pA_wb_data_i;
            end
        end

        // Port B drives whichever bank it goes to if win
        if (pB_wb_stb_i && pB_go) begin
            if (pBtoRAM0) begin
                ram0_EN0  = 1'b1;
                ram0_WE0  = pB_wb_sel_i;
                ram0_A0   = pB_wb_addr_i[9:2];
                ram0_Di0  = pB_wb_data_i;
            end else begin
                ram1_EN0  = 1'b1;
                ram1_WE0  = pB_wb_sel_i;
                ram1_A0   = pB_wb_addr_i[9:2];
                ram1_Di0  = pB_wb_data_i;
            end
        end
    end

    always_ff @(posedge clk_i) begin

        if (conflict)
            headbutt_winner <= ~headbutt_winner;

        // Port A request latch
        if (pA_wb_stb_i) 
        begin
            pA_req        <= 1'b1;
            pA_req_bank0  <= pAtoRAM0;
            pA_req_addr   <= pA_wb_addr_i[9:2];
        end 
        
        else if (pA_req) 
        begin
            
            pA_req <= 1'b0;
        end

        // Port B request latch
        if (pB_wb_stb_i) 
        begin
            pB_req        <= 1'b1;
            pB_req_bank0  <= pBtoRAM0;
            pB_req_addr   <= pB_wb_addr_i[9:2];
        end 
        
        else if (pB_req) 
        begin
            pB_req <= 1'b0;
        end

        // Issue ACKs
        pA_wb_ack_o <= pA_req;
        pB_wb_ack_o <= pB_req;

        // Route read data
        if (pA_req) 
        begin
            if (pA_req_bank0) 
            begin
                pA_wb_data_o <= ram0_Do0;
            end 
            else 
            
            begin
            pA_wb_data_o <= ram1_Do0;
            end

        end 
        else 
        begin
            pA_wb_data_o <= 32'd0;
        end

        if (pB_req) 
        begin
            if (pB_req_bank0) 
            begin
                pB_wb_data_o <= ram0_Do0;
            end 

            else 
            begin
                pB_wb_data_o <= ram1_Do0;
            end
        end 
        else 
        begin
            pB_wb_data_o <= 32'd0;
        end
    end


endmodule
