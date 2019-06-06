// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Jun  3 13:31:34 2019
// Host        : AndoUbuntu running 64-bit Ubuntu 16.04.6 LTS
// Command     : write_verilog -force -mode synth_stub gig_eth_ptpv2_lite_apb_stub.v
// Design      : gig_eth_ptpv2_lite_apb
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module gig_eth_ptpv2_lite_apb(PRESETn, PCLK, PSEL, PENABLE, PADDR, PWRITE, PWDATA, 
  PRDATA, IRQ_PTP, IRQ_RTC, gmii_rx_clk, gmii_rxd, gmii_rxdv, gmii_rxer, gmii_tx_clk, gmii_txd, 
  gmii_txen, gmii_txer, rtc_clk, ptpv2_master, ptp_pps, ptp_ppms, ptp_pp100us, ptp_ppus)
/* synthesis syn_black_box black_box_pad_pin="PRESETn,PCLK,PSEL,PENABLE,PADDR[31:0],PWRITE,PWDATA[31:0],PRDATA[31:0],IRQ_PTP,IRQ_RTC,gmii_rx_clk,gmii_rxd[7:0],gmii_rxdv,gmii_rxer,gmii_tx_clk,gmii_txd[7:0],gmii_txen,gmii_txer,rtc_clk,ptpv2_master,ptp_pps,ptp_ppms,ptp_pp100us,ptp_ppus" */;
  input PRESETn;
  input PCLK;
  input PSEL;
  input PENABLE;
  input [31:0]PADDR;
  input PWRITE;
  input [31:0]PWDATA;
  output [31:0]PRDATA;
  output IRQ_PTP;
  output IRQ_RTC;
  input gmii_rx_clk;
  input [7:0]gmii_rxd;
  input gmii_rxdv;
  input gmii_rxer;
  input gmii_tx_clk;
  input [7:0]gmii_txd;
  input gmii_txen;
  input gmii_txer;
  input rtc_clk;
  output ptpv2_master;
  output ptp_pps;
  output ptp_ppms;
  output ptp_pp100us;
  output ptp_ppus;
endmodule
