//------------------------------------------------------------------------------
`define SIM
`define DEBUG_GMII_TX
`define DEBUG_GMII_RX
`define RIGOR
`define VCD

`define VIVADO
`define FPGA_FAMILY         "ZYNQ7000"
`define XILINX_Z7
//`define FPGA_FAMILY         "VirtexUS"
`undef  RGMII
`ifdef RGMII
`define TXCLK_INV 0
`endif

`define HSR_PERFORMANCE

//------------------------------------------------------------------------------
`define TEST_CSR 1

`define TEST_SHORT_SINGLE_PACKET   1
`define TEST_SHORT_PACKETS         1

`define TEST_MIDDLE_SINGLE_PACKET  1
`define TEST_MIDDLE_PACKETS        1

`define TEST_LONG_SINGLE_PACKET    1
`define TEST_LONG_PACKETS          1
//------------------------------------------------------------------------------
