//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// top.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
//------------------------------------------------------------------------------
//                 gig_eth_hsr
//  +------+      +---------+
//  |      |      |         |
//  |      |      |     RX-A|<===========\\
//  |      |      |         |            ||
//  |      |      |         |            ||
//  |      |      |     TX-A|=====\\     ||
//  |      |      |         |     ||     ||
//  |      |=====>|RX-H     |    |\/|   +--+
//  | GMII |      |         |    +--+   +--+
//  | BFM  |      |         | A2B+--+B2A+--+
//  |      |<=====|TX-H     |    +--+   |/\|
//  |      |      |         |     ||     ||
//  |      |      |     RX-B|<====//     ||
//  |      |      |         |            ||
//  |      |      |         |            ||
//  |      |      |     TX-B|============//
//  |      |      |         |
//  +------+      +---------+
//------------------------------------------------------------------------------
`include "simple_phy.v"
`timescale 1ns/1ps

`ifndef FPGA_FAMILY
`define FPGA_FAMILY         "VIRTEX6"
`endif
`ifndef TXCLK_INV
`define TXCLK_INV           1'b0
`endif

module top;
   //---------------------------------------------------------------------------
   reg  RESET_N=1'b0;
   reg  CLK125M=1'b0;
   //---------------------------------------------------------------------------
   localparam CLK125_FREQ=125_000_000;
   localparam CLK125_PERIOD_HALF=1_000_000_000/(CLK125_FREQ*2);
   //---------------------------------------------------------------------------
   always #CLK125_PERIOD_HALF CLK125M <= ~CLK125M;
   //---------------------------------------------------------------------------
   wire    CLK125M_0  =CLK125M;
   wire #2 CLK125M_90 =CLK125M;
   wire #4 CLK125M_180=CLK125M;
   wire #2 CLK125M_270=CLK125M_180;
   //---------------------------------------------------------------------------
   wire              phy_resetU_n;
   wire              phy_resetA_n;
   wire              phy_resetB_n;
   reg  [47:0]       mac_addr=48'h0;
   wire              gtx_clk=CLK125M_0;
   wire              gmiiU_gtxc;
   wire  [7:0]  #1   gmiiU_txd ;
   wire         #1   gmiiU_txen;
   wire         #1   gmiiU_txer;
   wire              gmiiU_rxc ;
   wire              gmiiU_rxc_gated = (phy_resetU_n==1'b1) ? gmiiU_rxc : 1'b0;
   wire  [7:0]  #1   gmiiU_rxd ;
   wire         #1   gmiiU_rxdv;
   wire         #1   gmiiU_rxer;
   wire         #1   gmiiU_col=1'b0;
   wire         #1   gmiiU_crs=1'b0;
   wire              gmiiA_gtxc;
   wire  [7:0]  #1   gmiiA_txd ;
   wire         #1   gmiiA_txen;
   wire         #1   gmiiA_txer;
   wire              gmiiA_rxc =(phy_resetA_n==1'b1) ? CLK125M_90 : 1'b0;
   wire  [7:0]  #1   gmiiA_rxd ;
   wire         #1   gmiiA_rxdv;
   wire         #1   gmiiA_rxer;
   wire         #1   gmiiA_col=1'b0;
   wire         #1   gmiiA_crs=1'b0;
   wire              gmiiB_gtxc;
   wire  [7:0]  #1   gmiiB_txd ;
   wire         #1   gmiiB_txen;
   wire         #1   gmiiB_txer;
   wire              gmiiB_rxc =(phy_resetB_n==1'b1) ? CLK125M_270 : 1'b0;
   wire  [7:0]  #1   gmiiB_rxd ;
   wire         #1   gmiiB_rxdv;
   wire         #1   gmiiB_rxer;
   wire         #1   gmiiB_col=1'b0;
   wire         #1   gmiiB_crs=1'b0;
   //---------------------------------------------------------------------------
   wire         PRESETn=RESET_N;
   wire         PCLK=gtx_clk;
   wire         PSEL        ;
   wire         PENABLE     ;
   wire  [31:0] PADDR       ;
   wire         PWRITE      ;
   wire  [31:0] PWDATA      ;
   wire  [31:0] PRDATA      ;
   //---------------------------------------------------------------------------
   gig_eth_hsr #(.FPGA_FAMILY(`FPGA_FAMILY)
                ,.TXCLK_INV(`TXCLK_INV)
                ,.DANH_OR_REDBOX("REDBOX")
                ,.CONF_MAC_ADDR(48'hF0_12_34_56_78_00)// only valid when DANH_OR_REDBOX="DANH"
                ,.CONF_HSR_NET_ID(3'h0)
                ,.CONF_PROMISCUOUS(1'b0)// promiscuos when 1
                ,.CONF_DROP_NON_HSR(1'b1)// drop non-hsr packet when 1
                ,.CONF_HSR_QR(1'b1)// Quick Remove enabled when 1
                ,.CONF_SNOOP(1'b0)
                )
   u_hsr (
       .reset_n     ( RESET_N     )
     , .gtx_clk     ( gtx_clk     )
     , .board_id    ( 8'hAB       )
     , .hsr_ready   (             )
     , .phy_resetU_n( phy_resetU_n)
     , .phy_resetA_n( phy_resetA_n)
     , .phy_resetB_n( phy_resetB_n)
     , .phy_readyU  (             )
     , .phy_readyA  (             )
     , .phy_readyB  (             )
     , .gmiiU_gtxc  ( gmiiU_gtxc  )
     , .gmiiU_txd   ( gmiiU_txd   )
     , .gmiiU_txen  ( gmiiU_txen  )
     , .gmiiU_txer  ( gmiiU_txer  )
     , .gmiiU_rxc   ( gmiiU_rxc_gated )
     , .gmiiU_rxd   ( gmiiU_rxd   )
     , .gmiiU_rxdv  ( gmiiU_rxdv  )
     , .gmiiU_rxer  ( gmiiU_rxer  )
     , .gmiiU_col   ( gmiiU_col   )
     , .gmiiU_crs   ( gmiiU_crs   )
     , .gmiiA_gtxc  ( gmiiA_gtxc  )
     , .gmiiA_txd   ( gmiiA_txd   )
     , .gmiiA_txen  ( gmiiA_txen  )
     , .gmiiA_txer  ( gmiiA_txer  )
     , .gmiiA_rxc   ( gmiiA_rxc   )
     , .gmiiA_rxd   ( gmiiA_rxd   )
     , .gmiiA_rxdv  ( gmiiA_rxdv  )
     , .gmiiA_rxer  ( gmiiA_rxer  )
     , .gmiiA_col   ( gmiiA_col   )
     , .gmiiA_crs   ( gmiiA_crs   )
     , .gmiiB_gtxc  ( gmiiB_gtxc  )
     , .gmiiB_txd   ( gmiiB_txd   )
     , .gmiiB_txen  ( gmiiB_txen  )
     , .gmiiB_txer  ( gmiiB_txer  )
     , .gmiiB_rxc   ( gmiiB_rxc   )
     , .gmiiB_rxd   ( gmiiB_rxd   )
     , .gmiiB_rxdv  ( gmiiB_rxdv  )
     , .gmiiB_rxer  ( gmiiB_rxer  )
     , .gmiiB_col   ( gmiiB_col   )
     , .gmiiB_crs   ( gmiiB_crs   )
     
     , .PRESETn     ( PRESETn     )
     , .PCLK        ( PCLK        )
     , .PSEL        ( PSEL        )
     , .PENABLE     ( PENABLE     )
     , .PADDR       ( PADDR       )
     , .PWRITE      ( PWRITE      )
     , .PWDATA      ( PWDATA      )
     , .PRDATA      ( PRDATA      )
     `ifdef HSR_PERFORMANCE
     , .host_probe_txen ()
     , .host_probe_rxdv ()
     , .netA_probe_txen ()
     , .netA_probe_rxdv ()
     , .netB_probe_txen ()
     , .netB_probe_rxdv ()
     `endif
   );
   //---------------------------------------------------------------------------
   // loopback connections
   simple_phy
   u_phy_A (
       .reset_n   ( RESET_N )
     , .gmii_rxc  ( gmiiA_gtxc )
     , .gmii_rxd  ( gmiiA_txd  )
     , .gmii_rxdv ( gmiiA_txen )
     , .gmii_rxer ( gmiiA_txer )
     , .gmii_gtxc ( gmiiB_rxc  )
     , .gmii_txd  ( gmiiB_rxd  )
     , .gmii_txen ( gmiiB_rxdv )
     , .gmii_txer ( gmiiB_rxer )
   );
   simple_phy
   u_phy_B (
       .reset_n   ( RESET_N )
     , .gmii_rxc  ( gmiiB_gtxc )
     , .gmii_rxd  ( gmiiB_txd  )
     , .gmii_rxdv ( gmiiB_txen )
     , .gmii_rxer ( gmiiB_txer )
     , .gmii_gtxc ( gmiiA_rxc  )
     , .gmii_txd  ( gmiiA_rxd  )
     , .gmii_txen ( gmiiA_rxdv )
     , .gmii_txer ( gmiiA_rxer )
   );
   //---------------------------------------------------------------------------
   wire done;
   //---------------------------------------------------------------------------
   tester_gmii
   u_tester (
       .reset     (~RESET_N    )
     , .gmii_gtxc ( gmiiU_rxc  )
     , .gmii_txd  ( gmiiU_rxd  )
     , .gmii_txen ( gmiiU_rxdv )
     , .gmii_txer ( gmiiU_rxer )
     , .gmii_rxc  ( gmiiU_gtxc )
     , .gmii_rxd  ( gmiiU_txd  )
     , .gmii_rxdv ( gmiiU_txen )
     , .gmii_rxer ( gmiiU_txer )
     , .done      ( done       )
     , .PCLK      ( PCLK       )
     , .PSEL      ( PSEL       )
     , .PENABLE   ( PENABLE    )
     , .PADDR     ( PADDR      )
     , .PWRITE    ( PWRITE     )
     , .PWDATA    ( PWDATA     )
     , .PRDATA    ( PRDATA     )
   );
   //---------------------------------------------------------------------------
   initial begin
        RESET_N = 1'b0;
        repeat (13) @ (posedge gmiiU_gtxc);
        RESET_N = 1'b1;
        repeat (10) @ (posedge gmiiU_gtxc);
        //-------------------------------------
        wait (done==1'b1);
        //-------------------------------------
        repeat (50) @ (posedge gmiiU_gtxc);
        $finish(2);
   end
   //---------------------------------------------------------------------------
   `ifdef VCD
   initial begin
         $display("VCD dump enable.");
         $dumpfile("wave.vcd");
         $dumpvars(0);
       //$dumpoff;
       //#(3800*1000);
       //$dumpon;
       //#(2*1000*1000);
       //$dumpoff;
   end
   `endif
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.25: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
