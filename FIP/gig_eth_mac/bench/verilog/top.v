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
//
//       +------+       +------+       +------+       +------+       +------+ 
//       |      |       |      |       |MEM TX|  G    |      |       |      | 
//       | BFM  |=======|M0  S0|=======|S0  S1|=======|M     |=======|PHY   | 
//       | (TX) |       |      |       |      |R ||   |      |       |      | 
//       +------+       |      |       +------+  ||   |      |       +------+ 
//                      |      |       +------+  ||   |      |
//                      | AXI  |       |MEM RX|  ||   | GBE  |
//       +------+       |    S1|=======|S0  S1|====   |      |
//       |      |       |      |       |      |W      |      |
//       | BFM  |=======|M1    |       +------+       |      |
//       | (RX) |       |      |                      |      |
//       +------+       |    S2|======================|S     |
//                      |      |                      |      |
//                      +------+                      +------+
//------------------------------------------------------------------------------
`timescale 1ns/1ps

`ifndef FPGA_FAMILY
`define FPGA_FAMILY         "VIRTEX6"
`endif
`ifndef TXCLK_INV
`define TXCLK_INV           1'b0
`endif

`ifndef ADDR_START_MEM_TX
`define ADDR_START_MEM_TX   32'h0000_0000
`endif
`ifndef ADDR_START_MEM_RX
`define ADDR_START_MEM_RX   32'h1000_0000
`endif
`ifndef ADDR_START_GMAC
`define ADDR_START_GMAC     32'hC000_0000
`endif

//------------------------------------------------------------------------------
// Dual-port BRAM size in bytes
`ifndef P_SIZE
`define P_SIZE      (16*1024)
`define ADDR_LENGTH (14)
`endif

//------------------------------------------------------------------------------
// Async-FIFO depth between DMA and MAC_CORE
`ifndef P_TX_FIFO_DEPTH
`define P_TX_FIFO_DEPTH   (128)
`endif
`ifndef P_RX_FIFO_DEPTH
`define P_RX_FIFO_DEPTH   (256)
`endif

//------------------------------------------------------------------------------
// Sync-FIFO depth between int CSR, which connects to DMA
`ifndef TX_DESCRIPTOR_FAW
`define TX_DESCRIPTOR_FAW   4
`endif
`ifndef RX_DESCRIPTOR_FAW
`define RX_DESCRIPTOR_FAW   4
`endif

//------------------------------------------------------------------------------
`ifndef RX_FIFO_BNUM_FAW
`define RX_FIFO_BNUM_FAW    4
`endif

//------------------------------------------------------------------------------
`define AXI_MST_ID_TX   2
`define AXI_MST_ID_RX   1

module top;
   //---------------------------------------------------------------------------
   reg  RESET_N=1'b0;
   reg  CLK25M =1'b0;
   reg  CLK30M =1'b0;
   reg  CLK40M =1'b0;
   reg  CLK50M =1'b0;
   reg  CLK80M =1'b0;
   reg  CLK90M =1'b0;
   reg  CLK100M=1'b0;
   reg  CLK500M=1'b0;
   reg  CLK250M=1'b0;
   //---------------------------------------------------------------------------
   localparam CLK25_FREQ=25_000_000;
   localparam CLK25_PERIOD_HALF=1_000_000_000/(CLK25_FREQ*2);
   localparam CLK30_FREQ=30_000_000;
   localparam CLK30_PERIOD_HALF=1_000_000_000/(CLK30_FREQ*2);
   localparam CLK40_FREQ=40_000_000;
   localparam CLK40_PERIOD_HALF=1_000_000_000/(CLK40_FREQ*2);
   localparam CLK50_FREQ=50_000_000;
   localparam CLK50_PERIOD_HALF=1_000_000_000/(CLK50_FREQ*2);
   localparam CLK80_FREQ=80_000_000;
   localparam CLK80_PERIOD_HALF=1_000_000_000/(CLK80_FREQ*2);
   localparam CLK90_FREQ=90_000_000;
   localparam CLK90_PERIOD_HALF=1_000_000_000/(CLK90_FREQ*2);
   localparam CLK100_FREQ=100_000_000;
   localparam CLK100_PERIOD_HALF=1_000_000_000/(CLK100_FREQ*2);
   localparam CLK500_FREQ=500_000_000;
   localparam CLK500_PERIOD_HALF=1_000_000_000/(CLK500_FREQ*2);
   //---------------------------------------------------------------------------
   always #CLK25_PERIOD_HALF CLK25M <= ~CLK25M;
   always #CLK30_PERIOD_HALF CLK30M <= ~CLK30M;
   always #CLK40_PERIOD_HALF CLK40M <= ~CLK40M;
   always #CLK50_PERIOD_HALF CLK50M <= ~CLK50M;
   always #CLK80_PERIOD_HALF CLK80M <= ~CLK80M;
   always #CLK90_PERIOD_HALF CLK90M <= ~CLK90M;
   always #CLK100_PERIOD_HALF CLK100M <= ~CLK100M;
   always #CLK500_PERIOD_HALF CLK500M <= ~CLK500M;
   always @ (posedge CLK500M) CLK250M <= ~CLK250M;
   //---------------------------------------------------------------------------
   reg gtx_clk=1'b0;
   reg gtx_clk90=1'b0;
   always @ (posedge CLK250M) gtx_clk   <= ~gtx_clk;
   always @ (posedge CLK500M) gtx_clk90 <=  gtx_clk;
   //---------------------------------------------------------------------------
   `ifdef RGMII
   wire          rgmii_gtxc   ;
   wire  [ 3:0]  rgmii_txd    ;
   wire          rgmii_txctl  ;
   wire          rgmii_rxc    ;
   wire  [ 3:0]  rgmii_rxd    ;
   wire          rgmii_rxctl  ;
   `else
   wire          gmii_gtxc   ;
   wire  [ 7:0]  gmii_txd    ;
   wire          gmii_txen   ;
   wire          gmii_txer   ;
   wire          gmii_crs    ;
   wire          gmii_col    ;
   wire          gmii_rxc    ;
   wire  [ 7:0]  gmii_rxd    ;
   wire          gmii_rxdv   ;
   wire          gmii_rxer   ;
   `endif
   wire          gmii_mdc    ; pullup u_mdc (gmii_mdc );
   wire          gmii_mdio   ; pullup u_mdio(gmii_mdio);
   //---------------------------------------------------------------------------
   `include "top_axi.v"
   //---------------------------------------------------------------------------
   assign        ARESETn = RESET_N;
   assign        ACLK    = CLK80M;
   //---------------------------------------------------------------------------
   wire          IRQ         ;
   //---------------------------------------------------------------------------
   wire  [AXI_WIDTH_CID-1:0]    #(BUS_DELAY) G_MID     ;
   wire  [AXI_WIDTH_ID-1:0]     #(BUS_DELAY) G_AWID    ;
   wire  [AXI_WIDTH_AD-1:0]     #(BUS_DELAY) G_AWADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 #(BUS_DELAY) G_AWLEN   ;
   wire                         #(BUS_DELAY) G_AWLOCK  ;
   `else
   wire  [ 3:0]                 #(BUS_DELAY) G_AWLEN   ;
   wire  [ 1:0]                 #(BUS_DELAY) G_AWLOCK  ;
   `endif
   wire  [ 2:0]                 #(BUS_DELAY) G_AWSIZE  ;
   wire  [ 1:0]                 #(BUS_DELAY) G_AWBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 #(BUS_DELAY) G_AWCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 #(BUS_DELAY) G_AWPROT  ;
   `endif
   wire                         #(BUS_DELAY) G_AWVALID ;
   wire                         #(BUS_DELAY) G_AWREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 #(BUS_DELAY) G_AWQOS   ;
   wire  [ 3:0]                 #(BUS_DELAY) G_AWREGION;
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [AXI_WIDTH_AWUSER-1:0] #(BUS_DELAY) G_AWUSER  ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     #(BUS_DELAY) G_WID     ;
   wire  [AXI_WIDTH_DA-1:0]     #(BUS_DELAY) G_WDATA   ;
   wire  [AXI_WIDTH_DS-1:0]     #(BUS_DELAY) G_WSTRB   ;
   wire                         #(BUS_DELAY) G_WLAST   ;
   wire                         #(BUS_DELAY) G_WVALID  ;
   wire                         #(BUS_DELAY) G_WREADY  ;
   `ifdef AMBA_AXI_WUSER
   wire  [AXI_WIDTH_WUSER-1:0]  #(BUS_DELAY) G_WUSER   ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     #(BUS_DELAY) G_BID     ; wire [AXI_WIDTH_CID-1:0] G_BID_tmp;
   wire  [ 1:0]                 #(BUS_DELAY) G_BRESP   ;
   wire                         #(BUS_DELAY) G_BVALID  ;
   wire                         #(BUS_DELAY) G_BREADY  ;
   `ifdef AMBA_AXI_BUSER
   wire  [AXI_WIDTH_BUSER-1:0]  #(BUS_DELAY) G_BUSER   ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     #(BUS_DELAY) G_ARID    ;
   wire  [AXI_WIDTH_AD-1:0]     #(BUS_DELAY) G_ARADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 #(BUS_DELAY) G_ARLEN   ;
   wire                         #(BUS_DELAY) G_ARLOCK  ;
   `else
   wire  [ 3:0]                 #(BUS_DELAY) G_ARLEN   ;
   wire  [ 1:0]                 #(BUS_DELAY) G_ARLOCK  ;
   `endif
   wire  [ 2:0]                 #(BUS_DELAY) G_ARSIZE  ;
   wire  [ 1:0]                 #(BUS_DELAY) G_ARBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 #(BUS_DELAY) G_ARCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 #(BUS_DELAY) G_ARPROT  ;
   `endif
   wire                         #(BUS_DELAY) G_ARVALID ;
   wire                         #(BUS_DELAY) G_ARREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 #(BUS_DELAY) G_ARQOS   ;
   wire  [ 3:0]                 #(BUS_DELAY) G_ARREGION;
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [AXI_WIDTH_ARUSER-1:0] #(BUS_DELAY) G_ARUSER  ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     #(BUS_DELAY) G_RID     ; wire [AXI_WIDTH_CID-1:0] G_RID_tmp;
   wire  [AXI_WIDTH_DA-1:0]     #(BUS_DELAY) G_RDATA   ;
   wire  [ 1:0]                 #(BUS_DELAY) G_RRESP   ;
   wire                         #(BUS_DELAY) G_RLAST   ;
   wire                         #(BUS_DELAY) G_RVALID  ;
   wire                         #(BUS_DELAY) G_RREADY  ;
   `ifdef AMBA_AXI_RUSER
   wire  [AXI_WIDTH_RUSER-1:0]  #(BUS_DELAY) G_RUSER   ;
   `endif
   //---------------------------------------------------------------------------
   gig_eth_mac_axi #(.AXI_MST_ID       (1)
                    ,.AXI_WIDTH_CID    (AXI_WIDTH_CID)// Channel ID width in bits
                    ,.AXI_WIDTH_ID     (AXI_WIDTH_ID )// ID width in bits
                    ,.AXI_WIDTH_AD     (AXI_WIDTH_AD )// address width
                    ,.AXI_WIDTH_DA     (AXI_WIDTH_DA )// data width
                    ,.P_TX_FIFO_DEPTH  (`P_TX_FIFO_DEPTH  )
                    ,.P_RX_FIFO_DEPTH  (`P_RX_FIFO_DEPTH  )
                    ,.P_TX_DESCRIPTOR_FAW(`TX_DESCRIPTOR_FAW)
                    ,.P_RX_DESCRIPTOR_FAW(`RX_DESCRIPTOR_FAW)
                    ,.P_RX_FIFO_BNUM_FAW (`RX_FIFO_BNUM_FAW)
                    ,.P_TXCLK_INV        (`TXCLK_INV  )
                    ,.FPGA_FAMILY      (`FPGA_FAMILY)
                    )
   u_mac (
       .ARESETn ( ARESETn )
     , .ACLK    ( ACLK    )
     , .IRQ     ( IRQ     )
     , .gbe_phy_reset_n ( )
     `ifdef RGMII
     , .rgmii_gtxc ( rgmii_gtxc  )
     , .rgmii_txd  ( rgmii_txd   )
     , .rgmii_txctl( rgmii_txctl )
     , .rgmii_rxc  ( rgmii_rxc   )
     , .rgmii_rxd  ( rgmii_rxd   )
     , .rgmii_rxctl( rgmii_rxctl )
     , .gtx_clk    ( gtx_clk     )
     , .gtx_clk90  ( gtx_clk90   )
     , .gtx_clk_stable ( 1'b1    )
     `else
     , .gmii_gtxc  ( gmii_gtxc )
     , .gmii_txd   ( gmii_txd  )
     , .gmii_txen  ( gmii_txen )
     , .gmii_txer  ( gmii_txer )
     , .gmii_rxc   ( gmii_rxc  )
     , .gmii_rxd   ( gmii_rxd  )
     , .gmii_rxdv  ( gmii_rxdv )
     , .gmii_rxer  ( gmii_rxer )
     , .gmii_col   ( gmii_col  )
     , .gmii_crs   ( gmii_crs  )
     , .gtx_clk    ( gtx_clk   )
     , .gtx_clk_stable ( 1'b1    )
     `endif
     , .M_MID              ( G_MID                ) // AXI_WIDTH_CID-1:0
     , .M_AWID             ( G_AWID               ) // AXI_WIDTH_ID-1:0
     , .M_AWADDR           ( G_AWADDR             )
     `ifdef AMBA_AXI4
     , .M_AWLEN            ( G_AWLEN              )
     , .M_AWLOCK           ( G_AWLOCK             )
     `else
     , .M_AWLEN            ( G_AWLEN              )
     , .M_AWLOCK           ( G_AWLOCK             )
     `endif
     , .M_AWSIZE           ( G_AWSIZE             )
     , .M_AWBURST          ( G_AWBURST            )
     `ifdef AMBA_AXI_CACHE
     , .M_AWCACHE          ( G_AWCACHE            )
     `endif
     `ifdef AMBA_AXI_PROT
     , .M_AWPROT           ( G_AWPROT             )
     `endif
     , .M_AWVALID          ( G_AWVALID            )
     , .M_AWREADY          ( G_AWREADY            )
     `ifdef AMBA_AXI4
     , .M_AWQOS            ( G_AWQOS              )
     , .M_AWREGION         ( G_AWREGION           )
     `endif
     , .M_WID              ( G_WID                )
     , .M_WDATA            ( G_WDATA              )
     , .M_WSTRB            ( G_WSTRB              )
     , .M_WLAST            ( G_WLAST              )
     , .M_WVALID           ( G_WVALID             )
     , .M_WREADY           ( G_WREADY             )
     , .M_BID              ( G_BID                )
     , .M_BRESP            ( G_BRESP              )
     , .M_BVALID           ( G_BVALID             )
     , .M_BREADY           ( G_BREADY             )
     , .M_ARID             ( G_ARID               )
     , .M_ARADDR           ( G_ARADDR             )
     `ifdef AMBA_AXI4
     , .M_ARLEN            ( G_ARLEN              )
     , .M_ARLOCK           ( G_ARLOCK             )
     `else
     , .M_ARLEN            ( G_ARLEN              )
     , .M_ARLOCK           ( G_ARLOCK             )
     `endif
     , .M_ARSIZE           ( G_ARSIZE             )
     , .M_ARBURST          ( G_ARBURST            )
     `ifdef AMBA_AXI_CACHE
     , .M_ARCACHE          ( G_ARCACHE            )
     `endif
     `ifdef AMBA_AXI_PROT
     , .M_ARPROT           ( G_ARPROT             )
     `endif
     , .M_ARVALID          ( G_ARVALID            )
     , .M_ARREADY          ( G_ARREADY            )
     `ifdef AMBA_AXI4
     , .M_ARQOS            ( G_ARQOS              )
     , .M_ARREGION         ( G_ARREGION           )
     `endif
     , .M_RID              ( G_RID                )
     , .M_RDATA            ( G_RDATA              )
     , .M_RRESP            ( G_RRESP              )
     , .M_RLAST            ( G_RLAST              )
     , .M_RVALID           ( G_RVALID             )
     , .M_RREADY           ( G_RREADY             )
     , .S_AWID             ( S_AWID            [2]) // AXI_WIDTH_SID-1:0
     , .S_AWADDR           ( S_AWADDR          [2])
     `ifdef AMBA_AXI4
     , .S_AWLEN            ( S_AWLEN           [2])
     , .S_AWLOCK           ( S_AWLOCK          [2])
     `else
     , .S_AWLEN            ( S_AWLEN           [2])
     , .S_AWLOCK           ( S_AWLOCK          [2])
     `endif
     , .S_AWSIZE           ( S_AWSIZE          [2])
     , .S_AWBURST          ( S_AWBURST         [2])
     `ifdef AMBA_AXI_CACHE
     , .S_AWCACHE          ( S_AWCACHE         [2])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S_AWPROT           ( S_AWPROT          [2])
     `endif
     , .S_AWVALID          ( S_AWVALID         [2])
     , .S_AWREADY          ( S_AWREADY         [2])
     `ifdef AMBA_AXI4
     , .S_AWQOS            ( S_AWQOS           [2])
     , .S_AWREGION         ( S_AWREGION        [2])
     `endif
     , .S_WID              ( S_WID             [2])
     , .S_WDATA            ( S_WDATA           [2])
     , .S_WSTRB            ( S_WSTRB           [2])
     , .S_WLAST            ( S_WLAST           [2])
     , .S_WVALID           ( S_WVALID          [2])
     , .S_WREADY           ( S_WREADY          [2])
     , .S_BID              ( S_BID             [2])
     , .S_BRESP            ( S_BRESP           [2])
     , .S_BVALID           ( S_BVALID          [2])
     , .S_BREADY           ( S_BREADY          [2])
     , .S_ARID             ( S_ARID            [2])
     , .S_ARADDR           ( S_ARADDR          [2])
     `ifdef AMBA_AXI4
     , .S_ARLEN            ( S_ARLEN           [2])
     , .S_ARLOCK           ( S_ARLOCK          [2])
     `else
     , .S_ARLEN            ( S_ARLEN           [2])
     , .S_ARLOCK           ( S_ARLOCK          [2])
     `endif
     , .S_ARSIZE           ( S_ARSIZE          [2])
     , .S_ARBURST          ( S_ARBURST         [2])
     `ifdef AMBA_AXI_CACHE
     , .S_ARCACHE          ( S_ARCACHE         [2])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S_ARPROT           ( S_ARPROT          [2])
     `endif
     , .S_ARVALID          ( S_ARVALID         [2])
     , .S_ARREADY          ( S_ARREADY         [2])
     `ifdef AMBA_AXI4
     , .S_ARQOS            ( S_ARQOS           [2])
     , .S_ARREGION         ( S_ARREGION        [2])
     `endif
     , .S_RID              ( S_RID             [2])
     , .S_RDATA            ( S_RDATA           [2])
     , .S_RRESP            ( S_RRESP           [2])
     , .S_RLAST            ( S_RLAST           [2])
     , .S_RVALID           ( S_RVALID          [2])
     , .S_RREADY           ( S_RREADY          [2])
   );
   //---------------------------------------------------------------------------
   bram_axi_dual #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(`P_SIZE        )
               )
   u_bram_tx (
       .ARESETn            ( ARESETn             )
     , .ACLK               ( ACLK                )
     , .S0_AWID            ( S_AWID           [0])
     , .S0_AWADDR          ( S_AWADDR         [0])
     `ifdef AMBA_AXI4
     , .S0_AWLEN           ( S_AWLEN          [0])
     , .S0_AWLOCK          ( S_AWLOCK         [0])
     `else
     , .S0_AWLEN           ( S_AWLEN          [0])
     , .S0_AWLOCK          ( S_AWLOCK         [0])
     `endif
     , .S0_AWSIZE          ( S_AWSIZE         [0])
     , .S0_AWBURST         ( S_AWBURST        [0])
     `ifdef AMBA_AXI_CACHE
     , .S0_AWCACHE         ( S_AWCACHE        [0])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_AWPROT          ( S_AWPROT         [0])
     `endif
     , .S0_AWVALID         ( S_AWVALID        [0])
     , .S0_AWREADY         ( S_AWREADY        [0])
     `ifdef AMBA_AXI4
     , .S0_AWQOS           ( S_AWQOS          [0])
     , .S0_AWREGION        ( S_AWREGION       [0])
     `endif
     , .S0_WID             ( S_WID            [0])
     , .S0_WDATA           ( S_WDATA          [0])
     , .S0_WSTRB           ( S_WSTRB          [0])
     , .S0_WLAST           ( S_WLAST          [0])
     , .S0_WVALID          ( S_WVALID         [0])
     , .S0_WREADY          ( S_WREADY         [0])
     , .S0_BID             ( S_BID            [0])
     , .S0_BRESP           ( S_BRESP          [0])
     , .S0_BVALID          ( S_BVALID         [0])
     , .S0_BREADY          ( S_BREADY         [0])
     , .S0_ARID            ( S_ARID           [0])
     , .S0_ARADDR          ( S_ARADDR         [0])
     `ifdef AMBA_AXI4
     , .S0_ARLEN           ( S_ARLEN          [0])
     , .S0_ARLOCK          ( S_ARLOCK         [0])
     `else
     , .S0_ARLEN           ( S_ARLEN          [0])
     , .S0_ARLOCK          ( S_ARLOCK         [0])
     `endif
     , .S0_ARSIZE          ( S_ARSIZE         [0])
     , .S0_ARBURST         ( S_ARBURST        [0])
     `ifdef AMBA_AXI_CACHE
     , .S0_ARCACHE         ( S_ARCACHE        [0])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_ARPROT          ( S_ARPROT         [0])
     `endif
     , .S0_ARVALID         ( S_ARVALID        [0])
     , .S0_ARREADY         ( S_ARREADY        [0])
     `ifdef AMBA_AXI4
     , .S0_ARQOS           ( S_ARQOS          [0])
     , .S0_ARREGION        ( S_ARREGION       [0])
     `endif
     , .S0_RID             ( S_RID            [0])
     , .S0_RDATA           ( S_RDATA          [0])
     , .S0_RRESP           ( S_RRESP          [0])
     , .S0_RLAST           ( S_RLAST          [0])
     , .S0_RVALID          ( S_RVALID         [0])
     , .S0_RREADY          ( S_RREADY         [0])
     , .S1_AWID            (  6'h0              )
     , .S1_AWADDR          ( 32'h0              )
     `ifdef AMBA_AXI4
     , .S1_AWLEN           (  8'h0              )
     , .S1_AWLOCK          (  1'h0              )
     `else
     , .S1_AWLEN           (  4'h0              )
     , .S1_AWLOCK          (  2'h0              )
     `endif
     , .S1_AWSIZE          (  3'h0              )
     , .S1_AWBURST         (  2'h0              )
     `ifdef AMBA_AXI_CACHE
     , .S1_AWCACHE         (  4'h0              )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_AWPROT          (  3'h0              )
     `endif
     , .S1_AWVALID         (  1'h0              )
     , .S1_AWREADY         ( /*---*/            )
     `ifdef AMBA_AXI4
     , .S1_AWQOS           (  4'h0              )
     , .S1_AWREGION        (  4'h0              )
     `endif
     , .S1_WID             (  6'h0              )
     , .S1_WDATA           ( 32'h0              )
     , .S1_WSTRB           (  4'h0              )
     , .S1_WLAST           (  1'h0              )
     , .S1_WVALID          (  1'h0              )
     , .S1_WREADY          ( /*---*/            )
     , .S1_BID             (                    )
     , .S1_BRESP           (                    )
     , .S1_BVALID          (                    )
     , .S1_BREADY          ( 1'b1               )
     , .S1_ARID            ( {G_MID,G_ARID}     )
     , .S1_ARADDR          ( G_ARADDR           )
     `ifdef AMBA_AXI4
     , .S1_ARLEN           ( G_ARLEN            )
     , .S1_ARLOCK          ( G_ARLOCK           )
     `else
     , .S1_ARLEN           ( G_ARLEN            )
     , .S1_ARLOCK          ( G_ARLOCK           )
     `endif
     , .S1_ARSIZE          ( G_ARSIZE           )
     , .S1_ARBURST         ( G_ARBURST          )
     `ifdef AMBA_AXI_CACHE
     , .S1_ARCACHE         ( G_ARCACHE          )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_ARPROT          ( G_ARPROT           )
     `endif
     , .S1_ARVALID         ( G_ARVALID          )
     , .S1_ARREADY         ( G_ARREADY          )
     `ifdef AMBA_AXI4
     , .S1_ARQOS           ( G_ARQOS            )
     , .S1_ARREGION        ( G_ARREGION         )
     `endif
     , .S1_RID             ( {G_RID_tmp,G_RID}  )
     , .S1_RDATA           ( G_RDATA            )
     , .S1_RRESP           ( G_RRESP            )
     , .S1_RLAST           ( G_RLAST            )
     , .S1_RVALID          ( G_RVALID           )
     , .S1_RREADY          ( G_RREADY           )
   );
   //---------------------------------------------------------------------------
   bram_axi_dual #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(`P_SIZE        )
               )
   u_bram_rx (
       .ARESETn            ( ARESETn             )
     , .ACLK               ( ACLK                )
     , .S0_AWID            ( S_AWID           [1])
     , .S0_AWADDR          ( S_AWADDR         [1])
     `ifdef AMBA_AXI4
     , .S0_AWLEN           ( S_AWLEN          [1])
     , .S0_AWLOCK          ( S_AWLOCK         [1])
     `else
     , .S0_AWLEN           ( S_AWLEN          [1])
     , .S0_AWLOCK          ( S_AWLOCK         [1])
     `endif
     , .S0_AWSIZE          ( S_AWSIZE         [1])
     , .S0_AWBURST         ( S_AWBURST        [1])
     `ifdef AMBA_AXI_CACHE
     , .S0_AWCACHE         ( S_AWCACHE        [1])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_AWPROT          ( S_AWPROT         [1])
     `endif
     , .S0_AWVALID         ( S_AWVALID        [1])
     , .S0_AWREADY         ( S_AWREADY        [1])
     `ifdef AMBA_AXI4
     , .S0_AWQOS           ( S_AWQOS          [1])
     , .S0_AWREGION        ( S_AWREGION       [1])
     `endif
     , .S0_WID             ( S_WID            [1])
     , .S0_WDATA           ( S_WDATA          [1])
     , .S0_WSTRB           ( S_WSTRB          [1])
     , .S0_WLAST           ( S_WLAST          [1])
     , .S0_WVALID          ( S_WVALID         [1])
     , .S0_WREADY          ( S_WREADY         [1])
     , .S0_BID             ( S_BID            [1])
     , .S0_BRESP           ( S_BRESP          [1])
     , .S0_BVALID          ( S_BVALID         [1])
     , .S0_BREADY          ( S_BREADY         [1])
     , .S0_ARID            ( S_ARID           [1])
     , .S0_ARADDR          ( S_ARADDR         [1])
     `ifdef AMBA_AXI4
     , .S0_ARLEN           ( S_ARLEN          [1])
     , .S0_ARLOCK          ( S_ARLOCK         [1])
     `else
     , .S0_ARLEN           ( S_ARLEN          [1])
     , .S0_ARLOCK          ( S_ARLOCK         [1])
     `endif
     , .S0_ARSIZE          ( S_ARSIZE         [1])
     , .S0_ARBURST         ( S_ARBURST        [1])
     `ifdef AMBA_AXI_CACHE
     , .S0_ARCACHE         ( S_ARCACHE        [1])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_ARPROT          ( S_ARPROT         [1])
     `endif
     , .S0_ARVALID         ( S_ARVALID        [1])
     , .S0_ARREADY         ( S_ARREADY        [1])
     `ifdef AMBA_AXI4
     , .S0_ARQOS           ( S_ARQOS          [1])
     , .S0_ARREGION        ( S_ARREGION       [1])
     `endif
     , .S0_RID             ( S_RID            [1])
     , .S0_RDATA           ( S_RDATA          [1])
     , .S0_RRESP           ( S_RRESP          [1])
     , .S0_RLAST           ( S_RLAST          [1])
     , .S0_RVALID          ( S_RVALID         [1])
     , .S0_RREADY          ( S_RREADY         [1])
     , .S1_AWID            ( {G_MID,G_AWID}     )
     , .S1_AWADDR          ( G_AWADDR           )
     `ifdef AMBA_AXI4
     , .S1_AWLEN           ( G_AWLEN            )
     , .S1_AWLOCK          ( G_AWLOCK           )
     `else
     , .S1_AWLEN           ( G_AWLEN            )
     , .S1_AWLOCK          ( G_AWLOCK           )
     `endif
     , .S1_AWSIZE          ( G_AWSIZE           )
     , .S1_AWBURST         ( G_AWBURST          )
     `ifdef AMBA_AXI_CACHE
     , .S1_AWCACHE         ( G_AWCACHE          )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_AWPROT          ( G_AWPROT           )
     `endif
     , .S1_AWVALID         ( G_AWVALID          )
     , .S1_AWREADY         ( G_AWREADY          )
     `ifdef AMBA_AXI4
     , .S1_AWQOS           ( G_AWQOS            )
     , .S1_AWREGION        ( G_AWREGION         )
     `endif
     , .S1_WID             ( {G_MID,G_WID}      )
     , .S1_WDATA           ( G_WDATA            )
     , .S1_WSTRB           ( G_WSTRB            )
     , .S1_WLAST           ( G_WLAST            )
     , .S1_WVALID          ( G_WVALID           )
     , .S1_WREADY          ( G_WREADY           )
     , .S1_BID             ( {G_BID_tmp,G_BID}  )
     , .S1_BRESP           ( G_BRESP            )
     , .S1_BVALID          ( G_BVALID           )
     , .S1_BREADY          ( G_BREADY           )
     , .S1_ARID            (  6'h0              )
     , .S1_ARADDR          ( 32'h0              )
     `ifdef AMBA_AXI4
     , .S1_ARLEN           (  8'h0              )
     , .S1_ARLOCK          (  1'h0              )
     `else
     , .S1_ARLEN           (  4'h0              )
     , .S1_ARLOCK          (  2'h0              )
     `endif
     , .S1_ARSIZE          (  3'h0              )
     , .S1_ARBURST         (  2'h0              )
     `ifdef AMBA_AXI_CACHE
     , .S1_ARCACHE         (  4'h0              )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_ARPROT          (  3'h0              )
     `endif
     , .S1_ARVALID         (  1'h0              )
     , .S1_ARREADY         (                    )
     `ifdef AMBA_AXI4
     , .S1_ARQOS           ( 4'h0               )
     , .S1_ARREGION        ( 4'h0               )
     `endif
     , .S1_RID             (                    )
     , .S1_RDATA           (                    )
     , .S1_RRESP           (                    )
     , .S1_RLAST           (                    )
     , .S1_RVALID          (                    )
     , .S1_RREADY          (  1'h1              )
   );
   //---------------------------------------------------------------------------
   wire done_tx;
   //---------------------------------------------------------------------------
   tester_tx #(.AXI_MST_ID   (`AXI_MST_ID_TX)// Master ID
              ,.AXI_WIDTH_CID(AXI_WIDTH_CID)
              ,.AXI_WIDTH_ID (AXI_WIDTH_ID )// ID width in bits
              ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
              ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
              ,.ADDR_START_MEM_TX(`ADDR_START_MEM_TX)
              ,.ADDR_START_MEM_RX(`ADDR_START_MEM_RX)
              ,.ADDR_START_GMAC  (`ADDR_START_GMAC  )
              )
   u_tester_tx (
         .ARESETn            ( ARESETn          )
       , .ACLK               ( ACLK             )
       , .MID                ( M_MID         [0])
       , .AWID               ( M_AWID        [0])
       , .AWADDR             ( M_AWADDR      [0])
       , .AWLEN              ( M_AWLEN       [0])
       , .AWLOCK             ( M_AWLOCK      [0])
       , .AWSIZE             ( M_AWSIZE      [0])
       , .AWBURST            ( M_AWBURST     [0])
       `ifdef AMBA_AXI_CACHE
       , .AWCACHE            ( M_AWCACHE     [0])
       `endif
       `ifdef AMBA_AXI_PROT
       , .AWPROT             ( M_AWPROT      [0])
       `endif
       , .AWVALID            ( M_AWVALID     [0])
       , .AWREADY            ( M_AWREADY     [0])
       `ifdef AMBA_AXI4
       , .AWQOS              ( M_AWQOS       [0])
       , .AWREGION           ( M_AWREGION    [0])
       `endif
       , .WID                ( M_WID         [0])
       , .WDATA              ( M_WDATA       [0])
       , .WSTRB              ( M_WSTRB       [0])
       , .WLAST              ( M_WLAST       [0])
       , .WVALID             ( M_WVALID      [0])
       , .WREADY             ( M_WREADY      [0])
       , .BID                ( M_BID         [0])
       , .BRESP              ( M_BRESP       [0])
       , .BVALID             ( M_BVALID      [0])
       , .BREADY             ( M_BREADY      [0])
       , .ARID               ( M_ARID        [0])
       , .ARADDR             ( M_ARADDR      [0])
       , .ARLEN              ( M_ARLEN       [0])
       , .ARLOCK             ( M_ARLOCK      [0])
       , .ARSIZE             ( M_ARSIZE      [0])
       , .ARBURST            ( M_ARBURST     [0])
       `ifdef AMBA_AXI_CACHE
       , .ARCACHE            ( M_ARCACHE     [0])
       `endif
       `ifdef AMBA_AXI_PROT
       , .ARPROT             ( M_ARPROT      [0])
       `endif
       , .ARVALID            ( M_ARVALID     [0])
       , .ARREADY            ( M_ARREADY     [0])
       `ifdef AMBA_AXI4
       , .ARQOS              ( M_ARQOS       [0])
       , .ARREGION           ( M_ARREGION    [0])
       `endif
       , .RID                ( M_RID         [0])
       , .RDATA              ( M_RDATA       [0])
       , .RRESP              ( M_RRESP       [0])
       , .RLAST              ( M_RLAST       [0])
       , .RVALID             ( M_RVALID      [0])
       , .RREADY             ( M_RREADY      [0])
       , .done               ( done_tx          )
   );
   //---------------------------------------------------------------------------
   wire done_rx;
   //---------------------------------------------------------------------------
   tester_rx #(.AXI_MST_ID   (`AXI_MST_ID_RX)// Master ID
              ,.AXI_WIDTH_CID(AXI_WIDTH_CID)
              ,.AXI_WIDTH_ID (AXI_WIDTH_ID )// ID width in bits
              ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
              ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
              ,.ADDR_START_MEM_TX(`ADDR_START_MEM_TX)
              ,.ADDR_START_MEM_RX(`ADDR_START_MEM_RX)
              ,.ADDR_START_GMAC  (`ADDR_START_GMAC  )
              )
   u_tester_rx (
         .ARESETn            ( ARESETn          )
       , .ACLK               ( ACLK             )
       , .MID                ( M_MID         [1])
       , .AWID               ( M_AWID        [1])
       , .AWADDR             ( M_AWADDR      [1])
       , .AWLEN              ( M_AWLEN       [1])
       , .AWLOCK             ( M_AWLOCK      [1])
       , .AWSIZE             ( M_AWSIZE      [1])
       , .AWBURST            ( M_AWBURST     [1])
       `ifdef AMBA_AXI_CACHE
       , .AWCACHE            ( M_AWCACHE     [1])
       `endif
       `ifdef AMBA_AXI_PROT
       , .AWPROT             ( M_AWPROT      [1])
       `endif
       , .AWVALID            ( M_AWVALID     [1])
       , .AWREADY            ( M_AWREADY     [1])
       `ifdef AMBA_AXI4
       , .AWQOS              ( M_AWQOS       [1])
       , .AWREGION           ( M_AWREGION    [1])
       `endif
       , .WID                ( M_WID         [1])
       , .WDATA              ( M_WDATA       [1])
       , .WSTRB              ( M_WSTRB       [1])
       , .WLAST              ( M_WLAST       [1])
       , .WVALID             ( M_WVALID      [1])
       , .WREADY             ( M_WREADY      [1])
       , .BID                ( M_BID         [1])
       , .BRESP              ( M_BRESP       [1])
       , .BVALID             ( M_BVALID      [1])
       , .BREADY             ( M_BREADY      [1])
       , .ARID               ( M_ARID        [1])
       , .ARADDR             ( M_ARADDR      [1])
       , .ARLEN              ( M_ARLEN       [1])
       , .ARLOCK             ( M_ARLOCK      [1])
       , .ARSIZE             ( M_ARSIZE      [1])
       , .ARBURST            ( M_ARBURST     [1])
       `ifdef AMBA_AXI_CACHE
       , .ARCACHE            ( M_ARCACHE     [1])
       `endif
       `ifdef AMBA_AXI_PROT
       , .ARPROT             ( M_ARPROT      [1])
       `endif
       , .ARVALID            ( M_ARVALID     [1])
       , .ARREADY            ( M_ARREADY     [1])
       `ifdef AMBA_AXI4
       , .ARQOS              ( M_ARQOS       [1])
       , .ARREGION           ( M_ARREGION    [1])
       `endif
       , .RID                ( M_RID         [1])
       , .RDATA              ( M_RDATA       [1])
       , .RRESP              ( M_RRESP       [1])
       , .RLAST              ( M_RLAST       [1])
       , .RVALID             ( M_RVALID      [1])
       , .RREADY             ( M_RREADY      [1])
       , .done               ( done_rx          )
   );
   //---------------------------------------------------------------------------
   `ifdef RGMII
   assign #1.5 rgmii_rxc   = rgmii_gtxc;
   assign #1.5 rgmii_rxd   = rgmii_txd ;
   assign #1.5 rgmii_rxctl = rgmii_txctl;
   `else
   //gmii_phy #(.LOOPBACK(1),.MDIO_PHY_ADR(5'h2))
   //u_gmii_phy (
   //    .gmii_tx_clk     (gmii_gtxc  )
   //  , .gmii_txd        (gmii_txd   )
   //  , .gmii_txen       (gmii_txen  )
   //  , .gmii_txer       (gmii_txer  )
   //  , .gmii_crs        (gmii_crs   )
   //  , .gmii_col        (gmii_col   )
   //  , .gmii_rx_clk     (gmii_rxc   )
   //  , .gmii_rxd        (gmii_rxd   )
   //  , .gmii_rxdv       (gmii_rxdv  )
   //  , .gmii_rxer       (gmii_rxer  )
   //  , .gmii_mdc        (gmii_mdc   )
   //  , .gmii_mdio       (gmii_mdio  )
   //  `ifdef GMII_PHY_RESET
   //  , .gmii_phy_reset_n(RESET_N    )
   //  `endif
   //);
   reg   [ 7:0]  gmii_rxd_error=8'h0; // for error insersion (crc error)
   reg           gmii_rxer_error=1'b0; // for error insersion (early termination)
   assign gmii_rxc  = gmii_gtxc;
   assign gmii_rxdv = gmii_txen;
   assign gmii_rxd  = gmii_txd | gmii_rxd_error;
   assign gmii_rxer = gmii_txer| gmii_rxer_error;
   assign gmii_crs  = 1'b0;
   assign gmii_col  = 1'b0;
   assign gmii_mdio = 1'b0;
   reg [15:0] rx_cnt=16'h0;
   always @ (posedge gmii_rxc) begin
       if (gmii_rxdv==1'b0) rx_cnt <= 16'h0;
       else                 rx_cnt <= rx_cnt + 1;
   end
   `endif
   //---------------------------------------------------------------------------
//initial begin
//     repeat (500000) @ (posedge ACLK);
//     repeat (50000) @ (posedge ACLK);
//     $finish(2);
//end
   initial begin
        RESET_N = 1'b0;
        repeat ( 3) @ (posedge ACLK);
        RESET_N = 1'b1;
        repeat (10) @ (posedge ACLK);
        //-------------------------------------
        wait (done_tx==1'b1);
        //-------------------------------------
        repeat (50) @ (posedge ACLK);
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
