// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Tue May 14 21:32:37 2019
// Host        : AndoUbuntu running 64-bit Ubuntu 16.04.6 LTS
// Command     : write_verilog -force -mode synth_stub mdio_apb_stub.v
// Design      : mdio_apb
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module mdio_apb(PRESETn, PCLK, PSEL, PENABLE, PADDR, PWRITE, PWDATA, 
  PRDATA, IRQ, MDC, MDIO_I, MDIO_O, MDIO_T)
/* synthesis syn_black_box black_box_pad_pin="PRESETn,PCLK,PSEL,PENABLE,PADDR[31:0],PWRITE,PWDATA[31:0],PRDATA[31:0],IRQ,MDC,MDIO_I,MDIO_O,MDIO_T" */;
  input PRESETn;
  input PCLK;
  input PSEL;
  input PENABLE;
  input [31:0]PADDR;
  input PWRITE;
  input [31:0]PWDATA;
  output [31:0]PRDATA;
  output IRQ;
  output MDC;
  input MDIO_I;
  output MDIO_O;
  output MDIO_T;
endmodule
