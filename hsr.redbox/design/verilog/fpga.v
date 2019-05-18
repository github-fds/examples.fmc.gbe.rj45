//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fpga.v
//------------------------------------------------------------------------------
// VERSION: 2018.08.15.
//------------------------------------------------------------------------------
`include "defines_system.v"

`ifdef    BOARD_SMC
`include "fpga_smc.v"
`elsif    BOARD_VC
`include "fpga_vc.v"
`elsif    BOARD_UCB
`include "fpga_ucb.v"
`elsif    BOARD_ML605
`include "fpga_ml605.v"
`elsif    BOARD_ZED
`include "fpga_zed.v"
`define   XILINX_Z7
`else
`endif
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.08.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
