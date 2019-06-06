//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// dut.v
//------------------------------------------------------------------------------
// VERSION: 2018.02.15.
//------------------------------------------------------------------------------
//
//  +------+  +------+  +------+   +------+      +------+              +------+ 
//  |      |  |      |  |      |   |MEM TX|  G   |      |              |      | 
//  | USB  |==| BFM  |==|M0  S1|===|S0  S1|==++==|M     |==============|PHY   | 
//  |      |  | (TX) |  |      |   |      |R ||  |      |              |      | 
//  +------+  +------+  |      |   +------+  ||  |      |              +------+ 
//                      |      |   +------+  ||  |      |           
//                      | AXI  |   |MEM RX|  ||  | GBE  |           
//            +------+  |    S2|===|S0  S1|==//  | MAC  |           
//            |      |  |      |   |      |W     |      |           
//            | BFM  |==|M1    |   +------+      |      |   +------+
//            | (RX) |  |      |                 |      |   |      |
//            +------+  |    S3|=================|S     |===| PTP  |
//                      |      |                 |      |   |      |
//                      |      |                 +------+   +------+
//                      |      |                                   
//            +------+  |      |    +------+
//            |      |  |      |    | AXI  |
//            | MEM  |==|S0  S4|====| to   |
//            |      |  |      |    | APB  |           
//            +------+  +------+    +------+           
//------------------------------------------------------------------------------
//`include "axi_switch_m2s5.v"
//`include "axi_to_apb_s3.v"
//`include "bram_axi.v"
//`include "bram_axi_dual.v"
//`include "mdio_apb.v"
//`include "gpio_apb.v"
//`include "gig_eth_hsr.v"
//`include "gig_eth_mac_danh_axi.v"

module dut
     #(parameter FPGA_FAMILY        ="VIRTEX6"// SPARTAN6, VIRTEX4
               , P_SIZE_BRAM_MEM    =16*1024
               , P_SIZE_BRAM_TX     =16*1024
               , P_SIZE_BRAM_RX     =16*1024
               , P_ADDR_START_MEM   =32'h4000_0000,P_ADDR_LENGTH_MEM   =clogb2(P_SIZE_BRAM_MEM)
               , P_ADDR_START_MEM_TX=32'h4100_0000,P_ADDR_LENGTH_MEM_TX=clogb2(P_SIZE_BRAM_TX )
               , P_ADDR_START_MEM_RX=32'h4200_0000,P_ADDR_LENGTH_MEM_RX=clogb2(P_SIZE_BRAM_RX )
               , P_ADDR_START_GMAC  =32'h4300_0000,P_ADDR_LENGTH_GMAC =10
               , P_ADDR_START_APB   =32'h4C00_0000,P_ADDR_LENGTH_APB  =20
               , P_ADDR_START_MDIO  =32'h4C00_0000,P_ADDR_LENGTH_MDIO =10
               , P_ADDR_START_HSR   =32'h4C01_0000,P_ADDR_LENGTH_HSR  =10
               , P_ADDR_START_GPIO  =32'h4C02_0000,P_ADDR_LENGTH_GPIO =10
               , P_ADDR_START_TIMER =32'h4C03_0000,P_ADDR_LENGTH_TIMER=10
               , P_ADDR_START_PTP   =32'h4C04_0000,P_ADDR_LENGTH_PTP  =10
               , P_TX_FIFO_DEPTH    =128 // gig_eth_mac_axi   async fifo
               , P_RX_FIFO_DEPTH    =128 // gig_eth_mac_axi   async fifo
               , P_TX_DESCRIPTOR_FAW=4 // gig_eth_mac_csr sync fifo
               , P_RX_DESCRIPTOR_FAW=4 // gig_eth_mac_csr sync fifo
               , P_RX_FIFO_BNUM_FAW =5 // gig_eth_mac async fifo bewtween mac-rx-core and dma-rx
               , P_TXCLK_INV        =1'b0
               , P_IRQ_GMAC       = 0
               , P_IRQ_PTP        = 1
               , P_IRQ_RTC        = 2
               , P_IRQ_GPIO       = 3
               , AXI_WIDTH_CID    = 4    // Channel ID width in bits
               , AXI_WIDTH_ID     = 4    // ID width in bits
               , AXI_WIDTH_AD     =32    // address width
               , AXI_WIDTH_DA     =32    // data width
               , AXI_WIDTH_DS     =(AXI_WIDTH_DA/8)  // data strobe width
               , AXI_WIDTH_SID    =AXI_WIDTH_CID+AXI_WIDTH_ID // ID for slave
               , AXI_WIDTH_AWUSER =1  // Write-address user path
               , AXI_WIDTH_WUSER  =1  // Write-data user path
               , AXI_WIDTH_BUSER  =1  // Write-response user path
               , AXI_WIDTH_ARUSER =1  // read-address user path
               , AXI_WIDTH_RUSER  =1  // read-data user path
               , CONF_MAC_ADDR    =48'hF0_12_34_56_78_9A // only valid when DANH_OR_REDBOX="DANH"
               , CONF_HSR_NET_ID  =3'h0 
               , NUM_ENTRIES_PROXY=16
               , NUM_ENTRIES_QR   =16
               , DANH_OR_REDBOX   ="DANH"
               , CONF_PROMISCUOUS =1'b0 // promiscuos when 1
               , CONF_DROP_NON_HSR=1'b1 // drop non-hsr packet when 1
               , CONF_HSR_QR      =1'b1 // Quick Remove enabled when 1
               , CONF_SNOOP       =1'b0 // remove HSR head when 0
               )
(
     input   wire                      s_axi_aresetn
   , input   wire                      s_axi_aclk
   , input   wire  [AXI_WIDTH_CID-1:0] s_axi_mid
   , input   wire  [AXI_WIDTH_ID-1:0]  s_axi_awid
   , input   wire  [AXI_WIDTH_AD-1:0]  s_axi_awaddr
   `ifdef AMBA_AXI4
   , input   wire  [ 7:0]              s_axi_awlen
   , input   wire                      s_axi_awlock
   `else
   , input   wire  [ 3:0]              s_axi_awlen
   , input   wire  [ 1:0]              s_axi_awlock
   `endif
   , input   wire  [ 2:0]              s_axi_awsize
   , input   wire  [ 1:0]              s_axi_awburst
   `ifdef  AMBA_AXI_CACHE
   , input   wire  [ 3:0]              s_axi_awcache
   `endif
   `ifdef AMBA_AXI_PROT
   , input   wire  [ 2:0]              s_axi_awprot
   `endif
   , input   wire                      s_axi_awvalid
   , output  wire                      s_axi_awready
   , input   wire  [AXI_WIDTH_ID-1:0]  s_axi_wid
   , input   wire  [AXI_WIDTH_DA-1:0]  s_axi_wdata
   , input   wire  [AXI_WIDTH_DS-1:0]  s_axi_wstrb
   , input   wire                      s_axi_wlast
   , input   wire                      s_axi_wvalid
   , output  wire                      s_axi_wready
   , output  wire  [AXI_WIDTH_ID-1:0]  s_axi_bid
   , output  wire  [ 1:0]              s_axi_bresp
   , output  wire                      s_axi_bvalid
   , input   wire                      s_axi_bready
   , input   wire  [AXI_WIDTH_ID-1:0]  s_axi_arid
   , input   wire  [AXI_WIDTH_AD-1:0]  s_axi_araddr
   `ifdef AMBA_AXI4
   , input   wire  [ 7:0]              s_axi_arlen
   , input   wire                      s_axi_arlock
   `else
   , input   wire  [ 3:0]              s_axi_arlen
   , input   wire  [ 1:0]              s_axi_arlock
   `endif
   , input   wire  [ 2:0]              s_axi_arsize
   , input   wire  [ 1:0]              s_axi_arburst
   `ifdef  AMBA_AXI_CACHE
   , input   wire  [ 3:0]              s_axi_arcache
   `endif
   `ifdef AMBA_AXI_PROT
   , input   wire  [ 2:0]              s_axi_arprot
   `endif
   , input   wire                      s_axi_arvalid
   , output  wire                      s_axi_arready
   , output  wire  [AXI_WIDTH_ID-1:0]  s_axi_rid
   , output  wire  [AXI_WIDTH_DA-1:0]  s_axi_rdata
   , output  wire  [ 1:0]              s_axi_rresp
   , output  wire                      s_axi_rlast
   , output  wire                      s_axi_rvalid
   , input   wire                      s_axi_rready
   , output  wire          gbe_mdc
   , input   wire          gbe_mdio_I
   , output  wire          gbe_mdio_O
   , output  wire          gbe_mdio_T
   , input   wire          gtx_clk
   , input   wire          gtx_clk90
   , input   wire          gtx_clk_stable
   `ifdef RGMII
   , output  wire          rgmiiU_gtxc
   , output  wire  [ 3:0]  rgmiiU_txd
   , output  wire          rgmiiU_txctl
   , input   wire          rgmiiU_rxc
   , input   wire  [ 3:0]  rgmiiU_rxd
   , input   wire          rgmiiU_rxctl
   `else
   , output  wire          gmiiU_gtxc // Gigabit TX Clock  (output)
   , output  wire  [ 7:0]  gmiiU_txd
   , output  wire          gmiiU_txen
   , output  wire          gmiiU_txer
   , input   wire          gmiiU_rxc
   , input   wire  [ 7:0]  gmiiU_rxd
   , input   wire          gmiiU_rxdv
   , input   wire          gmiiU_rxer
   , input   wire          gmiiU_col
   , input   wire          gmiiU_crs
   `endif
   , output  wire          gbeU_phy_reset_n
   , output  wire          ptpv2_master
   , output  wire          ptp_pps
   , output  wire          ptp_ppus
   , output  wire          irq_gmac
   , output  wire          irq_ptp
   , output  wire          irq_rtc
   , output  wire          irq_gpio
   , output  wire  [ 3:0]  irq_timer
   , input   wire  [ 7:0]  board_id
   , output  wire          ptp_ready
   `ifdef HSR_PERFORMANCE
   , output wire           host_probe_txen // JA1   (Y11 )
   , output wire           host_probe_rxdv // JA2   (AA11)
   , output wire           netA_probe_txen // JA7   (AB11)
   , output wire           netA_probe_rxdv // JA8   (AB10)
   , output wire           netB_probe_txen // JA9   (AB9 )
   , output wire           netB_probe_rxdv // JA10  (AA8 )
   `endif
);
   //---------------------------------------------------------------------------
   localparam P_ACLK_FREQ=125_000_000; // gtx_125mhz
   //---------------------------------------------------------------------------
  `include "dut_axi_bus.v"
  `include "dut_apb_bus.v"
  `include "dut_axi_peri.v"
  `include "dut_apb_peri.v"
   //---------------------------------------------------------------------------
   function integer clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
      tmp = value - 1;
      for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
   end
   endfunction
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.24: stream-loopback added.
// 2018.03.07: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
