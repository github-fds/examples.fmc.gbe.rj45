`ifndef DEFINES_SYSTEM_V
`define DEFINES_SYSTEM_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// defines_system.v
//------------------------------------------------------------------------------
// VERSION: 2018.02.05.
//------------------------------------------------------------------------------
`ifndef TXCLK_INV
  `ifdef  RGMII
    `define TXCLK_INV   1'b1
  `else
    `define TXCLK_INV   1'b0
  `endif
`endif

`ifndef TXCLK_INV
`define TXCLK_INV 1'b0
`endif

`ifndef NUM_ENTRIES_PROXY
`define NUM_ENTRIES_PROXY 16 // should be power of 2
`endif
`ifndef NUM_ENTRIES_QR
`define NUM_ENTRIES_QR    16 // should be power of 2
`endif

`ifndef DANH_OR_REDBOX
`define DANH_OR_REDBOX   "REDBOX"
`endif

`ifndef HSR_PERFORMANCE
`define HSR_PERFORMANCE
`endif

//------------------------------------------------------------------------------
`ifdef SIM
`include "sim_define.v"
`elsif SYN
`include "syn_define.v"
`endif

//------------------------------------------------------------------------------
// Revision history:
//
// 2018.02.05: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
