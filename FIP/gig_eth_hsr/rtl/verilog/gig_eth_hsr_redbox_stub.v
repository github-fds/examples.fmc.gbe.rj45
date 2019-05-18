// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Fri May 17 16:24:02 2019
// Host        : AndoUbuntu running 64-bit Ubuntu 16.04.6 LTS
// Command     : write_verilog -force -mode synth_stub gig_eth_hsr_redbox_stub.v
// Design      : gig_eth_hsr_redbox
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module gig_eth_hsr_redbox(reset_n, gtx_clk, board_id, hsr_ready, 
  phy_resetU_n, phy_resetA_n, phy_resetB_n, phy_readyU, phy_readyA, phy_readyB, gmiiU_gtxc, 
  gmiiU_txd, gmiiU_txen, gmiiU_txer, gmiiU_rxc, gmiiU_rxd, gmiiU_rxdv, gmiiU_rxer, gmiiU_col, 
  gmiiU_crs, gmiiA_gtxc, gmiiA_txd, gmiiA_txen, gmiiA_txer, gmiiA_rxc, gmiiA_rxd, gmiiA_rxdv, 
  gmiiA_rxer, gmiiA_col, gmiiA_crs, gmiiB_gtxc, gmiiB_txd, gmiiB_txen, gmiiB_txer, gmiiB_rxc, 
  gmiiB_rxd, gmiiB_rxdv, gmiiB_rxer, gmiiB_col, gmiiB_crs, PRESETn, PCLK, PSEL, PENABLE, PADDR, PWRITE, 
  PWDATA, PRDATA, host_probe_txen, host_probe_rxdv, netA_probe_txen, netA_probe_rxdv, 
  netB_probe_txen, netB_probe_rxdv)
/* synthesis syn_black_box black_box_pad_pin="reset_n,gtx_clk,board_id[7:0],hsr_ready,phy_resetU_n,phy_resetA_n,phy_resetB_n,phy_readyU,phy_readyA,phy_readyB,gmiiU_gtxc,gmiiU_txd[7:0],gmiiU_txen,gmiiU_txer,gmiiU_rxc,gmiiU_rxd[7:0],gmiiU_rxdv,gmiiU_rxer,gmiiU_col,gmiiU_crs,gmiiA_gtxc,gmiiA_txd[7:0],gmiiA_txen,gmiiA_txer,gmiiA_rxc,gmiiA_rxd[7:0],gmiiA_rxdv,gmiiA_rxer,gmiiA_col,gmiiA_crs,gmiiB_gtxc,gmiiB_txd[7:0],gmiiB_txen,gmiiB_txer,gmiiB_rxc,gmiiB_rxd[7:0],gmiiB_rxdv,gmiiB_rxer,gmiiB_col,gmiiB_crs,PRESETn,PCLK,PSEL,PENABLE,PADDR[31:0],PWRITE,PWDATA[31:0],PRDATA[31:0],host_probe_txen,host_probe_rxdv,netA_probe_txen,netA_probe_rxdv,netB_probe_txen,netB_probe_rxdv" */;
  input reset_n;
  input gtx_clk;
  input [7:0]board_id;
  output hsr_ready;
  output phy_resetU_n;
  output phy_resetA_n;
  output phy_resetB_n;
  output phy_readyU;
  output phy_readyA;
  output phy_readyB;
  output gmiiU_gtxc;
  output [7:0]gmiiU_txd;
  output gmiiU_txen;
  output gmiiU_txer;
  input gmiiU_rxc;
  input [7:0]gmiiU_rxd;
  input gmiiU_rxdv;
  input gmiiU_rxer;
  input gmiiU_col;
  input gmiiU_crs;
  output gmiiA_gtxc;
  output [7:0]gmiiA_txd;
  output gmiiA_txen;
  output gmiiA_txer;
  input gmiiA_rxc;
  input [7:0]gmiiA_rxd;
  input gmiiA_rxdv;
  input gmiiA_rxer;
  input gmiiA_col;
  input gmiiA_crs;
  output gmiiB_gtxc;
  output [7:0]gmiiB_txd;
  output gmiiB_txen;
  output gmiiB_txer;
  input gmiiB_rxc;
  input [7:0]gmiiB_rxd;
  input gmiiB_rxdv;
  input gmiiB_rxer;
  input gmiiB_col;
  input gmiiB_crs;
  input PRESETn;
  input PCLK;
  input PSEL;
  input PENABLE;
  input [31:0]PADDR;
  input PWRITE;
  input [31:0]PWDATA;
  output [31:0]PRDATA;
  output host_probe_txen;
  output host_probe_rxdv;
  output netA_probe_txen;
  output netA_probe_rxdv;
  output netB_probe_txen;
  output netB_probe_rxdv;
endmodule
