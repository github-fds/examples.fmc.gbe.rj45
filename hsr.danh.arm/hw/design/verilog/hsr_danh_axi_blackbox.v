//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// hsr_danh_axi.v
//------------------------------------------------------------------------------
// VERSION: 2018.03.12.
//------------------------------------------------------------------------------
module hsr_danh_axi
(
       input   wire          BOARD_RST_SW // synthesis xc_pulldown = 1
     , input   wire          BOARD_CLK_IN // reference clock input (100)
     , input   wire  [ 7:0]  BOARD_SLIDE_SW
     , output  wire  [ 7:0]  BOARD_LED
     //-------------------------------------------------------------------------
     , output  wire          GBE_MDC      /* synthesis xc_pullup = 1 */
     , inout   wire          GBE_MDIO /* synthesis xc_pullup = 1 */
     //-------------------------------------------------------------------------
     , output  wire          GBEA_PHY_RESET_N /* synthesis xc_pullup = 1 */
     , output  wire          GBEA_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 7:0]  GBEA_TXD
     , output  wire          GBEA_TXEN
     , output  wire          GBEA_TXER
     , input   wire          GBEA_RXC
     , input   wire  [ 7:0]  GBEA_RXD
     , input   wire          GBEA_RXDV
     , input   wire          GBEA_RXER
     //-------------------------------------------------------------------------
     , output  wire          GBEB_PHY_RESET_N /* synthesis xc_pullup = 1 */
     , output  wire          GBEB_GTXC // Gigabit TX Clock  (output)
     , output  wire  [ 7:0]  GBEB_TXD
     , output  wire          GBEB_TXEN
     , output  wire          GBEB_TXER
     , input   wire          GBEB_RXC
     , input   wire  [ 7:0]  GBEB_RXD
     , input   wire          GBEB_RXDV
     , input   wire          GBEB_RXER
    //--------------------------------------------------------------------------
     , output wire           host_probe_txen // JA1   (Y11 )
     , output wire           host_probe_rxdv // JA2   (AA11)
     , output wire           netA_probe_txen // JA7   (AB11)
     , output wire           netA_probe_rxdv // JA8   (AB10)
     , output wire           netB_probe_txen // JA9   (AB9 )
     , output wire           netB_probe_rxdv // JA10  (AA8 )
    //--------------------------------------------------------------------------
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
     //-------------------------------------------------------------------------
     // synthesis attribute box_type hsr_danh_axi "black_box"
     //-------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.05.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
