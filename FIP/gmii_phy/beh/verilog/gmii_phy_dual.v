//--------------------------------------------------------
// Copyright (c) 2011 by Future Design Systems , Inc.
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// gmii_phy_dual.v
//--------------------------------------------------------
// VERSION = 2011.10.20.
//--------------------------------------------------------
`timescale 1ns/1ns
`include "gmii_phy.v"

//--------------------------------------------------------
module gmii_phy_dual #(parameter LOOPBACK=1'b0,
                                 MDIO_PHY_ADR0=5'h0,
                                 MDIO_PHY_ADR0=5'h1)
(
       input   wire         gmii0_tx_clk // it is gtx_clk
     , input   wire [ 7:0]  gmii0_txd
     , input   wire         gmii0_txen
     , input   wire         gmii0_txer
     , output  wire         gmii0_crs
     , output  wire         gmii0_col
     , output  wire         gmii0_rx_clk
     , output  wire [ 7:0]  gmii0_rxd
     , output  wire         gmii0_rxdv
     , output  wire         gmii0_rxer
     , input   wire         gmii1_tx_clk // it is gtx_clk
     , input   wire [ 7:0]  gmii1_txd
     , input   wire         gmii1_txen
     , input   wire         gmii1_txer
     , output  wire         gmii1_crs
     , output  wire         gmii1_col
     , output  wire         gmii1_rx_clk
     , output  wire [ 7:0]  gmii1_rxd
     , output  wire         gmii1_rxdv
     , output  wire         gmii1_rxer
     , input   wire         gmii_mdc
     , inout   wire         gmii_mdio
   `ifdef GMII_PHY_RESET
     , input   wire         gmii_phy_reset_n
   `endif
   `ifdef GMII_PHY_INT
     , output  wire         gmii_phy_int_n
   `endif
   `ifdef GMII_PHY_MODE
     , output  wire [ 3:0]  gmii_phy_mode
   `endif
);
     //---------------------------------------------------
   `ifdef GMII_PHY_INT
     wire         gmii0_phy_int_n;
     wire         gmii1_phy_int_n;
     assign gmii_phy_int_n = gmii0_phy_int_n & gmii1_phy_int_n;
   `endif
   `ifdef GMII_PHY_MODE
     wire [ 3:0]  gmii0_phy_mode;
     wire [ 3:0]  gmii1_phy_mode;
     assign gmii_phy_mode = gmii0_phy_mode;
   `endif
     //---------------------------------------------------
     gmii_phy #(.LOOPBACK(LOOPBACK),.MDIO_PHY_ADR(MDIO_PHY_ADR0))
     Ugmii_phy0 (
       .gmii_tx_clk      (gmii0_tx_clk)
     , .gmii_txd         (gmii0_txd   )
     , .gmii_txen        (gmii0_txen  )
     , .gmii_txer        (gmii0_txer  )
     , .gmii_crs         (gmii0_crs   )
     , .gmii_col         (gmii0_col   )
     , .gmii_rx_clk      (gmii0_rx_clk)
     , .gmii_rxd         (gmii0_rxd   )
     , .gmii_rxdv        (gmii0_rxdv  )
     , .gmii_rxer        (gmii0_rxer  )
     , .gmii_mdc         (gmii_mdc    )
     , .gmii_mdio        (gmii_mdio   )
   `ifdef GMII_PHY_RESET
     , .gmii_phy_reset_n (gmii_phy_reset_n)
   `endif
   `ifdef GMII_PHY_INT
     , .gmii_phy_int_n   (gmii0_phy_int_n )
   `endif
   `ifdef GMII_PHY_MODE
     , .gmii_phy_mode    (gmii0_phy_mode  )
   `endif
     );
     //---------------------------------------------------
     gmii_phy #(.LOOPBACK(LOOPBACK),.MDIO_PHY_ADR(MDIO_PHY_ADR1))
     Ugmii_phy1 (
       .gmii_tx_clk      (gmii1_tx_clk)
     , .gmii_txd         (gmii1_txd   )
     , .gmii_txen        (gmii1_txen  )
     , .gmii_txer        (gmii1_txer  )
     , .gmii_crs         (gmii1_crs   )
     , .gmii_col         (gmii1_col   )
     , .gmii_rx_clk      (gmii1_rx_clk)
     , .gmii_rxd         (gmii1_rxd   )
     , .gmii_rxdv        (gmii1_rxdv  )
     , .gmii_rxer        (gmii1_rxer  )
     , .gmii_mdc         (gmii_mdc    )
     , .gmii_mdio        (gmii_mdio   )
   `ifdef GMII_PHY_RESET
     , .gmii_phy_reset_n (gmii_phy_reset_n)
   `endif
   `ifdef GMII_PHY_INT
     , .gmii_phy_int_n   (gmii1_phy_int_n )
   `endif
   `ifdef GMII_PHY_MODE
     , .gmii_phy_mode    (gmii1_phy_mode  )
   `endif
     );
     //---------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2011.10.21: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
