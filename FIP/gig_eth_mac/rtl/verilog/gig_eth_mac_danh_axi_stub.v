// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Fri May 17 13:38:07 2019
// Host        : AndoUbuntu running 64-bit Ubuntu 16.04.6 LTS
// Command     : write_verilog -force -mode synth_stub gig_eth_mac_danh_axi_stub.v
// Design      : gig_eth_mac_danh_axi
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module gig_eth_mac_danh_axi(ARESETn, ACLK, M_MID, M_AWID, M_AWADDR, M_AWLEN, 
  M_AWLOCK, M_AWSIZE, M_AWBURST, M_AWCACHE, M_AWPROT, M_AWVALID, M_AWREADY, M_AWQOS, M_AWREGION, 
  M_WID, M_WDATA, M_WSTRB, M_WLAST, M_WVALID, M_WREADY, M_BID, M_BRESP, M_BVALID, M_BREADY, M_ARID, 
  M_ARADDR, M_ARLEN, M_ARLOCK, M_ARSIZE, M_ARBURST, M_ARCACHE, M_ARPROT, M_ARVALID, M_ARREADY, 
  M_ARQOS, M_ARREGION, M_RID, M_RDATA, M_RRESP, M_RLAST, M_RVALID, M_RREADY, S_AWID, S_AWADDR, S_AWLEN, 
  S_AWLOCK, S_AWSIZE, S_AWBURST, S_AWCACHE, S_AWPROT, S_AWVALID, S_AWREADY, S_AWQOS, S_AWREGION, 
  S_WID, S_WDATA, S_WSTRB, S_WLAST, S_WVALID, S_WREADY, S_BID, S_BRESP, S_BVALID, S_BREADY, S_ARID, 
  S_ARADDR, S_ARLEN, S_ARLOCK, S_ARSIZE, S_ARBURST, S_ARCACHE, S_ARPROT, S_ARVALID, S_ARREADY, 
  S_ARQOS, S_ARREGION, S_RID, S_RDATA, S_RRESP, S_RLAST, S_RVALID, S_RREADY, IRQ, gmii_gtxc, gmii_txd, 
  gmii_txen, gmii_txer, gmii_rxc, gmii_rxd, gmii_rxdv, gmii_rxer, gmii_col, gmii_crs, gtx_clk, 
  gtx_clk_stable, gbe_phy_reset_n)
/* synthesis syn_black_box black_box_pad_pin="ARESETn,ACLK,M_MID[3:0],M_AWID[3:0],M_AWADDR[31:0],M_AWLEN[7:0],M_AWLOCK,M_AWSIZE[2:0],M_AWBURST[1:0],M_AWCACHE[3:0],M_AWPROT[2:0],M_AWVALID,M_AWREADY,M_AWQOS[3:0],M_AWREGION[3:0],M_WID[3:0],M_WDATA[31:0],M_WSTRB[3:0],M_WLAST,M_WVALID,M_WREADY,M_BID[3:0],M_BRESP[1:0],M_BVALID,M_BREADY,M_ARID[3:0],M_ARADDR[31:0],M_ARLEN[7:0],M_ARLOCK,M_ARSIZE[2:0],M_ARBURST[1:0],M_ARCACHE[3:0],M_ARPROT[2:0],M_ARVALID,M_ARREADY,M_ARQOS[3:0],M_ARREGION[3:0],M_RID[3:0],M_RDATA[31:0],M_RRESP[1:0],M_RLAST,M_RVALID,M_RREADY,S_AWID[7:0],S_AWADDR[31:0],S_AWLEN[7:0],S_AWLOCK,S_AWSIZE[2:0],S_AWBURST[1:0],S_AWCACHE[3:0],S_AWPROT[2:0],S_AWVALID,S_AWREADY,S_AWQOS[3:0],S_AWREGION[3:0],S_WID[7:0],S_WDATA[31:0],S_WSTRB[3:0],S_WLAST,S_WVALID,S_WREADY,S_BID[7:0],S_BRESP[1:0],S_BVALID,S_BREADY,S_ARID[7:0],S_ARADDR[31:0],S_ARLEN[7:0],S_ARLOCK,S_ARSIZE[2:0],S_ARBURST[1:0],S_ARCACHE[3:0],S_ARPROT[2:0],S_ARVALID,S_ARREADY,S_ARQOS[3:0],S_ARREGION[3:0],S_RID[7:0],S_RDATA[31:0],S_RRESP[1:0],S_RLAST,S_RVALID,S_RREADY,IRQ,gmii_gtxc,gmii_txd[7:0],gmii_txen,gmii_txer,gmii_rxc,gmii_rxd[7:0],gmii_rxdv,gmii_rxer,gmii_col,gmii_crs,gtx_clk,gtx_clk_stable,gbe_phy_reset_n" */;
  input ARESETn;
  input ACLK;
  output [3:0]M_MID;
  output [3:0]M_AWID;
  output [31:0]M_AWADDR;
  output [7:0]M_AWLEN;
  output M_AWLOCK;
  output [2:0]M_AWSIZE;
  output [1:0]M_AWBURST;
  output [3:0]M_AWCACHE;
  output [2:0]M_AWPROT;
  output M_AWVALID;
  input M_AWREADY;
  output [3:0]M_AWQOS;
  output [3:0]M_AWREGION;
  output [3:0]M_WID;
  output [31:0]M_WDATA;
  output [3:0]M_WSTRB;
  output M_WLAST;
  output M_WVALID;
  input M_WREADY;
  input [3:0]M_BID;
  input [1:0]M_BRESP;
  input M_BVALID;
  output M_BREADY;
  output [3:0]M_ARID;
  output [31:0]M_ARADDR;
  output [7:0]M_ARLEN;
  output M_ARLOCK;
  output [2:0]M_ARSIZE;
  output [1:0]M_ARBURST;
  output [3:0]M_ARCACHE;
  output [2:0]M_ARPROT;
  output M_ARVALID;
  input M_ARREADY;
  output [3:0]M_ARQOS;
  output [3:0]M_ARREGION;
  input [3:0]M_RID;
  input [31:0]M_RDATA;
  input [1:0]M_RRESP;
  input M_RLAST;
  input M_RVALID;
  output M_RREADY;
  input [7:0]S_AWID;
  input [31:0]S_AWADDR;
  input [7:0]S_AWLEN;
  input S_AWLOCK;
  input [2:0]S_AWSIZE;
  input [1:0]S_AWBURST;
  input [3:0]S_AWCACHE;
  input [2:0]S_AWPROT;
  input S_AWVALID;
  output S_AWREADY;
  input [3:0]S_AWQOS;
  input [3:0]S_AWREGION;
  input [7:0]S_WID;
  input [31:0]S_WDATA;
  input [3:0]S_WSTRB;
  input S_WLAST;
  input S_WVALID;
  output S_WREADY;
  output [7:0]S_BID;
  output [1:0]S_BRESP;
  output S_BVALID;
  input S_BREADY;
  input [7:0]S_ARID;
  input [31:0]S_ARADDR;
  input [7:0]S_ARLEN;
  input S_ARLOCK;
  input [2:0]S_ARSIZE;
  input [1:0]S_ARBURST;
  input [3:0]S_ARCACHE;
  input [2:0]S_ARPROT;
  input S_ARVALID;
  output S_ARREADY;
  input [3:0]S_ARQOS;
  input [3:0]S_ARREGION;
  output [7:0]S_RID;
  output [31:0]S_RDATA;
  output [1:0]S_RRESP;
  output S_RLAST;
  output S_RVALID;
  input S_RREADY;
  output IRQ;
  output gmii_gtxc;
  output [7:0]gmii_txd;
  output gmii_txen;
  output gmii_txer;
  input gmii_rxc;
  input [7:0]gmii_rxd;
  input gmii_rxdv;
  input gmii_rxer;
  input gmii_col;
  input gmii_crs;
  input gtx_clk;
  input gtx_clk_stable;
  output gbe_phy_reset_n;
endmodule
