//------------------------------------------------------------------------------
`define SIM
`define RIGOR
`define VCD
`define DEBUG_PORT

`define ISE
`define FPGA_FAMILY         "VIRTEX6"
`undef  RGMII
`ifdef RGMII
`define TXCLK_INV 0
`endif

`define HSR_PERFORMANCE

//------------------------------------------------------------------------------
`define TEST_CSR                   0

`define TEST_SHORT_SINGLE_PACKET   1
`define TEST_SHORT_PACKETS         0

`define TEST_MIDDLE_SINGLE_PACKET  0
`define TEST_MIDDLE_PACKETS        0

`define TEST_LONG_SINGLE_PACKET    0
`define TEST_LONG_PACKETS          0
//------------------------------------------------------------------------------
