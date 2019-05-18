//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// http://www.future-ds.com
//------------------------------------------------------------------------------
// dut_axi_peri.v
//------------------------------------------------------------------------------
// VERSION: 2018.05.15.
//------------------------------------------------------------------------------
   wire        IRQ_GMAC;
//------------------------------------------------------------------------------
   assign M_MID[0]=1;
//------------------------------------------------------------------------------
        assign ARESETn       = s_axi_aresetn;
        assign ACLK          = s_axi_aclk   ;
        assign M_MID     [0] = s_axi_mid    ;
        assign M_AWID    [0] = s_axi_awid   ;
        assign M_AWADDR  [0] = s_axi_awaddr ;
        assign M_AWLEN   [0] = s_axi_awlen  ;
        assign M_AWLOCK  [0] = s_axi_awlock ;
        assign M_AWSIZE  [0] = s_axi_awsize ;
        assign M_AWBURST [0] = s_axi_awburst;
        `ifdef  AMBA_AXI_CACHE
        assign M_AWCACHE [0] = s_axi_awcache;
        `endif
        `ifdef AMBA_AXI_PROT
        assign M_AWPROT  [0] = s_axi_awprot ;
        `endif
        assign M_AWVALID [0] = s_axi_awvalid;
        assign s_axi_awready = M_AWREADY [0];
        `ifdef AMBA_AXI4
        assign M_AWQOS   [0] = 4'h0;
        assign M_AWREGION[0] = 4'h0;
        `endif
        `ifdef AMBA_AXI_AWUSER
        assign M_AWUSER  [0] = 0;
        `endif
        assign M_WID     [0] = s_axi_wid    ;
        assign M_WDATA   [0] = s_axi_wdata  ;
        assign M_WSTRB   [0] = s_axi_wstrb  ;
        assign M_WLAST   [0] = s_axi_wlast  ;
        assign M_WVALID  [0] = s_axi_wvalid ;
        assign s_axi_wready  = M_WREADY  [0];
        `ifdef AMBA_AXI_AWUSER
        assign M_WUSER   [0] = 0;
        `endif
        assign s_axi_bid     = M_BID     [0];
        assign s_axi_bresp   = M_BRESP   [0];
        assign s_axi_bvalid  = M_BVALID  [0];
        assign M_BREADY  [0] = s_axi_bready ;
        assign M_ARID    [0] = s_axi_arid   ;
        assign M_ARADDR  [0] = s_axi_araddr ;
        assign M_ARLEN   [0] = s_axi_arlen  ;
        assign M_ARLOCK  [0] = s_axi_arlock ;
        assign M_ARSIZE  [0] = s_axi_arsize ;
        assign M_ARBURST [0] = s_axi_arburst;
        `ifdef  AMBA_AXI_CACHE
        assign M_ARCACHE [0] = s_axi_arcache;
        `endif
        `ifdef AMBA_AXI_PROT
        assign M_ARPROT  [0] = s_axi_arprot ;
        `endif
        assign M_ARVALID [0] = s_axi_arvalid;
        assign s_axi_arready = M_ARREADY [0];
        `ifdef AMBA_AXI4
        assign M_ARQOS   [0] = 4'h0;
        assign M_ARREGION[0] = 4'h0;
        `endif
        `ifdef AMBA_AXI_AWUSER
        assign M_ARUSER  [0] = 0;
        `endif
        assign s_axi_rid     = M_RID     [0];
        assign s_axi_rdata   = M_RDATA   [0];
        assign s_axi_rresp   = M_RRESP   [0];
        assign s_axi_rlast   = M_RLAST   [0];
        assign s_axi_rvalid  = M_RVALID  [0];
        assign M_RREADY  [0] = s_axi_rready ;

//------------------------------------------------------------------------------
   `ifdef SIM
   `define BUS_DELAY  #(1)
   `else
   `define BUS_DELAY
   `endif
   //---------------------------------------------------------------------------
   wire  [AXI_WIDTH_CID-1:0]    `BUS_DELAY G_MID     ;
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY G_AWID    ;
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY G_AWADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY G_AWLEN   ;
   wire                         `BUS_DELAY G_AWLOCK  ;
   `else
   wire  [ 3:0]                 `BUS_DELAY G_AWLEN   ;
   wire  [ 1:0]                 `BUS_DELAY G_AWLOCK  ;
   `endif
   wire  [ 2:0]                 `BUS_DELAY G_AWSIZE  ;
   wire  [ 1:0]                 `BUS_DELAY G_AWBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY G_AWCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY G_AWPROT  ;
   `endif
   wire                         `BUS_DELAY G_AWVALID ;
   wire                         `BUS_DELAY G_AWREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY G_AWQOS   ;
   wire  [ 3:0]                 `BUS_DELAY G_AWREGION;
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [AXI_WIDTH_AWUSER-1:0] `BUS_DELAY G_AWUSER  ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY G_WID     ;
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY G_WDATA   ;
   wire  [AXI_WIDTH_DS-1:0]     `BUS_DELAY G_WSTRB   ;
   wire                         `BUS_DELAY G_WLAST   ;
   wire                         `BUS_DELAY G_WVALID  ;
   wire                         `BUS_DELAY G_WREADY  ;
   `ifdef AMBA_AXI_WUSER
   wire  [AXI_WIDTH_WUSER-1:0]  `BUS_DELAY G_WUSER   ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY G_BID     ; wire [AXI_WIDTH_CID-1:0] G_BID_tmp;
   wire  [ 1:0]                 `BUS_DELAY G_BRESP   ;
   wire                         `BUS_DELAY G_BVALID  ;
   wire                         `BUS_DELAY G_BREADY  ;
   `ifdef AMBA_AXI_BUSER
   wire  [AXI_WIDTH_BUSER-1:0]  `BUS_DELAY G_BUSER   ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY G_ARID    ;
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY G_ARADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY G_ARLEN   ;
   wire                         `BUS_DELAY G_ARLOCK  ;
   `else
   wire  [ 3:0]                 `BUS_DELAY G_ARLEN   ;
   wire  [ 1:0]                 `BUS_DELAY G_ARLOCK  ;
   `endif
   wire  [ 2:0]                 `BUS_DELAY G_ARSIZE  ;
   wire  [ 1:0]                 `BUS_DELAY G_ARBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY G_ARCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY G_ARPROT  ;
   `endif
   wire                         `BUS_DELAY G_ARVALID ;
   wire                         `BUS_DELAY G_ARREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY G_ARQOS   ;
   wire  [ 3:0]                 `BUS_DELAY G_ARREGION;
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [AXI_WIDTH_ARUSER-1:0] `BUS_DELAY G_ARUSER  ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY G_RID     ; wire [AXI_WIDTH_CID-1:0] G_RID_tmp;
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY G_RDATA   ;
   wire  [ 1:0]                 `BUS_DELAY G_RRESP   ;
   wire                         `BUS_DELAY G_RLAST   ;
   wire                         `BUS_DELAY G_RVALID  ;
   wire                         `BUS_DELAY G_RREADY  ;
   `ifdef AMBA_AXI_RUSER
   wire  [AXI_WIDTH_RUSER-1:0]  `BUS_DELAY G_RUSER   ;
   `endif
//------------------------------------------------------------------------------
   wire       gmiiU_gtxc;
   wire [7:0] gmiiU_txd ;
   wire       gmiiU_txen;
   wire       gmiiU_txer;
   wire       gmiiU_rxc ;
   wire [7:0] gmiiU_rxd ;
   wire       gmiiU_rxdv;
   wire       gmiiU_rxer;
   wire       gmiiU_col =1'b0;
   wire       gmiiU_crs =1'b0;
//------------------------------------------------------------------------------
   gig_eth_mac_danh_axi
                        `ifdef SIM
                        #(.AXI_MST_ID       (3)
                         ,.AXI_WIDTH_CID    (AXI_WIDTH_CID)// Channel ID width in bits
                         ,.AXI_WIDTH_ID     (AXI_WIDTH_ID )// ID width in bits
                         ,.AXI_WIDTH_AD     (AXI_WIDTH_AD )// address width
                         ,.AXI_WIDTH_DA     (AXI_WIDTH_DA )// data width
                         ,.ACLK_FREQ        (P_ACLK_FREQ  )// for PHY_RESET_N
                         ,.P_TX_FIFO_DEPTH  (P_TX_FIFO_DEPTH  )
                         ,.P_RX_FIFO_DEPTH  (P_RX_FIFO_DEPTH  )
                         ,.P_TX_DESCRIPTOR_FAW(P_TX_DESCRIPTOR_FAW)
                         ,.P_RX_DESCRIPTOR_FAW(P_RX_DESCRIPTOR_FAW)
                         ,.P_RX_FIFO_BNUM_FAW (P_RX_FIFO_BNUM_FAW )
                         ,.P_TXCLK_INV        (P_TXCLK_INV  )
                         ,.FPGA_FAMILY        (FPGA_FAMILY)
                         )
                         `endif
   u_mac (
       .ARESETn         ( ARESETn  )
     , .ACLK            ( ACLK     )
     , .IRQ             ( IRQ_GMAC )
     , .gbe_phy_reset_n (              )
     `ifdef RGMII
     , .rgmii_gtxc      ( rgmiiU_gtxc  )
     , .rgmii_txd       ( rgmiiU_rxd   )
     , .rgmii_txctl     ( rgmiiU_rxctl )
     , .rgmii_rxc       ( rgmiiU_txc   )
     , .rgmii_rxd       ( rgmiiU_txd   )
     , .rgmii_rxctl     ( rgmiiU_txctl )
     , .gtx_clk         ( gtx_clk        )
     , .gtx_clk90       ( gtx_clk90      )
     , .gtx_clk_stable  ( gtx_clk_stable )
     `else
     , .gmii_gtxc       ( gmiiU_rxc  ) // be careful its direction (output)
     , .gmii_txd        ( gmiiU_rxd  ) // be careful its direction (output)
     , .gmii_txen       ( gmiiU_rxdv ) // be careful its direction (output)
     , .gmii_txer       ( gmiiU_rxer ) // be careful its direction (output)
     , .gmii_rxc        ( gmiiU_gtxc ) // be careful its direction (input)
     , .gmii_rxd        ( gmiiU_txd  ) // be careful its direction (input)
     , .gmii_rxdv       ( gmiiU_txen ) // be careful its direction (input)
     , .gmii_rxer       ( gmiiU_txer ) // be careful its direction (input)
     , .gmii_col        ( gmiiU_col  ) // be careful its direction (input)
     , .gmii_crs        ( gmiiU_crs  ) // be careful its direction (input)
     , .gtx_clk         ( gtx_clk        )
     , .gtx_clk_stable  ( gtx_clk_stable )
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
     , .S_AWID             ( S_AWID            [3]) // AXI_WIDTH_SID-1:0
     , .S_AWADDR           ( S_AWADDR          [3])
     `ifdef AMBA_AXI4
     , .S_AWLEN            ( S_AWLEN           [3])
     , .S_AWLOCK           ( S_AWLOCK          [3])
     `else
     , .S_AWLEN            ( S_AWLEN           [3])
     , .S_AWLOCK           ( S_AWLOCK          [3])
     `endif
     , .S_AWSIZE           ( S_AWSIZE          [3])
     , .S_AWBURST          ( S_AWBURST         [3])
     `ifdef AMBA_AXI_CACHE
     , .S_AWCACHE          ( S_AWCACHE         [3])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S_AWPROT           ( S_AWPROT          [3])
     `endif
     , .S_AWVALID          ( S_AWVALID         [3])
     , .S_AWREADY          ( S_AWREADY         [3])
     `ifdef AMBA_AXI4
     , .S_AWQOS            ( S_AWQOS           [3])
     , .S_AWREGION         ( S_AWREGION        [3])
     `endif
     , .S_WID              ( S_WID             [3])
     , .S_WDATA            ( S_WDATA           [3])
     , .S_WSTRB            ( S_WSTRB           [3])
     , .S_WLAST            ( S_WLAST           [3])
     , .S_WVALID           ( S_WVALID          [3])
     , .S_WREADY           ( S_WREADY          [3])
     , .S_BID              ( S_BID             [3])
     , .S_BRESP            ( S_BRESP           [3])
     , .S_BVALID           ( S_BVALID          [3])
     , .S_BREADY           ( S_BREADY          [3])
     , .S_ARID             ( S_ARID            [3])
     , .S_ARADDR           ( S_ARADDR          [3])
     `ifdef AMBA_AXI4
     , .S_ARLEN            ( S_ARLEN           [3])
     , .S_ARLOCK           ( S_ARLOCK          [3])
     `else
     , .S_ARLEN            ( S_ARLEN           [3])
     , .S_ARLOCK           ( S_ARLOCK          [3])
     `endif
     , .S_ARSIZE           ( S_ARSIZE          [3])
     , .S_ARBURST          ( S_ARBURST         [3])
     `ifdef AMBA_AXI_CACHE
     , .S_ARCACHE          ( S_ARCACHE         [3])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S_ARPROT           ( S_ARPROT          [3])
     `endif
     , .S_ARVALID          ( S_ARVALID         [3])
     , .S_ARREADY          ( S_ARREADY         [3])
     `ifdef AMBA_AXI4
     , .S_ARQOS            ( S_ARQOS           [3])
     , .S_ARREGION         ( S_ARREGION        [3])
     `endif
     , .S_RID              ( S_RID             [3])
     , .S_RDATA            ( S_RDATA           [3])
     , .S_RRESP            ( S_RRESP           [3])
     , .S_RLAST            ( S_RLAST           [3])
     , .S_RVALID           ( S_RVALID          [3])
     , .S_RREADY           ( S_RREADY          [3])
   );
//------------------------------------------------------------------------------
    `ifdef RGMII
    `else
    gig_eth_hsr_danh
                `ifdef SIM
                #(.NUM_ENTRIES_PROXY     (NUM_ENTRIES_PROXY)// should be power of 2
                 ,.NUM_ENTRIES_QR        (NUM_ENTRIES_QR   )// should be power of 2
                 ,.FPGA_FAMILY           (FPGA_FAMILY)
                 ,.TXCLK_INV             (P_TXCLK_INV)
                 ,.CONF_MAC_ADDR         (CONF_MAC_ADDR    )// only valid when DANH_OR_REDBOX="DANH"
                 ,.CONF_HSR_NET_ID       (CONF_HSR_NET_ID  )
                 ,.DANH_OR_REDBOX        (DANH_OR_REDBOX   )
                 ,.CONF_PROMISCUOUS      (CONF_PROMISCUOUS )// promiscuos when 1
                 ,.CONF_DROP_NON_HSR     (CONF_DROP_NON_HSR)// drop non-hsr packet when 1
                 ,.CONF_HSR_QR           (CONF_HSR_QR      )// Quick Remove enabled when 1
                 ,.CONF_SNOOP            (CONF_SNOOP       )// remove HSR head when 0
                 )
                 `endif
    u_hsr (
           .gtx_clk      ( gtx_clk          ) // 125Mhz
         , .reset_n      ( ARESETn          )
         , .board_id     ( board_id         )
         , .hsr_ready    ( hsr_ready        )
         , .phy_resetU_n (                  )
         , .phy_resetA_n ( gbeA_phy_reset_n )
         , .phy_resetB_n ( gbeB_phy_reset_n )
         , .phy_readyU   (                  )
         , .phy_readyA   (                  )
         , .phy_readyB   (                  )

         , .gmiiU_gtxc  ( gmiiU_gtxc ) // output
         , .gmiiU_txd   ( gmiiU_txd  ) // output
         , .gmiiU_txen  ( gmiiU_txen ) // output
         , .gmiiU_txer  ( gmiiU_txer ) // output
         , .gmiiU_rxc   ( gmiiU_rxc  ) // input
         , .gmiiU_rxd   ( gmiiU_rxd  ) // input
         , .gmiiU_rxdv  ( gmiiU_rxdv ) // input
         , .gmiiU_rxer  ( gmiiU_rxer ) // input
         , .gmiiU_col   ( gmiiU_col  ) // input
         , .gmiiU_crs   ( gmiiU_crs  ) // input
                                    
         , .gmiiA_gtxc  ( gmiiA_gtxc )
         , .gmiiA_txd   ( gmiiA_txd  )
         , .gmiiA_txen  ( gmiiA_txen )
         , .gmiiA_txer  ( gmiiA_txer )
         , .gmiiA_rxc   ( gmiiA_rxc  )
         , .gmiiA_rxd   ( gmiiA_rxd  )
         , .gmiiA_rxdv  ( gmiiA_rxdv )
         , .gmiiA_rxer  ( gmiiA_rxer )
         , .gmiiA_col   ( gmiiA_col  )
         , .gmiiA_crs   ( gmiiA_crs  )
                                    
         , .gmiiB_gtxc  ( gmiiB_gtxc )
         , .gmiiB_txd   ( gmiiB_txd  )
         , .gmiiB_txen  ( gmiiB_txen )
         , .gmiiB_txer  ( gmiiB_txer )
         , .gmiiB_rxc   ( gmiiB_rxc  )
         , .gmiiB_rxd   ( gmiiB_rxd  )
         , .gmiiB_rxdv  ( gmiiB_rxdv )
         , .gmiiB_rxer  ( gmiiB_rxer )
         , .gmiiB_col   ( gmiiB_col  )
         , .gmiiB_crs   ( gmiiB_crs  )

         , .PRESETn    ( PRESETn    )
         , .PCLK       ( PCLK       )
         , .PSEL       ( PSEL    [1])
         , .PENABLE    ( PENABLE    )
         , .PADDR      ( PADDR      )
         , .PWRITE     ( PWRITE     )
         , .PWDATA     ( PWDATA     )
         , .PRDATA     ( PRDATA  [1])

         `ifdef HSR_PERFORMANCE
         , .host_probe_txen(host_probe_txen)
         , .host_probe_rxdv(host_probe_rxdv)
         , .netA_probe_txen(netA_probe_txen)
         , .netA_probe_rxdv(netA_probe_rxdv)
         , .netB_probe_txen(netB_probe_txen)
         , .netB_probe_rxdv(netB_probe_rxdv)
         `endif
    );
    `ifdef AMBA_APB3
    assign PREADY [1]=1'b1;
    assign PSLVERR[1]=1'b0;
    `endif
    `endif
//------------------------------------------------------------------------------
   //---------------------------------------------------------------------------
   bram_axi_dual #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(P_SIZE_BRAM_TX )
               )
   u_bram_tx (
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
     , .S1_AWID            ({AXI_WIDTH_SID{1'b0}})
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
     , .S1_WID             ({AXI_WIDTH_SID{1'b0}})
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
                  ,.P_SIZE_IN_BYTES(P_SIZE_BRAM_RX )
               )
   u_bram_rx (
       .ARESETn            ( ARESETn             )
     , .ACLK               ( ACLK                )
     , .S0_AWID            ( S_AWID           [2])
     , .S0_AWADDR          ( S_AWADDR         [2])
     `ifdef AMBA_AXI4
     , .S0_AWLEN           ( S_AWLEN          [2])
     , .S0_AWLOCK          ( S_AWLOCK         [2])
     `else
     , .S0_AWLEN           ( S_AWLEN          [2])
     , .S0_AWLOCK          ( S_AWLOCK         [2])
     `endif
     , .S0_AWSIZE          ( S_AWSIZE         [2])
     , .S0_AWBURST         ( S_AWBURST        [2])
     `ifdef AMBA_AXI_CACHE
     , .S0_AWCACHE         ( S_AWCACHE        [2])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_AWPROT          ( S_AWPROT         [2])
     `endif
     , .S0_AWVALID         ( S_AWVALID        [2])
     , .S0_AWREADY         ( S_AWREADY        [2])
     `ifdef AMBA_AXI4
     , .S0_AWQOS           ( S_AWQOS          [2])
     , .S0_AWREGION        ( S_AWREGION       [2])
     `endif
     , .S0_WID             ( S_WID            [2])
     , .S0_WDATA           ( S_WDATA          [2])
     , .S0_WSTRB           ( S_WSTRB          [2])
     , .S0_WLAST           ( S_WLAST          [2])
     , .S0_WVALID          ( S_WVALID         [2])
     , .S0_WREADY          ( S_WREADY         [2])
     , .S0_BID             ( S_BID            [2])
     , .S0_BRESP           ( S_BRESP          [2])
     , .S0_BVALID          ( S_BVALID         [2])
     , .S0_BREADY          ( S_BREADY         [2])
     , .S0_ARID            ( S_ARID           [2])
     , .S0_ARADDR          ( S_ARADDR         [2])
     `ifdef AMBA_AXI4
     , .S0_ARLEN           ( S_ARLEN          [2])
     , .S0_ARLOCK          ( S_ARLOCK         [2])
     `else
     , .S0_ARLEN           ( S_ARLEN          [2])
     , .S0_ARLOCK          ( S_ARLOCK         [2])
     `endif
     , .S0_ARSIZE          ( S_ARSIZE         [2])
     , .S0_ARBURST         ( S_ARBURST        [2])
     `ifdef AMBA_AXI_CACHE
     , .S0_ARCACHE         ( S_ARCACHE        [2])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_ARPROT          ( S_ARPROT         [2])
     `endif
     , .S0_ARVALID         ( S_ARVALID        [2])
     , .S0_ARREADY         ( S_ARREADY        [2])
     `ifdef AMBA_AXI4
     , .S0_ARQOS           ( S_ARQOS          [2])
     , .S0_ARREGION        ( S_ARREGION       [2])
     `endif
     , .S0_RID             ( S_RID            [2])
     , .S0_RDATA           ( S_RDATA          [2])
     , .S0_RRESP           ( S_RRESP          [2])
     , .S0_RLAST           ( S_RLAST          [2])
     , .S0_RVALID          ( S_RVALID         [2])
     , .S0_RREADY          ( S_RREADY         [2])
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
     , .S1_ARID            ({AXI_WIDTH_SID{1'b0}})
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
//------------------------------------------------------------------------------
   bram_axi #(.AXI_WIDTH_CID(AXI_WIDTH_CID)// Channel ID width in bits
             ,.AXI_WIDTH_ID (AXI_WIDTH_ID )// ID width in bits
             ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
             ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
             ,.P_SIZE_IN_BYTES(P_SIZE_BRAM_MEM))
   u_mem_axi (
          .ARESETn            (   ARESETn      )
        , .ACLK               (   ACLK         )
        , .AWID               ( S_AWID      [0])
        , .AWADDR             ( S_AWADDR    [0])
        , .AWLEN              ( S_AWLEN     [0])
        , .AWLOCK             ( S_AWLOCK    [0])
        , .AWSIZE             ( S_AWSIZE    [0])
        , .AWBURST            ( S_AWBURST   [0])
        `ifdef AMBA_AXI_CACHE
        , .AWCACHE            ( S_AWCACHE   [0])
        `endif
        `ifdef AMBA_AXI_PROT  
        , .AWPROT             ( S_AWPROT    [0])
        `endif
        , .AWVALID            ( S_AWVALID   [0])
        , .AWREADY            ( S_AWREADY   [0])
        `ifdef AMBA_AXI4      
        , .AWQOS              ( S_AWQOS     [0])
        , .AWREGION           ( S_AWREGION  [0])
        `endif
        , .WID                ( S_WID       [0])
        , .WDATA              ( S_WDATA     [0])
        , .WSTRB              ( S_WSTRB     [0])
        , .WLAST              ( S_WLAST     [0])
        , .WVALID             ( S_WVALID    [0])
        , .WREADY             ( S_WREADY    [0])
        , .BID                ( S_BID       [0]) //[AXI_WIDTH_SID-1:0]
        , .BRESP              ( S_BRESP     [0])
        , .BVALID             ( S_BVALID    [0])
        , .BREADY             ( S_BREADY    [0])
        , .ARID               ( S_ARID      [0])
        , .ARADDR             ( S_ARADDR    [0])
        , .ARLEN              ( S_ARLEN     [0])
        , .ARLOCK             ( S_ARLOCK    [0])
        , .ARSIZE             ( S_ARSIZE    [0])
        , .ARBURST            ( S_ARBURST   [0])
        `ifdef AMBA_AXI_CACHE
        , .ARCACHE            ( S_ARCACHE   [0])
        `endif
        `ifdef AMBA_AXI_PROT
        , .ARPROT             ( S_ARPROT    [0])
        `endif
        , .ARVALID            ( S_ARVALID   [0])
        , .ARREADY            ( S_ARREADY   [0])
        `ifdef AMBA_AXI4     
        , .ARQOS              ( S_ARQOS     [0])
        , .ARREGION           ( S_ARREGION  [0])
        `endif
        , .RID                ( S_RID       [0]) //[AXI_WIDTH_SID-1:0]
        , .RDATA              ( S_RDATA     [0])
        , .RRESP              ( S_RRESP     [0])
        , .RLAST              ( S_RLAST     [0])
        , .RVALID             ( S_RVALID    [0])
        , .RREADY             ( S_RREADY    [0])
   );
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.05.15: by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
