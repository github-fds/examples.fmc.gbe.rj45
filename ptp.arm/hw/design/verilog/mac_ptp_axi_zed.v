//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// mac_ptp_axi.v
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
module mac_ptp_axi
     #(parameter FPGA_FAMILY      =`FPGA_FAMILY
               , TXCLK_INV        =`TXCLK_INV
               , NUM_ENTRIES_PROXY=`NUM_ENTRIES_PROXY
               , NUM_ENTRIES_QR   =`NUM_ENTRIES_QR
               , DANH_OR_REDBOX   =`DANH_OR_REDBOX
               , CONF_MAC_ADDR    =`CONF_MAC_ADDR// only valid when DANH_OR_REDBOX="DANH"
               , CONF_PROMISCUOUS =1'b0 // promiscuos when 1
               , CONF_DROP_NON_HSR=1'b0 // drop non-hsr packet when 1
               , CONF_HSR_QR      =1'b0 // Quick Remove enabled when 1
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
       input   wire          BOARD_RST_SW // synthesis xc_pulldown = 1 (active-high)
     , input   wire          BOARD_CLK_IN // reference clock input (100)
     , input   wire  [ 7:0]  BOARD_SLIDE_SW
     , output  wire  [ 7:0]  BOARD_LED
     , input   wire          BOARD_BTND // synthesis xc_pulldown = 1 (active-high)
     , input   wire          BOARD_BTNU // synthesis xc_pulldown = 1 (active-high)
     //-------------------------------------------------------------------------
     , output  wire          GBE_MDC  /* synthesis xc_pullup = 1 */
     , inout   wire          GBE_MDIO /* synthesis xc_pullup = 1 */
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
     , output  wire          PTP_PPS  // PMOD1 JA3 (Y10)
     , output  wire          PTP_PPUS // PMOD1 JA4 (AA9)
     , output  wire          IRQ_GMAC
     , output  wire          IRQ_PTP
     , output  wire          IRQ_RTC
     , output  wire          IRQ_GPIO
     , output  wire  [ 3:0]  IRQ_TIMER
     , (* mark_debug="true" *) output  wire          IRQ_SWU // PushButton Down
     , (* mark_debug="true" *) output  wire          IRQ_SWD // PushButton Down
     //-------------------------------------------------------------------------
     `ifdef HSR_PERFORMANCE
     , output wire           host_probe_txen // PMOD1 JA1   (Y11 )
     , output wire           host_probe_rxdv // PMOD1 JA2   (AA11)
     , output wire           netA_probe_txen // PMOD1 JA7   (AB11)
     , output wire           netA_probe_rxdv // PMOD1 JA8   (AB10)
     , output wire           netB_probe_txen // PMOD1 JA9   (AB9 )
     , output wire           netB_probe_rxdv // PMOD1 JA10  (AA8 )
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
    assign     IRQ_SWD=BOARD_BTND;// PushButton Down
    assign     IRQ_SWU=BOARD_BTNU;// PushButton Up
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
    wire PTP_MASTER;
    wire PTP_SLAVE=~PTP_MASTER;
    wire hsr_ready=1'b1;
    wire ptp_ready;
    assign BOARD_LED={1'h0 // 7
                     ,PTP_SLAVE//6
                     ,PTP_MASTER //5
                     ,ptp_ready // 4
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
         ,.P_ADDR_START_TIMER (`ADDR_START_TIMER ) // APB3
         ,.P_ADDR_START_PTP   (`ADDR_START_PTP   ) // APB4
         ,.P_TX_FIFO_DEPTH    (`TX_FIFO_DEPTH    )
         ,.P_RX_FIFO_DEPTH    (`RX_FIFO_DEPTH    )
         ,.P_TX_DESCRIPTOR_FAW(`TX_DESCRIPTOR_FAW)
         ,.P_RX_DESCRIPTOR_FAW(`RX_DESCRIPTOR_FAW)
         ,.P_RX_FIFO_BNUM_FAW (`RX_FIFO_BNUM_FAW )
         ,.P_TXCLK_INV        (`TXCLK_INV        )
         ,.P_IRQ_GMAC         (`IRQ_GMAC         )
         ,.P_IRQ_PTP          (`IRQ_PTP          )
         ,.P_IRQ_RTC          (`IRQ_RTC          )
         ,.P_IRQ_GPIO         (`IRQ_GPIO         )
         ,.NUM_ENTRIES_PROXY  (NUM_ENTRIES_PROXY )
         ,.NUM_ENTRIES_QR     (NUM_ENTRIES_QR    )
         ,.DANH_OR_REDBOX     (DANH_OR_REDBOX    )
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
         , .rgmiiU_gtxc    ( GBEU_GTXC       )
         , .rgmiiU_txd     ( GBEU_TXD[3:0]   )
         , .rgmiiU_txctl   ( GBEU_TXCTL      )
         , .rgmiiU_rxc     ( GBEU_RXC        )
         , .rgmiiU_rxd     ( GBEU_RXD        )
         , .rgmiiU_rxctl   ( GBEU_RXCTL      )
         `else
         , .gmiiU_gtxc     ( GBEU_GTXC       )
         , .gmiiU_txd      ( GBEU_TXD        )
         , .gmiiU_txen     ( GBEU_TXEN       )
         , .gmiiU_txer     ( GBEU_TXER       )
         , .gmiiU_rxc      ( GBEU_RXC        )
         , .gmiiU_rxd      ( GBEU_RXD        )
         , .gmiiU_rxdv     ( GBEU_RXDV       )
         , .gmiiU_rxer     ( GBEU_RXER       )
         , .gmiiU_col      ( 1'b0            )
         , .gmiiU_crs      ( 1'b0            )
         `endif
         , .gbeU_phy_reset_n( GBEU_PHY_RESET_N )
         , .ptpv2_master    ( PTP_MASTER       )
         , .ptp_pps         ( PTP_PPS          )
         , .ptp_ppus        ( PTP_PPUS         )
         , .irq_gmac        ( IRQ_GMAC         )
         , .irq_ptp         ( IRQ_PTP          )
         , .irq_rtc         ( IRQ_RTC          )
         , .irq_gpio        ( IRQ_GPIO         )
         , .irq_timer       ( IRQ_TIMER        )
         , .board_id        ( BOARD_SLIDE_SW   )
         , .ptp_ready       ( ptp_ready        )
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
