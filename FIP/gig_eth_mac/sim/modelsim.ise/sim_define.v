//------------------------------------------------------------------------------
`define DEBUG_GMII_TX
`define DEBUG_GMII_RX
`define RIGOR
`define VCD
`define DEBUG_PORT

`define ISE
`define FPGA_FAMILY         "VIRTEX6"
`define AMBA_AXI4
`undef  RGMII
`ifdef RGMII
`define TXCLK_INV 0
`endif

//------------------------------------------------------------------------------
`define ADDR_START_MEM_TX   32'h0000_0000
`define ADDR_START_MEM_RX   32'h1000_0000
`define ADDR_START_GMAC     32'hC000_0000

`define P_SIZE      (16*1024)
`define ADDR_LENGTH (14)

`define P_TX_FIFO_DEPTH (128)
`define P_RX_FIFO_DEPTH (128)

`define TX_DESCRIPTOR_FAW   4
`define RX_DESCRIPTOR_FAW   4

//------------------------------------------------------------------------------
`define  TEST_MEM                               0
`define  TEST_MAC_CSR                           0
`define  TEST_MAC_TX_SHORT_PAD                  1
`define  TEST_MAC_TX_NORMAL                     0
`define  TEST_MAC_TX_LONG                       0
`define  TEST_MAC_TX_NORMAL_RANDOM              0
`define  TEST_MAC_RX_CRC_ERROR                  0
`define  TEST_MAC_RX_CRC_ERROR_LONG             0
`define  TEST_MAC_TX_LONG_DROP                  0
`define  TEST_MAC_TX_LONG_DROP_LONG             0
`define  TEST_MAC_TX_SHORT_PAD_MANY_DROP_AT_RX  0

//------------------------------------------------------------------------------
`define TEST_MAC_RX

//------------------------------------------------------------------------------
// Not implemented yet.
`define TEST_MAC_TX_NO_CRC       0
`define TEST_MAC_TX_JUMBO        0
`define TEST_MAC_TX_JUMBO_DROP   0
`define TEST_MAC_TX_JUMBO_NO_CRC 0
//------------------------------------------------------------------------------
