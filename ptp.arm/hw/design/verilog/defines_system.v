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
`ifdef SIM
`include "sim_define.v"
`elsif SYN
`include "syn_define.v"
`else
`error SIM or SYN should be defined, but not.
`endif

//------------------------------------------------------------------------------
`ifndef IRQ_GMAC
`define IRQ_GMAC 0
`endif
`ifndef IRQ_PTP 
`define IRQ_PTP  1
`endif
`ifndef IRQ_RTC 
`define IRQ_RTC  2
`endif
`ifndef IRQ_SWD
`define IRQ_SWU 3
`endif
`ifndef IRQ_SWD
`define IRQ_SWD 4
`endif
`ifndef IRQ_GPIO
`define IRQ_GPIO 5
`endif

//------------------------------------------------------------------------------
`ifndef SIZE_BRAM_MEM
`define SIZE_BRAM_MEM (16*1024)
`endif
`ifndef SIZE_BRAM_TX
`define SIZE_BRAM_TX (16*1024)
`endif
`ifndef SIZE_BRAM_RX
`define SIZE_BRAM_RX (16*1024)
`endif

//------------------------------------------------------------------------------
`ifndef ADDR_START_MEM
`define ADDR_START_MEM       32'h4000_0000
`endif
`ifndef ADDR_START_MEM_TX
`define ADDR_START_MEM_TX    32'h4100_0000
`endif
`ifndef ADDR_START_MEM_RX
`define ADDR_START_MEM_RX    32'h4200_0000
`endif
`ifndef ADDR_START_GMAC
`define ADDR_START_GMAC      32'h4300_0000
`endif
`ifndef ADDR_START_APB
`define ADDR_START_APB       32'h4C00_0000
`endif
`ifndef ADDR_START_MDIO
`define ADDR_START_MDIO      (`ADDR_START_APB+32'h0000_0000)
`endif
`ifndef ADDR_START_HSR
`define ADDR_START_HSR       (`ADDR_START_APB+32'h0001_0000)
`endif
`ifndef ADDR_START_GPIO
`define ADDR_START_GPIO      (`ADDR_START_APB+32'h0002_0000)
`endif
`ifndef ADDR_START_TIMER
`define ADDR_START_TIMER     (`ADDR_START_APB+32'h0003_0000)
`endif
`ifndef ADDR_START_PTP 
`define ADDR_START_PTP       (`ADDR_START_APB+32'h0004_0000)
`endif

//------------------------------------------------------------------------------
// Async-FIFO depth between DMA and MAC_CORE
`ifndef TX_FIFO_DEPTH
`define TX_FIFO_DEPTH   (128)
`endif
`ifndef RX_FIFO_DEPTH
`define RX_FIFO_DEPTH   (128)
`endif

//------------------------------------------------------------------------------
// Sync-FIFO depth between int CSR, which connects to DMA
`ifndef TX_DESCRIPTOR_FAW
`define TX_DESCRIPTOR_FAW   (4)
`endif
`ifndef RX_DESCRIPTOR_FAW
`define RX_DESCRIPTOR_FAW   (4)
`endif

//------------------------------------------------------------------------------
// Async-FIFO depth between int MAC_CORE-RX, which connects to DMA-RX
`ifndef RX_FIFO_BNUM_FAW
`define RX_FIFO_BNUM_FAW    (4)
`endif

//------------------------------------------------------------------------------
`ifndef TXCLK_INV
`ifdef  RGMII
`define TXCLK_INV   1'b1
`else
`define TXCLK_INV   1'b0
`endif
`endif

//------------------------------------------------------------------------------
`ifndef AMBA_AXI4
`define AMBA_AXI4
`endif
`ifndef AMBA_AXI_CACHE
`define AMBA_AXI_CACHE
`endif
`ifndef AMBA_AXI_PROT
`define AMBA_AXI_PROT
`endif

//------------------------------------------------------------------------------
`ifndef FPGA_FAMILY
`define FPGA_FAMILY "ZYNQ7000"
`define XILINIX_Z7
`endif

`ifndef NUM_ENTRIES_PROXY
`define NUM_ENTRIES_PROXY 16 // should be power of 2
`endif
`ifndef NUM_ENTRIES_QR
`define NUM_ENTRIES_QR    16 // should be power of 2
`endif

`ifndef DANH_OR_REDBOX
`define DANH_OR_REDBOX   "PTP"
`endif

`ifndef CONF_MAC_ADDR
`define CONF_MAC_ADDR 48'h02_01_23_45_67_00
// make locally-managed HW MAC ADDR.
// lower 8-bit will be determined by SLIDE SWITCH if any.
`endif

// define this to gathering performance statistics
`undef  HSR_PERFORMANCE

//------------------------------------------------------------------------------
// Revision history:
//
// 2018.02.05: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
