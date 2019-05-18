//----------------------------------------------------------------
//  Copyright (c) 2013-2015 by Ando Ki.
//  All right reserved.
//
//  andoki@gmail.com
//----------------------------------------------------------------
// tester_rx.v
//----------------------------------------------------------------
// VERSION: 2015.10.29.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4       - AMBA AXI4
//    AMBA_AXI_CACHE  -
//    AMBA_AXI_PROT   -
//----------------------------------------------------------------
`timescale 1ns/1ns

module tester_rx
    #(parameter AXI_MST_ID   =0         // Master ID
              , AXI_WIDTH_CID=4
              , AXI_WIDTH_ID =4         // ID width in bits
              , AXI_WIDTH_AD =32        // address width
              , AXI_WIDTH_DA =32        // data width
              , AXI_WIDTH_DS =(AXI_WIDTH_DA/8) // data strobe width
              , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
              , ADDR_START_MEM_TX=32'h0000_0000
              , ADDR_START_MEM_RX=32'h1000_0000
              , ADDR_START_GMAC  =32'h3000_0000
              )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     , output reg  [AXI_WIDTH_CID-1:0] MID=AXI_MST_ID
     //-----------------------------------------------------------
     , output reg  [AXI_WIDTH_ID-1:0]  AWID='h0
     , output reg  [AXI_WIDTH_AD-1:0]  AWADDR=~'h0
     `ifdef AMBA_AXI4
     , output reg  [ 7:0]              AWLEN='h0
     , output reg                      AWLOCK=1'b0
     `else
     , output reg  [ 3:0]              AWLEN='h0
     , output reg  [ 1:0]              AWLOCK='h0
     `endif
     , output reg  [ 2:0]              AWSIZE='h0
     , output reg  [ 1:0]              AWBURST='h0
     `ifdef AMBA_AXI_CACHE
     , output reg  [ 3:0]              AWCACHE='h0
     `endif
     `ifdef AMBA_AXI_PROT
     , output reg  [ 2:0]              AWPROT='h0
     `endif
     , output reg                      AWVALID=1'b0
     , input  wire                     AWREADY
     `ifdef AMBA_AXI4
     , output reg  [ 3:0]              AWQOS='h0
     , output reg  [ 3:0]              AWREGION='h0
     `endif
     //-----------------------------------------------------------
     , output reg  [AXI_WIDTH_ID-1:0]  WID='h0
     , output reg  [AXI_WIDTH_DA-1:0]  WDATA=~'h0
     , output reg  [AXI_WIDTH_DS-1:0]  WSTRB='h0
     , output reg                      WLAST=1'b0
     , output reg                      WVALID=1'b0
     , input  wire                     WREADY
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_ID-1:0]  BID
     , input  wire [ 1:0]              BRESP
     , input  wire                     BVALID
     , output reg                      BREADY=1'b0
     //-----------------------------------------------------------
     , output reg  [AXI_WIDTH_ID-1:0]  ARID='h0
     , output reg  [AXI_WIDTH_AD-1:0]  ARADDR=~'h0
     `ifdef AMBA_AXI4
     , output reg  [ 7:0]              ARLEN='h0
     , output reg                      ARLOCK=1'b0
     `else
     , output reg  [ 3:0]              ARLEN='h0
     , output reg  [ 1:0]              ARLOCK='h0
     `endif
     , output reg  [ 2:0]              ARSIZE='h0
     , output reg  [ 1:0]              ARBURST='h0
     `ifdef AMBA_AXI_CACHE
     , output reg  [ 3:0]              ARCACHE='h0
     `endif
     `ifdef AMBA_AXI_PROT
     , output reg  [ 2:0]              ARPROT='h0
     `endif
     , output reg                      ARVALID=1'b0
     , input  wire                     ARREADY
     `ifdef AMBA_AXI4
     , output reg  [ 3:0]              ARQOS='h0
     , output reg  [ 3:0]              ARREGION='h0
     `endif
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_ID-1:0]  RID
     , input  wire [AXI_WIDTH_DA-1:0]  RDATA
     , input  wire [ 1:0]              RRESP
     , input  wire                     RLAST
     , input  wire                     RVALID
     , output reg                      RREADY=1'b0
     //-----------------------------------------------------------
     , output reg                      done=1'b0 // successfully done
);
     //-----------------------------------------------------------
     reg wait_for_start=1'b0;
     //-----------------------------------------------------------
     `include "axi_tasks.v"
     `include "mem_test_tasks.v"
     `include "gig_mac_tasks.v"
     //-----------------------------------------------------------
     integer idx;
     reg [15:0] tx_rooms, tx_items;
     integer delayA, delay_rx;
     integer seed_rx=5;
     integer num_pkt_received=0;
     //-----------------------------------------------------------
     reg [47:0] mac_src = 48'h00_66_77_88_99_AA;// src
     //-----------------------------------------------------------
     initial begin
       wait (ARESETn==1'b0);
       wait (ARESETn==1'b1);
       repeat (10) @ (posedge ACLK);
       //-----------------------------------------------------
if (`TEST_MEM) begin
       repeat (10) @ (posedge ACLK);
       memory_test(ADDR_START_MEM_RX,ADDR_START_MEM_RX+'h100, 4);
       memory_test(ADDR_START_MEM_RX,ADDR_START_MEM_RX+'h100, 2);
       memory_test(ADDR_START_MEM_RX,ADDR_START_MEM_RX+'h100, 1);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 1);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 2);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 3);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 4);
       //-----------------------------------------------------
       repeat (10) @ (posedge ACLK);
       memory_test(ADDR_START_MEM_TX,ADDR_START_MEM_TX+'h100, 4);
       memory_test(ADDR_START_MEM_TX,ADDR_START_MEM_TX+'h100, 2);
       memory_test(ADDR_START_MEM_TX,ADDR_START_MEM_TX+'h100, 1);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 1);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 2);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 3);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 4);
end
       //-----------------------------------------------------
if (`TEST_MAC_CSR) begin
       repeat (10) @ (posedge ACLK);
       gig_mac_csr_test;
end
       //-----------------------------------------------------
`ifdef TEST_MAC_RX
       num_pkt_received=0;
       repeat (10) @ (posedge ACLK);
if (0) begin
// tester_tx will do this
       gig_mac_init_frame_buffer_tx({32'h0,ADDR_START_MEM_TX+32'h100}
                                   ,{32'h0,ADDR_START_MEM_TX+32'h100}+(2*1024));
       gig_mac_init_frame_buffer_rx({32'h0,ADDR_START_MEM_RX+32'h100}
                                   ,{32'h0,ADDR_START_MEM_RX+32'h100}+(2*1024));
       gig_mac_set_mac_addr(mac_src);
       gig_mac_enable_tx(16<<2); // conf_tx_en & chunk
       gig_mac_enable_rx(16<<2); // conf_rx_en & chunk
       gig_mac_set_ie(1'b1); // enable interrupt
end
     //wait (wait_for_start==1'b1);
     //wait (wait_for_start==1'b0);
       while (1) begin
            gig_mac_receive_packet(0);// 0=fast, 1=slow
            num_pkt_received=num_pkt_received+1;
            delayA = $random(seed_rx);
            delay_rx = delayA&32'h0000_00FF;
            for (idx=0; idx<delay_rx; idx=idx+1) @ (posedge ACLK);
       end
`endif
       //-----------------------------------------------------
       repeat (10) @ (posedge ACLK);
       done = 1'b1;
     end
     //-----------------------------------------------------------
     function integer clogb2;
     input [31:0] value;
     begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
           value = value >> 1;
        end
     endfunction
     //-----------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2015.10.29: Rewritten by Ando Ki (andoki@gmail.com)
//----------------------------------------------------------------
