//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// hsr_node.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
//------------------------------------------------------------------------------
`include "tester.v"
`timescale 1ns/1ps

module hsr_node
     #(parameter NUM_OF_HSR_NODE=2
               , HSR_ID=0
               , TX_ENABLE=0
               , MAC_ADDR=48'hF0_12_34_56_78_00
               , FPGA_FAMILY="VIRTEX6"
               , TXCLK_INV  =1'b0
               , DANH_OR_REDBOX="DANH")
(
       output  wire         gmiiA_gtxc
     , output  wire  [7:0]  gmiiA_txd 
     , output  wire         gmiiA_txen
     , output  wire         gmiiA_txer
     , input   wire         gmiiA_rxc 
     , input   wire  [7:0]  gmiiA_rxd 
     , input   wire         gmiiA_rxdv
     , input   wire         gmiiA_rxer
     , input   wire         gmiiA_col
     , input   wire         gmiiA_crs

     , output  wire         gmiiB_gtxc
     , output  wire  [7:0]  gmiiB_txd 
     , output  wire         gmiiB_txen
     , output  wire         gmiiB_txer
     , input   wire         gmiiB_rxc 
     , input   wire  [7:0]  gmiiB_rxd 
     , input   wire         gmiiB_rxdv
     , input   wire         gmiiB_rxer
     , input   wire         gmiiB_col
     , input   wire         gmiiB_crs
);
   //---------------------------------------------------------------------------
   reg  RESET_N=1'b0;
   //---------------------------------------------------------------------------
`ifdef BOARD_ML605
   localparam real CLK200_FREQ=200_000_000.0;
   localparam real CLK200_PERIOD_HALF=1_000_000_000.0/(CLK200_FREQ*2.0);
   reg  CLK200M=1'b0;
   always #CLK200_PERIOD_HALF CLK200M <= ~CLK200M;
   wire CLK200_P=CLK200M;
   wire CLK200_N=~CLK200M;
`elsif BOARD_ZED
   localparam real CLK100_FREQ=100_000_000.0;
   localparam real CLK100_PERIOD_HALF=1_000_000_000.0/(CLK100_FREQ*2.0);
   reg  CLK100=1'b0;
   always #CLK100_PERIOD_HALF CLK100 <= ~CLK100;
`elsif BOARD_VC
   localparam real CLK125_FREQ=125_000_000.0;
   localparam real CLK125_PERIOD_HALF=1_000_000_000.0/(CLK125_FREQ*2.0);
   reg  CLK125=1'b0;
   always #CLK125_PERIOD_HALF CLK125 <= ~CLK125;
`endif
   //---------------------------------------------------------------------------
   reg  [47:0]   mac_addr={MAC_ADDR[47:8],HSR_ID[7:0]};
   wire          gmii_mdio; pullup Um(gmii_mdio);
   //---------------------------------------------------------------------------
   localparam AXI_WIDTH_AD=32    // address width
            , AXI_WIDTH_DA=32    // data width
            , AXI_WIDTH_DS=(AXI_WIDTH_DA/8);
   wire                        s_axi_aresetn; // output from fpga
   wire                        s_axi_aclk   ; // output from fpga
   wire  [AXI_WIDTH_AD-1:0]    s_axi_awaddr ;
   wire  [ 7:0]                s_axi_awlen  ;
   wire                        s_axi_awlock ;
   wire  [ 2:0]                s_axi_awsize ;
   wire  [ 1:0]                s_axi_awburst;
   wire  [ 3:0]                s_axi_awcache;
   wire  [ 2:0]                s_axi_awprot ;
   wire                        s_axi_awvalid;
   wire                        s_axi_awready;
   wire  [AXI_WIDTH_DA-1:0]    s_axi_wdata  ;
   wire  [AXI_WIDTH_DS-1:0]    s_axi_wstrb  ;
   wire                        s_axi_wlast  ;
   wire                        s_axi_wvalid ;
   wire                        s_axi_wready ;
   wire  [ 1:0]                s_axi_bresp  ;
   wire                        s_axi_bvalid ;
   wire                        s_axi_bready ;
   wire  [AXI_WIDTH_AD-1:0]    s_axi_araddr ;
   wire  [ 7:0]                s_axi_arlen  ;
   wire                        s_axi_arlock ;
   wire  [ 2:0]                s_axi_arsize ;
   wire  [ 1:0]                s_axi_arburst;
   wire  [ 3:0]                s_axi_arcache;
   wire  [ 2:0]                s_axi_arprot ;
   wire                        s_axi_arvalid;
   wire                        s_axi_arready;
   wire  [AXI_WIDTH_DA-1:0]    s_axi_rdata  ;
   wire  [ 1:0]                s_axi_rresp  ;
   wire                        s_axi_rlast  ;
   wire                        s_axi_rvalid ;
   wire                        s_axi_rready ;
   //---------------------------------------------------------------------------
   hsr_danh_axi #(.FPGA_FAMILY(FPGA_FAMILY)
                 ,.TXCLK_INV(TXCLK_INV))
   u_fpga (
         .BOARD_CLK_IN     ( CLK100     )
       , .BOARD_RST_SW     ( 1'b0       )
       , .BOARD_SLIDE_SW   ( HSR_ID[7:0])
       , .BOARD_LED        (            )

       , .s_axi_aresetn  ( s_axi_aresetn )
       , .s_axi_aclk     ( s_axi_aclk    )
       , .s_axi_awaddr   ( s_axi_awaddr  )
       , .s_axi_awlen    ( s_axi_awlen   )
       , .s_axi_awlock   ( s_axi_awlock  )
       , .s_axi_awsize   ( s_axi_awsize  )
       , .s_axi_awburst  ( s_axi_awburst )
       , .s_axi_awcache  ( s_axi_awcache )
       , .s_axi_awprot   ( s_axi_awprot  )
       , .s_axi_awvalid  ( s_axi_awvalid )
       , .s_axi_awready  ( s_axi_awready )
       , .s_axi_wdata    ( s_axi_wdata   )
       , .s_axi_wstrb    ( s_axi_wstrb   )
       , .s_axi_wlast    ( s_axi_wlast   )
       , .s_axi_wvalid   ( s_axi_wvalid  )
       , .s_axi_wready   ( s_axi_wready  )
       , .s_axi_bresp    ( s_axi_bresp   )
       , .s_axi_bvalid   ( s_axi_bvalid  )
       , .s_axi_bready   ( s_axi_bready  )
       , .s_axi_araddr   ( s_axi_araddr  )
       , .s_axi_arlen    ( s_axi_arlen   )
       , .s_axi_arlock   ( s_axi_arlock  )
       , .s_axi_arsize   ( s_axi_arsize  )
       , .s_axi_arburst  ( s_axi_arburst )
       , .s_axi_arcache  ( s_axi_arcache )
       , .s_axi_arprot   ( s_axi_arprot  )
       , .s_axi_arvalid  ( s_axi_arvalid )
       , .s_axi_arready  ( s_axi_arready )
       , .s_axi_rdata    ( s_axi_rdata   )
       , .s_axi_rresp    ( s_axi_rresp   )
       , .s_axi_rlast    ( s_axi_rlast   )
       , .s_axi_rvalid   ( s_axi_rvalid  )
       , .s_axi_rready   ( s_axi_rready  )

       , .GBE_MDC          (            )
       , .GBE_MDIO         ( gmii_mdio  )

       , .GBEA_PHY_RESET_N (            )
       , .GBEA_GTXC        ( gmiiA_gtxc )
       , .GBEA_TXD         ( gmiiA_txd  )
       , .GBEA_TXEN        ( gmiiA_txen )
       , .GBEA_TXER        ( gmiiA_txer )
       , .GBEA_RXC         ( gmiiA_rxc  )
       , .GBEA_RXD         ( gmiiA_rxd  )
       , .GBEA_RXDV        ( gmiiA_rxdv )
       , .GBEA_RXER        ( gmiiA_rxer )

       , .GBEB_PHY_RESET_N (            )
       , .GBEB_GTXC        ( gmiiB_gtxc )
       , .GBEB_TXD         ( gmiiB_txd  )
       , .GBEB_TXEN        ( gmiiB_txen )
       , .GBEB_TXER        ( gmiiB_txer )
       , .GBEB_RXC         ( gmiiB_rxc  )
       , .GBEB_RXD         ( gmiiB_rxd  )
       , .GBEB_RXDV        ( gmiiB_rxdv )
       , .GBEB_RXER        ( gmiiB_rxer )

`ifdef BOARD_ZED
       `ifdef HSR_PERFORMANCE
       , .host_probe_txen (  )// JA1   (Y11 )
       , .host_probe_rxdv (  )// JA2   (AA11)
       , .netA_probe_txen (  )// JA7   (AB11)
       , .netA_probe_rxdv (  )// JA8   (AB10)
       , .netB_probe_txen (  )// JA9   (AB9 )
       , .netB_probe_rxdv (  )// JA10  (AA8 )
       `endif
`endif
   );
   //---------------------------------------------------------------------------
   wire done;
   //---------------------------------------------------------------------------
       tester    #(.NUM_OF_HSR_NODE(NUM_OF_HSR_NODE)
                  ,.HSR_ID       (HSR_ID       )
                  ,.HSR_ENABLE   (HSR_ID==0    )
                  ,.AXI_MST_ID   (0            )// Master ID
                  ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
                  ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
                  ,.ADDR_START_MEM_TX(32'h4100_0000)
                  ,.ADDR_START_MEM_RX(32'h4200_0000)
                  ,.ADDR_START_GMAC  (32'h4300_0000)
                  )
       u_test (
             .ARESETn            ( s_axi_aresetn        )
           , .ACLK               ( s_axi_aclk           )
           , .AWADDR             ( s_axi_awaddr         )
           , .AWLEN              ( s_axi_awlen          )
           , .AWLOCK             ( s_axi_awlock         )
           , .AWSIZE             ( s_axi_awsize         )
           , .AWBURST            ( s_axi_awburst        )
           `ifdef AMBA_AXI_CACHE
           , .AWCACHE            ( s_axi_awcache        )
           `endif
           `ifdef AMBA_AXI_PROT
           , .AWPROT             ( s_axi_awprot         )
           `endif
           , .AWVALID            ( s_axi_awvalid        )
           , .AWREADY            ( s_axi_awready        )
           , .WDATA              ( s_axi_wdata          )
           , .WSTRB              ( s_axi_wstrb          )
           , .WLAST              ( s_axi_wlast          )
           , .WVALID             ( s_axi_wvalid         )
           , .WREADY             ( s_axi_wready         )
           , .BRESP              ( s_axi_bresp          )
           , .BVALID             ( s_axi_bvalid         )
           , .BREADY             ( s_axi_bready         )
           , .ARADDR             ( s_axi_araddr         )
           , .ARLEN              ( s_axi_arlen          )
           , .ARLOCK             ( s_axi_arlock         )
           , .ARSIZE             ( s_axi_arsize         )
           , .ARBURST            ( s_axi_arburst        )
           `ifdef AMBA_AXI_CACHE
           , .ARCACHE            ( s_axi_arcache        )
           `endif
           `ifdef AMBA_AXI_PROT
           , .ARPROT             ( s_axi_arprot         )
           `endif
           , .ARVALID            ( s_axi_arvalid        )
           , .ARREADY            ( s_axi_arready        )
           , .RDATA              ( s_axi_rdata          )
           , .RRESP              ( s_axi_rresp          )
           , .RLAST              ( s_axi_rlast          )
           , .RVALID             ( s_axi_rvalid         )
           , .RREADY             ( s_axi_rready         )
           , .mac_addr           ( mac_addr             )
           , .done               ( done                 )
       );
   //---------------------------------------------------------------------------
   initial begin
        RESET_N = 1'b0;
        repeat (13) @ (posedge s_axi_aclk);
        RESET_N = 1'b1;
        repeat (10) @ (posedge s_axi_aclk);
        //-------------------------------------
   end
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.25: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
