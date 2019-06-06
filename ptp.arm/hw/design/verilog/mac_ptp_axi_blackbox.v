//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// mac_ptp_axi.v
//------------------------------------------------------------------------------
// VERSION: 2018.03.12.
//------------------------------------------------------------------------------
module mac_ptp_axi
(
       input   wire          BOARD_RST_SW // synthesis xc_pulldown = 1 (active-high)
     , input   wire          BOARD_CLK_IN // reference clock input (100)
     , input   wire  [ 7:0]  BOARD_SLIDE_SW
     , output  wire  [ 7:0]  BOARD_LED
     , input   wire          BOARD_BTND /* synthesis xc_pulldown = 1*/
     , input   wire          BOARD_BTNU /* synthesis xc_pulldown = 1*/
     //-------------------------------------------------------------------------
     , output  wire          GBE_MDC  /* synthesis xc_pullup = 1 */
     , inout   wire          GBE_MDIO /* synthesis xc_pullup = 1 */
     //-------------------------------------------------------------------------
     , output  wire          GBEU_PHY_RESET_N /* synthesis xc_pullup = 1 */
     , output  wire          GBEU_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 7:0]  GBEU_TXD
     , output  wire          GBEU_TXEN
     , output  wire          GBEU_TXER
     , input   wire          GBEU_RXC
     , input   wire  [ 7:0]  GBEU_RXD
     , input   wire          GBEU_RXDV
     , input   wire          GBEU_RXER
     //-------------------------------------------------------------------------
     , output  wire          PTP_PPS  // PMOD1 JA3 (Y10)
     , output  wire          PTP_PPUS // PMOD1 JA4 (AA9)
     , output  wire          IRQ_GMAC
     , output  wire          IRQ_PTP
     , output  wire          IRQ_RTC
     , output  wire          IRQ_GPIO
     , output  wire  [ 3:0]  IRQ_TIMER
     , output  wire          IRQ_SWD
     , output  wire          IRQ_SWU
     //-------------------------------------------------------------------------
     , output  wire          s_axi_aresetn
     , output  wire          s_axi_aclk
     , input   wire  [31:0]  s_axi_awaddr
     , input   wire  [ 7:0]  s_axi_awlen
     , input   wire          s_axi_awlock
     , input   wire  [ 2:0]  s_axi_awsize
     , input   wire  [ 1:0]  s_axi_awburst
     , input   wire  [ 3:0]  s_axi_awcache
     , input   wire  [ 2:0]  s_axi_awprot
     , input   wire          s_axi_awvalid
     , output  wire          s_axi_awready
     , input   wire  [31:0]  s_axi_wdata
     , input   wire  [ 3:0]  s_axi_wstrb
     , input   wire          s_axi_wlast
     , input   wire          s_axi_wvalid
     , output  wire          s_axi_wready
     , output  wire  [ 1:0]  s_axi_bresp
     , output  wire          s_axi_bvalid
     , input   wire          s_axi_bready
     , input   wire  [31:0]  s_axi_araddr
     , input   wire  [ 7:0]  s_axi_arlen
     , input   wire          s_axi_arlock
     , input   wire  [ 2:0]  s_axi_arsize
     , input   wire  [ 1:0]  s_axi_arburst
     , input   wire  [ 3:0]  s_axi_arcache
     , input   wire  [ 2:0]  s_axi_arprot
     , input   wire          s_axi_arvalid
     , output  wire          s_axi_arready
     , output  wire  [31:0]  s_axi_rdata
     , output  wire  [ 1:0]  s_axi_rresp
     , output  wire          s_axi_rlast
     , output  wire          s_axi_rvalid
     , input   wire          s_axi_rready

);
    //--------------------------------------------------------------------------
    // synthesis attribute box_type mac_ptp_axi "black_box"
    //--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.05.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
