//--------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// top.v
//--------------------------------------------------------
// VERSION = 2018.07.02.
//--------------------------------------------------------
// Macros
//--------------------------------------------------------
// Note:
//--------------------------------------------------------
`timescale 1ns/1ns

`ifndef CLOCK_FREQ
`define CLOCK_FREQ  50000000
`endif

module top;
   //--------------------------------------------------------
   `ifdef VCD
   initial begin
         $display("VCD dump enable.");
         $dumpfile("wave.vcd");
   end
   `endif
   //--------------------------------------------------------
   reg              CLK     = 1'b0;
   reg              RESET_N = 1'b0;
   //--------------------------------------------------------
   localparam CLOCK_FREQ=`CLOCK_FREQ;
   localparam CLOCK_PERIOD_HALF=1000000000/(CLOCK_FREQ*2);
   //-----------------------------------------------------
   always #CLOCK_PERIOD_HALF CLK <= ~CLK;
   //--------------------------------------------------------
   wire         PRESETn   = RESET_N;
   wire         PCLK      = CLK;
   reg   [31:0] PADDR     = 0;
   reg          PWRITE    = 0;
   reg   [31:0] PWDATA    = 0;
   wire  [31:0] PRDATA    ;
   reg          PSEL      = 0;
   reg          PENABLE   = 0;
   wire         IRQ       ;
   //--------------------------------------------------------
   wire         MDC     ;
   wire         MDIO    ; pullup Umdio(MDIO);
   wire         core_MDIO_O  ;
   wire         core_MDIO_T  ;// active-low output enable
   wire         slv_MDIO_O  ;
   wire         slv_MDIO_T  ;// active-low output enable
   //--------------------------------------------------------
   assign MDIO = (core_MDIO_T==1'b0) ? core_MDIO_O
                                     : (slv_MDIO_T==1'b0) ? slv_MDIO_O
                                     : 1'bZ;
   //--------------------------------------------------------
   mdio_apb #(.P_CLK_FREQ(CLOCK_FREQ))
   u_mdio_apb (
        .PRESETn  (PRESETn  )
      , .PCLK     (PCLK     )
      , .PSEL     (PSEL     )
      , .PENABLE  (PENABLE  )
      , .PADDR    (PADDR    )
      , .PWRITE   (PWRITE   )
      , .PWDATA   (PWDATA   )
      , .PRDATA   (PRDATA   )
      , .IRQ      (IRQ      )
      , .MDC      (MDC      )
      , .MDIO_I   (MDIO     )
      , .MDIO_O   (core_MDIO_O   )
      , .MDIO_T   (core_MDIO_T   )// active-low output enable
   );
   //--------------------------------------------------------
   mdio_slave #(.PHYADR(5'h1))
   Umdio_slave (
       .MDC    (MDC   )
     , .MDIO_I (MDIO  )
     , .MDIO_O (slv_MDIO_O)
     , .MDIO_T (slv_MDIO_T) // active-low output enable
   );
   //--------------------------------------------------------
   reg [15:0] rdata = ~'h0;
   reg [15:0] wdata = ~'h0;
   reg [ 5:0] padr  = 5'h1;// physical address
   reg [ 5:0] radr  = 0;// register address
   reg [ 4:0] CLKDIV= 0;
   //--------------------------------------------------------
   initial begin
       RESET_N = 1'b0;
       repeat (3) @ (posedge PCLK);
       RESET_N = 1'b1;
       repeat (3) @ (posedge PCLK);
       mdio_csr_check();
       repeat (10) @ (posedge CLK);
        for (CLKDIV=0; CLKDIV<5'd3; CLKDIV=CLKDIV+1) begin
        for (radr=0; radr<5; radr=radr+1) begin // do not exceed 32
           repeat (10) @ (posedge CLK);
           wdata = $random&16'hFFFF;
           mdio_write(padr,radr,wdata);
           repeat (20) @ (posedge CLK);
           mdio_read(padr,radr,rdata);
           if (wdata!=rdata) $display($time,,"ERROR mismatch");
           else              $display($time,,"OK matched 0x%04x", rdata);
           repeat (10) @ (posedge CLK);
        end
        end
       repeat (10) @ (posedge CLK);
       $finish(2);
   end
   //--------------------------------------------------------
   `ifdef VCD
    initial begin
         $dumpvars(0);
    end
   `endif
   //--------------------------------------------------------
   `include "apb_tasks.v"
   //--------------------------------------------------------
   localparam CSRA_BASE           = 32'h00;
   localparam CSRA_NAME0          = CSRA_BASE + 8'h00,
              CSRA_NAME1          = CSRA_BASE + 8'h04,
              CSRA_NAME2          = CSRA_BASE + 8'h08,
              CSRA_NAME3          = CSRA_BASE + 8'h0C,
              CSRA_COMP0          = CSRA_BASE + 8'h10,
              CSRA_COMP1          = CSRA_BASE + 8'h14,
              CSRA_COMP2          = CSRA_BASE + 8'h18,
              CSRA_COMP3          = CSRA_BASE + 8'h1C,
              CSRA_VERSION        = CSRA_BASE + 8'h20,
              CSRA_MDIO_CONTROL   = CSRA_BASE + 8'h30,
              CSRA_MDIO_STATUS    = CSRA_BASE + 8'h34,
              CSRA_MDIO_WR_CMD    = CSRA_BASE + 8'h38,
              CSRA_MDIO_RD_CMD    = CSRA_BASE + 8'h3C;
   //--------------------------------------------------------
   task mdio_check_default;
        input [31:0] addr;
        input [99:0] msg;
        input [31:0] eval;
        reg   [31:0] rval;
   begin
        apb_read(addr, rval); 
        if (rval==eval) $display("CSR %s A:0x%08x D:0x%08x, OK", msg, addr, rval);
        else            $display("CSR %s A:0x%08x D:0x%08x, but 0x%08x expected", msg, addr, rval, eval);
   end
   endtask
   //--------------------------------------------------------
   task mdio_csr_check;
        reg [15:0] div;
   begin
        div = CLOCK_FREQ/(2*u_mdio_apb.u_csr.P_MDC_FREQ)-1;
        mdio_check_default(CSRA_NAME0       ,"NAME0       ", "MDIO" );
        mdio_check_default(CSRA_NAME1       ,"NAME1       ", "AMBA" );
        mdio_check_default(CSRA_NAME2       ,"NAME2       ", "    " );
        mdio_check_default(CSRA_NAME3       ,"NAME3       ", "    " );
        mdio_check_default(CSRA_COMP0       ,"COMP0       ", "FUTU" );
        mdio_check_default(CSRA_COMP1       ,"COMP1       ", "RE D" );
        mdio_check_default(CSRA_COMP2       ,"COMP2       ", "ESIG" );
        mdio_check_default(CSRA_COMP3       ,"COMP3       ", "N   " );
        mdio_check_default(CSRA_VERSION     ,"VERSION     ", 32'h2018_1011 );
        mdio_check_default(CSRA_MDIO_CONTROL,"MDIO_CONTROL", {16'h0000,div});
        mdio_check_default(CSRA_MDIO_STATUS ,"MDIO_STATUS ", 32'h0000_0000 );
        mdio_check_default(CSRA_MDIO_WR_CMD ,"MDIO_WR_CMD ", 32'hD400_0000 );
        mdio_check_default(CSRA_MDIO_RD_CMD ,"MDIO_RD_CMD ", 32'hD800_0000 );
   end
   endtask
   //--------------------------------------------------------
   task mdio_write;
        input [ 4:0] phyadr;
        input [ 4:0] regadr;
        input [15:0] data;
        reg   [31:0] dataR, dataW;
   begin
        $display($time,,"%m write P=0x%02x R=0x%02x D=0x%04x", phyadr, regadr, data);
        dataW = 1<<31; // enable
        apb_write(CSRA_MDIO_CONTROL, dataW);
        dataW[25:21] = phyadr;
        dataW[20:16] = regadr;
        dataW[15:0]  = data;
        apb_write(CSRA_MDIO_WR_CMD, dataW);
        dataR = 0;
        while (dataR[1]==1'b0) apb_read(CSRA_MDIO_STATUS, dataR);
   end
   endtask
   //--------------------------------------------------------
   task mdio_read;
        input       [ 4:0] phyadr;
        input       [ 4:0] regadr;
        output reg  [15:0] data;
        reg         [31:0] dataW, dataR;
   begin
        $display($time,,"%m read P=0x%02x R=0x%02x D=0x%04x", phyadr, regadr, data);
        dataW = 1<<31; // enable
        apb_write(CSRA_MDIO_CONTROL, dataW);
        dataW[25:21] = phyadr;
        dataW[20:16] = regadr;
        dataW[15:0]  = 'h0;
        apb_write(CSRA_MDIO_RD_CMD, dataW);
        dataR = 0;
        while (dataR[1]==1'b0) apb_read(CSRA_MDIO_STATUS, dataR);
        apb_read(CSRA_MDIO_RD_CMD, dataR);
        data = dataR[15:0];
   end
   endtask
   //--------------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
