//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// hsr_danh_axi.v
//------------------------------------------------------------------------------
// VERSION: 2018.03.12.
//------------------------------------------------------------------------------
`include "defines_system.v"

//------------------------------------------------------------------------------
`ifndef  BOARD_ZED
`error   "BOARD_ZED" should be defined.
`endif
`define FPGA_FAMILY     "ZYNQ7000"
`define XILINX_Z7
`define VIVADO

//------------------------------------------------------------------------------
`include "clkmgra.v"
`include "clkmgra_gtx125mhz.v"
`include "dut.v"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
module hsr_danh_axi
     #(parameter FPGA_FAMILY      =`FPGA_FAMILY
               , TXCLK_INV        =`TXCLK_INV
               , NUM_ENTRIES_PROXY=`NUM_ENTRIES_PROXY
               , NUM_ENTRIES_QR   =`NUM_ENTRIES_QR
               , DANH_OR_REDBOX   =`DANH_OR_REDBOX
               , CONF_MAC_ADDR    =`CONF_MAC_ADDR// only valid when DANH_OR_REDBOX="DANH"
               , CONF_PROMISCUOUS =1'b0 // promiscuos when 1
               , CONF_DROP_NON_HSR=1'b1 // drop non-hsr packet when 1
               , CONF_HSR_QR      =1'b1 // Quick Remove enabled when 1
               , CONF_SNOOP       =1'b0
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
               )
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
    //--------------------------------------------------------------------------
     `ifdef HSR_PERFORMANCE
     , output wire           host_probe_txen // JA1   (Y11 )
     , output wire           host_probe_rxdv // JA2   (AA11)
     , output wire           netA_probe_txen // JA7   (AB11)
     , output wire           netA_probe_rxdv // JA8   (AB10)
     , output wire           netB_probe_txen // JA9   (AB9 )
     , output wire           netB_probe_rxdv // JA10  (AA8 )
     `endif
    //--------------------------------------------------------------------------
     , output  wire                      s_axi_aresetn
     , output  wire                      s_axi_aclk
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
     `ifdef AMBA_AXI_CACHE
     , input   wire  [ 3:0]              s_axi_awcache
     `endif
     `ifdef AMBA_AXI_PROT
     , input   wire  [ 2:0]              s_axi_awprot
     `endif
     , input   wire                      s_axi_awvalid
     , output  wire                      s_axi_awready
     , input   wire  [AXI_WIDTH_DA-1:0]  s_axi_wdata
     , input   wire  [AXI_WIDTH_DS-1:0]  s_axi_wstrb
     , input   wire                      s_axi_wlast
     , input   wire                      s_axi_wvalid
     , output  wire                      s_axi_wready
     , output  wire  [ 1:0]              s_axi_bresp
     , output  wire                      s_axi_bvalid
     , input   wire                      s_axi_bready
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
     , output  wire  [AXI_WIDTH_DA-1:0]  s_axi_rdata
     , output  wire  [ 1:0]              s_axi_rresp
     , output  wire                      s_axi_rlast
     , output  wire                      s_axi_rvalid
     , input   wire                      s_axi_rready

);
    //--------------------------------------------------------------------------
    localparam BOARD_CLK_IN_FREQ=100_000_000;
    //--------------------------------------------------------------------------
    wire CLK_STABLE;
    wire clk125mhz;
    //--------------------------------------------------------------------------
    clkmgra #(.INPUT_CLOCK_FREQ(BOARD_CLK_IN_FREQ)
             ,.SYSCLK_FREQ     ( 80_000_000)
             ,.CLKOUT1_FREQ    (100_000_000) // it does not affect for SPARTAN6
             ,.CLKOUT2_FREQ    (125_000_000)
             ,.CLKOUT3_FREQ    ( 50_000_000)
             ,.CLKOUT4_FREQ    (250_000_000)
             ,.FPGA_FAMILY     (FPGA_FAMILY))// ARTIX7, VIRTEX6, SPARTAN6
    u_clkmgr (
           .OSC_IN         ( BOARD_CLK_IN     )
         , .OSC_OUT        (  )
         , .SYS_CLK_OUT    (                  )
         , .CLKOUT1        (                  )
         , .CLKOUT2        ( clk125mhz        )
         , .CLKOUT3        (  )
         , .CLKOUT4        (  )
         , .SYS_CLK_LOCKED ( CLK_STABLE   )
    );
    //--------------------------------------------------------------------------
    wire gtx0_clk125mhz  ;
    wire gtx90_clk125mhz ;
    wire gtx180_clk125mhz;
    wire gtx270_clk125mhz;
    wire gtx_clk_stable  ;
    // synthesis translate_off
    initial begin
    if (`TXCLK_INV!=1'b0) $display("%m Warning gtx_clk125mhz_90 is required");
    end
    // synthesis translate_on
    //--------------------------------------------------------------------------
    clkmgra_gtx125mhz #(.FPGA_FAMILY(FPGA_FAMILY))// ARTIX7, VIRTEX6, SPARTAN6
    u_gtx (
           .CLK125_IN      ( clk125mhz        )
         , .CLKOUT0        ( gtx0_clk125mhz   )
         , .CLKOUT90       ( gtx90_clk125mhz  )
         , .CLKOUT180      ( gtx180_clk125mhz )
         , .CLKOUT270      ( gtx270_clk125mhz )
         , .RST            (~CLK_STABLE   )
         , .LOCKED         ( gtx_clk_stable   )
    );
    //--------------------------------------------------------------------------
    wire SYS_RST_N = CLK_STABLE&gtx_clk_stable&~BOARD_RST_SW;
    //--------------------------------------------------------------------------
    wire hsr_ready;
    assign BOARD_LED={4'h0
                     ,CONF_SNOOP[0] // 3
                     ,(DANH_OR_REDBOX=="DANH") // 2
                     ,(DANH_OR_REDBOX=="REDBOX") // 1
                     ,hsr_ready}; // 0
    //--------------------------------------------------------------------------
    wire   GBE_MDIO_I;
    wire   GBE_MDIO_O;
    wire   GBE_MDIO_T;
`ifdef XXYY_MDIO
    assign GBE_MDIO_I = GBE_MDIO;
    assign GBE_MDIO   = (GBE_MDIO_T==1'b0) ? GBE_MDIO_O : 1'hZ;
`else
    IOBUF u_mdio(.I(GBE_MDIO_O),.T(GBE_MDIO_T),.O(GBE_MDIO_I),.IO(GBE_MDIO));
`endif
    //--------------------------------------------------------------------------
    assign  s_axi_aresetn=SYS_RST_N;
    assign  s_axi_aclk   =gtx0_clk125mhz;
    //--------------------------------------------------------------------------
    wire  [AXI_WIDTH_CID-1:0] s_axi_mid=1;
    wire  [AXI_WIDTH_ID-1:0]  s_axi_awid=1;
    wire  [AXI_WIDTH_ID-1:0]  s_axi_wid=1;
    wire  [AXI_WIDTH_ID-1:0]  s_axi_bid;
    wire  [AXI_WIDTH_ID-1:0]  s_axi_arid=1;
    wire  [AXI_WIDTH_ID-1:0]  s_axi_rid;
    //--------------------------------------------------------------------------
    dut #(.FPGA_FAMILY        (FPGA_FAMILY    )
         ,.P_SIZE_BRAM_MEM    (`SIZE_BRAM_MEM )
         ,.P_SIZE_BRAM_TX     (`SIZE_BRAM_TX  )
         ,.P_SIZE_BRAM_RX     (`SIZE_BRAM_RX  )
         ,.P_ADDR_START_MEM   (`ADDR_START_MEM   ) // AXI0
         ,.P_ADDR_START_MEM_TX(`ADDR_START_MEM_TX) // AXI1
         ,.P_ADDR_START_MEM_RX(`ADDR_START_MEM_RX) // AXI2
         ,.P_ADDR_START_GMAC  (`ADDR_START_GMAC  ) // AXI3
         ,.P_ADDR_START_APB   (`ADDR_START_APB   ) // APB0
         ,.P_ADDR_START_MDIO  (`ADDR_START_MDIO  ) // APB0
         ,.P_ADDR_START_HSR   (`ADDR_START_HSR   ) // APB1
         ,.P_ADDR_START_GPIO  (`ADDR_START_GPIO  ) // APB2
         ,.P_TX_FIFO_DEPTH    (`TX_FIFO_DEPTH    )
         ,.P_RX_FIFO_DEPTH    (`RX_FIFO_DEPTH    )
         ,.P_TX_DESCRIPTOR_FAW(`TX_DESCRIPTOR_FAW)
         ,.P_RX_DESCRIPTOR_FAW(`RX_DESCRIPTOR_FAW)
         ,.P_RX_FIFO_BNUM_FAW (`RX_FIFO_BNUM_FAW )
         ,.P_TXCLK_INV        (`TXCLK_INV        )
         ,.NUM_ENTRIES_PROXY  (NUM_ENTRIES_PROXY)
         ,.NUM_ENTRIES_QR     (NUM_ENTRIES_QR   )
         ,.DANH_OR_REDBOX     (DANH_OR_REDBOX   )
         ,.CONF_MAC_ADDR      (CONF_MAC_ADDR)// only valid when DANH_OR_REDBOX="DANH"
         ,.CONF_HSR_NET_ID    (3'h0)
         ,.CONF_PROMISCUOUS   (CONF_PROMISCUOUS )// promiscuos when 1
         ,.CONF_DROP_NON_HSR  (CONF_DROP_NON_HSR)// drop non-hsr packet when 1
         ,.CONF_HSR_QR        (CONF_HSR_QR      )// Quick Remove enabled when 1
         ,.CONF_SNOOP         (CONF_SNOOP       )// remove HSR head when 0
         ,.AXI_WIDTH_CID      (AXI_WIDTH_CID    )
         ,.AXI_WIDTH_ID       (AXI_WIDTH_ID     )
         ,.AXI_WIDTH_AD       (AXI_WIDTH_AD     )
         ,.AXI_WIDTH_DA       (AXI_WIDTH_DA     )
         ,.AXI_WIDTH_DS       (AXI_WIDTH_DS     )
         ,.AXI_WIDTH_SID      (AXI_WIDTH_SID    )
         ,.AXI_WIDTH_AWUSER   (AXI_WIDTH_AWUSER )
         ,.AXI_WIDTH_WUSER    (AXI_WIDTH_WUSER  )
         ,.AXI_WIDTH_BUSER    (AXI_WIDTH_BUSER  )
         ,.AXI_WIDTH_ARUSER   (AXI_WIDTH_ARUSER )
         ,.AXI_WIDTH_RUSER    (AXI_WIDTH_RUSER  )
         )
    u_dut (
           .s_axi_aresetn  ( s_axi_aresetn )
         , .s_axi_aclk     ( s_axi_aclk    )
         , .s_axi_mid      ( s_axi_mid     )
         , .s_axi_awid     ( s_axi_awid    )
         , .s_axi_awaddr   ( s_axi_awaddr  )
         `ifdef AMBA_AXI4
         , .s_axi_awlen    ( s_axi_awlen   )
         , .s_axi_awlock   ( s_axi_awlock  )
         `else
         , .s_axi_awlen    ( s_axi_awlen   )
         , .s_axi_awlock   ( s_axi_awlock  )
         `endif
         , .s_axi_awsize   ( s_axi_awsize  )
         , .s_axi_awburst  ( s_axi_awburst )
         `ifdef AMBA_AXI_CACHE
         , .s_axi_awcache  ( s_axi_awcache )
         `endif
         `ifdef AMBA_AXI_PROT
         , .s_axi_awprot   ( s_axi_awprot  )
         `endif
         , .s_axi_awvalid  ( s_axi_awvalid )
         , .s_axi_awready  ( s_axi_awready )
         , .s_axi_wid      ( s_axi_wid     )
         , .s_axi_wdata    ( s_axi_wdata   )
         , .s_axi_wstrb    ( s_axi_wstrb   )
         , .s_axi_wlast    ( s_axi_wlast   )
         , .s_axi_wvalid   ( s_axi_wvalid  )
         , .s_axi_wready   ( s_axi_wready  )
         , .s_axi_bid      ( s_axi_bid     )
         , .s_axi_bresp    ( s_axi_bresp   )
         , .s_axi_bvalid   ( s_axi_bvalid  )
         , .s_axi_bready   ( s_axi_bready  )
         , .s_axi_arid     ( s_axi_arid    )
         , .s_axi_araddr   ( s_axi_araddr  )
         `ifdef AMBA_AXI4
         , .s_axi_arlen    ( s_axi_arlen   )
         , .s_axi_arlock   ( s_axi_arlock  )
         `else
         , .s_axi_arlen    ( s_axi_arlen   )
         , .s_axi_arlock   ( s_axi_arlock  )
         `endif
         , .s_axi_arsize   ( s_axi_arsize  )
         , .s_axi_arburst  ( s_axi_arburst )
         `ifdef  AMBA_AXI_CACHE
         , .s_axi_arcache  ( s_axi_arcache )
         `endif
         `ifdef AMBA_AXI_PROT
         , .s_axi_arprot   ( s_axi_arprot  )
         `endif
         , .s_axi_arvalid  ( s_axi_arvalid )
         , .s_axi_arready  ( s_axi_arready )
         , .s_axi_rid      ( s_axi_rid     )
         , .s_axi_rdata    ( s_axi_rdata   )
         , .s_axi_rresp    ( s_axi_rresp   )
         , .s_axi_rlast    ( s_axi_rlast   )
         , .s_axi_rvalid   ( s_axi_rvalid  )
         , .s_axi_rready   ( s_axi_rready  )
         , .gbe_mdc         ( GBE_MDC        )
         , .gbe_mdio_I      ( GBE_MDIO_I     )
         , .gbe_mdio_O      ( GBE_MDIO_O     )
         , .gbe_mdio_T      ( GBE_MDIO_T     )
         , .gtx_clk        ( gtx0_clk125mhz  )
         , .gtx_clk90      ( gtx90_clk125mhz )
         , .gtx_clk_stable ( gtx_clk_stable  )
         `ifdef RGMII
         , .rgmiiA_gtxc    ( GBEA_GTXC       )
         , .rgmiiA_txd     ( GBEA_TXD[3:0]   )
         , .rgmiiA_txctl   ( GBEA_TXCTL      )
         , .rgmiiA_rxc     ( GBEA_RXC        )
         , .rgmiiA_rxd     ( GBEA_RXD        )
         , .rgmiiA_rxctl   ( GBEA_RXCTL      )
         `else
         , .gmiiA_gtxc     ( GBEA_GTXC       )
         , .gmiiA_txd      ( GBEA_TXD        )
         , .gmiiA_txen     ( GBEA_TXEN       )
         , .gmiiA_txer     ( GBEA_TXER       )
         , .gmiiA_rxc      ( GBEA_RXC        )
         , .gmiiA_rxd      ( GBEA_RXD        )
         , .gmiiA_rxdv     ( GBEA_RXDV       )
         , .gmiiA_rxer     ( GBEA_RXER       )
         , .gmiiA_col      ( 1'b0            )
         , .gmiiA_crs      ( 1'b0            )
         `endif
         , .gbeA_phy_reset_n( GBEA_PHY_RESET_N )
         `ifdef RGMII
         , .rgmiiB_gtxc    ( GBEB_GTXC       )
         , .rgmiiB_txd     ( GBEB_TXD[3:0]   )
         , .rgmiiB_txctl   ( GBEB_TXCTL      )
         , .rgmiiB_rxc     ( GBEB_RXC        )
         , .rgmiiB_rxd     ( GBEB_RXD        )
         , .rgmiiB_rxctl   ( GBEB_RXCTL      )
         `else
         , .gmiiB_gtxc     ( GBEB_GTXC       )
         , .gmiiB_txd      ( GBEB_TXD        )
         , .gmiiB_txen     ( GBEB_TXEN       )
         , .gmiiB_txer     ( GBEB_TXER       )
         , .gmiiB_rxc      ( GBEB_RXC        )
         , .gmiiB_rxd      ( GBEB_RXD        )
         , .gmiiB_rxdv     ( GBEB_RXDV       )
         , .gmiiB_rxer     ( GBEB_RXER       )
         , .gmiiB_col      ( 1'b0            )
         , .gmiiB_crs      ( 1'b0            )
         `endif
         , .gbeB_phy_reset_n( GBEB_PHY_RESET_N )
         , .board_id        ( BOARD_SLIDE_SW   )
         , .hsr_ready       ( hsr_ready        )
         `ifdef HSR_PERFORMANCE
         , .host_probe_txen ( host_probe_txen )
         , .host_probe_rxdv ( host_probe_rxdv )
         , .netA_probe_txen ( netA_probe_txen )
         , .netA_probe_rxdv ( netA_probe_rxdv )
         , .netB_probe_txen ( netB_probe_txen )
         , .netB_probe_rxdv ( netB_probe_rxdv )
         `endif
    );
    //--------------------------------------------------------------------------
    // synthesis translate_off
    real stamp_x, stamp_y;
    initial begin
         wait (SYS_RST_N==1'b0);
         wait (SYS_RST_N==1'b1);
         repeat (5) @ (posedge BOARD_CLK_IN);
         @ (posedge BOARD_CLK_IN); stamp_x = $realtime;
         @ (posedge BOARD_CLK_IN); stamp_y = $realtime;
         $display("%m BOARD_CLK_IN %.2f-nsec %.2f-MHz", stamp_y - stamp_x, 1000.0/(stamp_y-stamp_x));
         @ (posedge clk125mhz); stamp_x = $realtime;
         @ (posedge clk125mhz); stamp_y = $realtime;
         $display("%m clk125mhz %.2f-nsec %.2f-MHz", stamp_y - stamp_x, 1000.0/(stamp_y-stamp_x));
         $fflush();
    end
    // synthesis translate_on
    //--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
//                                  +-----------+       +------------+   +------------+           
//                         ACLK     |           |       |            |   |            |
//                       <----+---->| AXI bus   |       | GBE MAC    |   | HSR        |
//                            |     | AXI perip |       |            |   |            |
//                            |     |           |       |            |   |            |
//                            |     |           |       |            |   |            |
//                            |     +-----------+       +------------+   +------------+           
//                            |       /\                  /\    /\ /\      /\
//                            |ACLK    |                   |     |  |       |
//                            +--------+-------------------/     |  |       |
//                            |                                  |  |       |
//                            |                                  |  |       |
//                            |                                  |  |       |
//            +---------+     |     +----------+ gtx90_clk125mhz |  |       |
//   BOARD_CLK|         |-----/     |          |-----------------/  |       |
//  --------->| DCM     |           | DCM      | gtx0_clk125mhz     |       |
//            |         |---------->|          |--------------------+-------/
//            +---------+ clk125mhz +----------+ 
//
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.05.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
