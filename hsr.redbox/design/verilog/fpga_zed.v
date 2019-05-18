//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fpga_ml605.v
//------------------------------------------------------------------------------
// VERSION: 2018.09.07.
//------------------------------------------------------------------------------
`include "defines_system.v"
`include "clkmgra.v"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
`ifdef VIVADO
`define IOB_DEF (* IOB="true" *)
`define DBG_HSR (* mark_debug="true" *)
`elsif ISE
`define IOB_DEF
`define DBG_HSR
`else
`error VIVADO or ISE should be defined.
`endif

//------------------------------------------------------------------------------
`ifndef FPGA_FAMILY
`define FPGA_FAMILY "ZYNQ7000"
`define XILINIX_Z7
`endif

//------------------------------------------------------------------------------
module fpga
     #(parameter FPGA_FAMILY=`FPGA_FAMILY
               , TXCLK_INV=`TXCLK_INV
               , NUM_ENTRIES_PROXY=`NUM_ENTRIES_PROXY
               , NUM_ENTRIES_QR   =`NUM_ENTRIES_QR
               , DANH_OR_REDBOX   =`DANH_OR_REDBOX
               , CONF_PROMISCUOUS =1'b0 // promiscuos when 1
               , CONF_DROP_NON_HSR=1'b1 // drop non-hsr packet when 1
               , CONF_HSR_QR      =1'b1 // Quick Remove enabled when 1
               , CONF_SNOOP       =1'b0
               )
(
     //-------------------------------------------------------------------------
       input   wire          CLK100
     , input   wire          BOARD_RST_SW /* synthesis xc_pulldown = 1 */
     , input   wire  [ 7:0]  BOARD_SLIDE_SW
     , output  wire  [ 7:0]  BOARD_LED
     //-------------------------------------------------------------------------
     , output  reg           GBE_MDC=1'b1 /* synthesis xc_pullup = 1 */
     , inout   wire          GBE_MDIO
     //-------------------------------------------------------------------------
     , output  wire          GBEA_PHY_RESET_N /* synthesis xc_pullup = 1 */
     `ifdef RGMII
     , output  wire          GBEA_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 3:0]  GBEA_TXD
     , output  wire          GBEA_TXCTL
     , input   wire          GBEA_RXC
     , input   wire  [ 3:0]  GBEA_RXD
     , input   wire          GBEA_RXCTL
     `else
     , output  wire          GBEA_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 7:0]  GBEA_TXD
     , output  wire          GBEA_TXEN
     , output  wire          GBEA_TXER
     , input   wire          GBEA_RXC
     , input   wire  [ 7:0]  GBEA_RXD
     , input   wire          GBEA_RXDV
     , input   wire          GBEA_RXER
     `endif
     //-------------------------------------------------------------------------
     , output  wire          GBEB_PHY_RESET_N /* synthesis xc_pullup = 1 */
     `ifdef RGMII
     , output  wire          GBEB_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 3:0]  GBEB_TXD
     , output  wire          GBEB_TXCTL
     , input   wire          GBEB_RXC
     , input   wire  [ 3:0]  GBEB_RXD
     , input   wire          GBEB_RXCTL
     `else
     , output  wire          GBEB_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 7:0]  GBEB_TXD
     , output  wire          GBEB_TXEN
     , output  wire          GBEB_TXER
     , input   wire          GBEB_RXC
     , input   wire  [ 7:0]  GBEB_RXD
     , input   wire          GBEB_RXDV
     , input   wire          GBEB_RXER
     `endif
     //-------------------------------------------------------------------------
     , output  wire          GBEU_PHY_RESET_N /* synthesis xc_pullup = 1 */
     `ifdef RGMII
     , output  wire          GBEU_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 3:0]  GBEU_TXD
     , output  wire          GBEU_TXCTL
     , input   wire          GBEU_RXC
     , input   wire  [ 3:0]  GBEU_RXD
     , input   wire          GBEU_RXCTL
     `else
     , output  wire          GBEU_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 7:0]  GBEU_TXD
     , output  wire          GBEU_TXEN
     , output  wire          GBEU_TXER
     , input   wire          GBEU_RXC
     , input   wire  [ 7:0]  GBEU_RXD
     , input   wire          GBEU_RXDV
     , input   wire          GBEU_RXER
     `endif
     //-------------------------------------------------------------------------
    `ifdef HSR_PERFORMANCE
     , output wire           host_probe_txen // JA1   (Y11 )
     , output wire           host_probe_rxdv // JA2   (AA11)
     , output wire           netA_probe_txen // JA7   (AB11)
     , output wire           netA_probe_rxdv // JA8   (AB10)
     , output wire           netB_probe_txen // JA9   (AB9 )
     , output wire           netB_probe_rxdv // JA10  (AA8 )
     `endif
     //-------------------------------------------------------------------------
     `ifdef DEBUG
     , output  wire  [ 7:0]  FPGA_GPIO_A // synthesis attribute keep of FPGA_GPIO_A is "true";
     `endif
);
    //--------------------------------------------------------------------------
    `DBG_HSR wire RESET_N;
    `DBG_HSR wire LOCKED ;
             wire clk125mhz;
    `DBG_HSR wire hsr_ready;
    //--------------------------------------------------------------------------
    assign RESET_N = LOCKED&~BOARD_RST_SW;
    assign BOARD_LED={4'h0
                     ,CONF_SNOOP[0] // 3
                     ,(DANH_OR_REDBOX=="DANH") // 2
                     ,(DANH_OR_REDBOX=="REDBOX") // 1
                     ,hsr_ready}; // 0
    //--------------------------------------------------------------------------
    clkmgra #(.INPUT_CLOCK_FREQ(100_000_000)
             ,.SYSCLK_FREQ     ( 80_000_000)
             ,.CLKOUT1_FREQ    (100_000_000) // it does not affect for SPARTAN6
             ,.CLKOUT2_FREQ    (125_000_000)
             ,.CLKOUT3_FREQ    ( 50_000_000)
             ,.CLKOUT4_FREQ    (250_000_000)
             ,.FPGA_FAMILY     (FPGA_FAMILY))// ARTIX7, VIRTEX6, SPARTAN6
    u_clkmgr (
           .OSC_IN         ( CLK100           )
         , .OSC_OUT        (  )
         , .SYS_CLK_OUT    (                  )
         , .CLKOUT1        (                  )
         , .CLKOUT2        ( clk125mhz        )
         , .CLKOUT3        (  )
         , .CLKOUT4        (  )
         , .SYS_CLK_LOCKED ( LOCKED           )
    );
    //--------------------------------------------------------------------------
    `ifdef RGMII
    `else
    gig_eth_hsr_redbox
                       `ifdef SIM
                       #(.NUM_ENTRIES_PROXY     (NUM_ENTRIES_PROXY)// should be power of 2
                        ,.NUM_ENTRIES_QR        (NUM_ENTRIES_QR   )// should be power of 2
                        ,.FPGA_FAMILY           (FPGA_FAMILY)
                        ,.TXCLK_INV             (TXCLK_INV)
                        ,.CONF_MAC_ADDR         (48'hF0_12_34_56_78_9A)// only valid when DANH_OR_REDBOX="DANH"
                        ,.CONF_HSR_NET_ID       (3'h0)
                        ,.DANH_OR_REDBOX        (DANH_OR_REDBOX   )
                        ,.CONF_PROMISCUOUS      (CONF_PROMISCUOUS )// promiscuos when 1
                        ,.CONF_DROP_NON_HSR     (CONF_DROP_NON_HSR)// drop non-hsr packet when 1
                        ,.CONF_HSR_QR           (CONF_HSR_QR      )// Quick Remove enabled when 1
                        ,.CONF_SNOOP            (CONF_SNOOP       )// remove HSR head when 0
                        )
                        `endif
    u_hsr (
           .gtx_clk      ( clk125mhz      )
         , .reset_n      ( RESET_N        )
         , .board_id     ( BOARD_SLIDE_SW )
         , .hsr_ready    ( hsr_ready      )
         , .phy_resetU_n ( GBEU_PHY_RESET_N )
         , .phy_resetA_n ( GBEA_PHY_RESET_N )
         , .phy_resetB_n ( GBEB_PHY_RESET_N )
         , .phy_readyU   (                  )
         , .phy_readyA   (                  )
         , .phy_readyB   (                  )

         , .gmiiU_gtxc  ( GBEU_GTXC )
         , .gmiiU_txd   ( GBEU_TXD  )
         , .gmiiU_txen  ( GBEU_TXEN )
         , .gmiiU_txer  ( GBEU_TXER )
         , .gmiiU_rxc   ( GBEU_RXC  )
         , .gmiiU_rxd   ( GBEU_RXD  )
         , .gmiiU_rxdv  ( GBEU_RXDV )
         , .gmiiU_rxer  ( GBEU_RXER )
         , .gmiiU_col   ( 1'b0      )
         , .gmiiU_crs   ( 1'b0      )

         , .gmiiA_gtxc  ( GBEA_GTXC )
         , .gmiiA_txd   ( GBEA_TXD  )
         , .gmiiA_txen  ( GBEA_TXEN )
         , .gmiiA_txer  ( GBEA_TXER )
         , .gmiiA_rxc   ( GBEA_RXC  )
         , .gmiiA_rxd   ( GBEA_RXD  )
         , .gmiiA_rxdv  ( GBEA_RXDV )
         , .gmiiA_rxer  ( GBEA_RXER )
         , .gmiiA_col   ( 1'b0      )
         , .gmiiA_crs   ( 1'b0      )

         , .gmiiB_gtxc  ( GBEB_GTXC )
         , .gmiiB_txd   ( GBEB_TXD  )
         , .gmiiB_txen  ( GBEB_TXEN )
         , .gmiiB_txer  ( GBEB_TXER )
         , .gmiiB_rxc   ( GBEB_RXC  )
         , .gmiiB_rxd   ( GBEB_RXD  )
         , .gmiiB_rxdv  ( GBEB_RXDV )
         , .gmiiB_rxer  ( GBEB_RXER )
         , .gmiiB_col   ( 1'b0      )
         , .gmiiB_crs   ( 1'b0      )

         , .PRESETn     ( RESET_N   )
         , .PCLK        ( clk125mhz )
         , .PSEL        ( 1'b0      )
         , .PENABLE     ( 1'b0      )
         , .PADDR       ( 32'h0     )
         , .PWRITE      ( 1'b0      )
         , .PWDATA      ( 32'b0     )
         , .PRDATA      (  )

         `ifdef HSR_PERFORMANCE
         , .host_probe_txen(host_probe_txen)
         , .host_probe_rxdv(host_probe_rxdv)
         , .netA_probe_txen(netA_probe_txen)
         , .netA_probe_rxdv(netA_probe_rxdv)
         , .netB_probe_txen(netB_probe_txen)
         , .netB_probe_rxdv(netB_probe_rxdv)
         `endif
    );
    `endif
    //--------------------------------------------------------------------------
    // synthesis translate_off
    real stamp_x, stamp_y, stamp_z;
    initial begin
         wait (RESET_N==1'b0);
         wait (RESET_N==1'b1);
         repeat (5) @ (posedge CLK100);
         @ (posedge CLK100); stamp_x = $realtime;
         @ (posedge CLK100); stamp_y = $realtime;
         stamp_z = stamp_y - stamp_x;
         $display("%m CLK100 %.2f-nsec %.2f-MHz", stamp_z, 1000.0/stamp_z);
         repeat (5) @ (posedge clk125mhz);
         @ (posedge clk125mhz); stamp_y = $realtime;
         @ (posedge clk125mhz); stamp_x = $realtime;
         @ (posedge clk125mhz); stamp_y = $realtime;
         stamp_z = stamp_y - stamp_x;
         $display("%m clk125mhz %.2f-nsec %.2f-MHz", stamp_z, 1000.0/stamp_z);
         $fflush();
    end
    // synthesis translate_on
    //--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.09.07: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
