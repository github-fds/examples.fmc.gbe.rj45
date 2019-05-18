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
`include "tester_gmii.v"
`timescale 1ns/1ps

module hsr_node
     #(parameter NUM_OF_HSR_NODE=2
               , HSR_ID=0
               , TX_ENABLE=0
               , MAC_ADDR=48'hF0_12_34_56_78_00
               , FPGA_FAMILY="VIRTEX6"
               , TXCLK_INV  =1'b0
               , DANH_OR_REDBOX="REDBOX")
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
   wire          tx_reset=~RESET_N;
   wire          rx_reset=~RESET_N;
   wire          gmiiU_gtxc;
   wire  [7:0]   gmiiU_txd ;
   wire          gmiiU_txen;
   wire          gmiiU_txer;
   wire          gmiiU_rxc ;
   wire  [7:0]   gmiiU_rxd ;
   wire          gmiiU_rxdv;
   wire          gmiiU_rxer;
   wire          gmiiU_col=1'b0;
   wire          gmiiU_crs=1'b0;
   wire          gmiiU_mdio; pullup Uu(gmiiU_mdio);
   wire          gmiiA_mdio; pullup Ua(gmiiA_mdio);
   wire          gmiiB_mdio; pullup Ub(gmiiB_mdio);
   //---------------------------------------------------------------------------
   fpga #(.FPGA_FAMILY(FPGA_FAMILY)
         ,.TXCLK_INV(TXCLK_INV))
   u_fpga (
`ifdef BOARD_ML605
         .CLK200_P         ( CLK200_P   )
       , .CLK200_N         ( CLK200_N   )
       , .BOARD_RST_SW     ( 1'b0       )
       , .GBEA_PHY_RESET_N (            )
       , .GBEB_PHY_RESET_N (            )
       , .GBEU_PHY_RESET_N (            )
`elsif BOARD_ZED
         .CLK100           ( CLK100     )
       , .BOARD_RST_SW     ( 1'b0       )
       , .BOARD_SLIDE_SW   ( HSR_ID[7:0])
       , .BOARD_LED        (            )
       , .GBEA_PHY_RESET_N (            )
       , .GBEB_PHY_RESET_N (            )
       , .GBEU_PHY_RESET_N (            )
`elsif BOARD_VC
         .CLK125           ( CLK125     )
       , .GBEA_PHY_RESET_N (            )
       , .GBEB_PHY_RESET_N (            )
       , .GBEU_PHY_RESET_N (            )
`endif
       , .GBE_MDC          (            )
       , .GBE_MDIO         ( gmiiA_mdio )

       , .GBEA_GTXC        ( gmiiA_gtxc )
       , .GBEA_TXD         ( gmiiA_txd  )
       , .GBEA_TXEN        ( gmiiA_txen )
       , .GBEA_TXER        ( gmiiA_txer )
       , .GBEA_RXC         ( gmiiA_rxc  )
       , .GBEA_RXD         ( gmiiA_rxd  )
       , .GBEA_RXDV        ( gmiiA_rxdv )
       , .GBEA_RXER        ( gmiiA_rxer )
`ifdef BOARD_ML605
       , .GBEA_COL         ( 1'b0       )
       , .GBEA_CRS         ( 1'b0       )
`endif

       , .GBEB_GTXC        ( gmiiB_gtxc )
       , .GBEB_TXD         ( gmiiB_txd  )
       , .GBEB_TXEN        ( gmiiB_txen )
       , .GBEB_TXER        ( gmiiB_txer )
       , .GBEB_RXC         ( gmiiB_rxc  )
       , .GBEB_RXD         ( gmiiB_rxd  )
       , .GBEB_RXDV        ( gmiiB_rxdv )
       , .GBEB_RXER        ( gmiiB_rxer )
`ifdef BOARD_ML605
       , .GBEB_COL         ( 1'b0       )
       , .GBEB_CRS         ( 1'b0       )
`endif

       , .GBEU_GTXC        ( gmiiU_gtxc )
       , .GBEU_TXD         ( gmiiU_txd  )
       , .GBEU_TXEN        ( gmiiU_txen )
       , .GBEU_TXER        ( gmiiU_txer )
       , .GBEU_RXC         ( gmiiU_rxc  )
       , .GBEU_RXD         ( gmiiU_rxd  )
       , .GBEU_RXDV        ( gmiiU_rxdv )
       , .GBEU_RXER        ( gmiiU_rxer )
`ifdef BOARD_ML605
       , .GBEU_COL         ( 1'b0       )
       , .GBEU_CRS         ( 1'b0       )
`endif

`ifdef BOARD_ZED
    `ifdef HSR_PERFORMANCE
      , .host_probe_txen (  )
      , .host_probe_rxdv (  )
      , .netA_probe_txen (  )
      , .netA_probe_rxdv (  )
      , .netB_probe_txen (  )
      , .netB_probe_rxdv (  )
     `endif
`endif
   );
   //---------------------------------------------------------------------------
   wire done;
   //---------------------------------------------------------------------------
   tester_gmii #(.NUM_OF_HSR_NODE(NUM_OF_HSR_NODE)
                 ,.HSR_ID(HSR_ID)
                 ,.TX_ENABLE(TX_ENABLE))
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
     , .mac_addr  ( mac_addr   )
     , .done      ( done       )
   );
   //---------------------------------------------------------------------------
   initial begin
        RESET_N = 1'b0;
        repeat (13) @ (posedge gmiiU_gtxc);
        RESET_N = 1'b1;
        repeat (10) @ (posedge gmiiU_gtxc);
        //-------------------------------------
   end
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.25: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
