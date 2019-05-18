`ifndef SIM_DEFINE_V
`define SIM_DEFINE_V
//-----------------------------------------------------------------------
// Copyright (c) 2018 by Ando Ki
// All rights reserved.
//
// This program is distributed in the hope that it
// will be useful to understand Ando Ki's work,
// BUT WITHOUT ANY WARRANTY.
//-----------------------------------------------------------------------
`define SIM      // define this for simulation case if you are not sure
`undef  SYN      // undefine this for simulation case
`define VCD      // define this for VCD waveform dump
`undef  DEBUG
`define RIGOR
//-----------------------------------------------------------------------
// define board type
`undef  BOARD_SP605
`undef  BOARD_ML605
`undef  BOARD_VCU108
`undef  BOARD_ZCU102
`undef  BOARD_ZC706
`undef  BOARD_ZC702
`define BOARD_ZED

`ifdef  BOARD_ML605
`define FPGA_FAMILY     "VIRTEX6"
`define ISE
`elsif  BOARD_SP605
`define FPGA_FAMILY     "SPARTAN6"
`define ISE
`elsif  BOARD_VCU108
`define FPGA_FAMILY     "VirtexUS"
`define VIVADO
`elsif  BOARD_ZCU102
`define FPGA_FAMILY     "ZynqUSP"
`define VIVADO
`elsif  BOARD_ZC706
`define FPGA_FAMILY     "ZYNQ7000"
`define XILINX_Z7
`define VIVADO
`elsif  BOARD_ZC702
`define FPGA_FAMILY     "ZYNQ7000"
`define XILINX_Z7
`define VIVADO
`elsif  BOARD_ZED
`define FPGA_FAMILY     "ZYNQ7000"
`define XILINX_Z7
`define VIVADO
`else
`define FPGA_FAMILY     "ARTIX7"
`define ISE
`endif

//-----------------------------------------------------------------------
`define HSR_PERFORMANCE

//-----------------------------------------------------------------------
`define GMII_PHY_RESET

//-----------------------------------------------------------------------
`define NUM_OF_HSR_NODE 3

//-----------------------------------------------------------------------
// Test case sel
`define TEST_MEM                         0
`define TEST_MAC_CSR                     0
`define TEST_HSR_CSR                     0
`define TEST_MAC_TX_SHORT_PAD_SINGLE     1
`define TEST_MAC_TX_SHORT_PAD            0
`define TEST_MAC_TX_NORMAL               0
`define TEST_MAC_TX_LONG                 0

//-----------------------------------------------------------------------
`endif
