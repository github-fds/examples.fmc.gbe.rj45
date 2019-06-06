//----------------------------------------------------------------
//  Copyright (c) 2013-2015 by Ando Ki.
//  All right reserved.
//
//  andoki@gmail.com
//----------------------------------------------------------------
// tester.v
//----------------------------------------------------------------
// VERSION: 2015.10.29.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4       - AMBA AXI4
//    AMBA_AXI_CACHE  -
//    AMBA_AXI_PROT   -
//----------------------------------------------------------------
`timescale 1ns/1ns

module tester
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
     //-----------------------------------------------------------
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
     //-----------------------------------------------------------
     , output reg  [AXI_WIDTH_DA-1:0]  WDATA=~'h0
     , output reg  [AXI_WIDTH_DS-1:0]  WSTRB='h0
     , output reg                      WLAST=1'b0
     , output reg                      WVALID=1'b0
     , input  wire                     WREADY
     //-----------------------------------------------------------
     , input  wire [ 1:0]              BRESP
     , input  wire                     BVALID
     , output reg                      BREADY=1'b0
     //-----------------------------------------------------------
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
     //-----------------------------------------------------------
     , input  wire [AXI_WIDTH_DA-1:0]  RDATA
     , input  wire [ 1:0]              RRESP
     , input  wire                     RLAST
     , input  wire                     RVALID
     , output reg                      RREADY=1'b0
     //-----------------------------------------------------------
     , input  wire                     ptp_ppus
     //-----------------------------------------------------------
     , input  wire [47:0]              mac_addr
     , output reg                      done=1'b0 // successfully done
);
     //-----------------------------------------------------------
     reg  [AXI_WIDTH_CID-1:0] MID=AXI_MST_ID;
     reg  [AXI_WIDTH_ID-1:0]  AWID='h0;
     reg  [AXI_WIDTH_ID-1:0]  WID='h0;
     reg  [AXI_WIDTH_ID-1:0]  BID='h0;
     reg  [AXI_WIDTH_ID-1:0]  ARID='h0;
     reg  [AXI_WIDTH_ID-1:0]  RID='h0;
     //-----------------------------------------------------------
     always @ (posedge ACLK) begin
          if (AWVALID&AWREADY) BID <= AWID;
          if (ARVALID&ARREADY) RID <= ARID;
     end
     //-----------------------------------------------------------
     `include "axi_tasks.v"
     `include "mem_test_tasks.v"
     `include "gig_mac_tasks.v"
     `include "ptpv2_slave_tasks.v"
     //-----------------------------------------------------------
     integer idx, idy, idz;
     reg [15:0] tx_rooms, tx_items;
     integer num_pkt_sent=0;
     integer seed=3;
     reg [15:0] value;
     reg [ 1:0] status;
     integer tmp_val=0;
     integer mac_set=0;
     //-----------------------------------------------------------
     reg [47:0] mac_src = 48'h0;// src
     reg [47:0] mac_dst = 48'h0;// dst
     //-----------------------------------------------------------
     initial begin
       wait (ARESETn==1'b0);
       mac_src = mac_addr;// src
       mac_dst[47:8] = mac_addr[47:8];// dst
       mac_dst[7:0] = (mac_addr[7:0]+1);
       wait (ARESETn==1'b1);
       repeat (10) @ (posedge ACLK);
       gig_mac_set_mac_addr(mac_src);
       repeat (10) @ (posedge ACLK);
       //-----------------------------------------------------
if (`TEST_MEM) begin
       repeat (10) @ (posedge ACLK);
       memory_test(ADDR_START_MEM_TX,ADDR_START_MEM_TX+'h100, 4);
       memory_test(ADDR_START_MEM_TX,ADDR_START_MEM_TX+'h100, 2);
       memory_test(ADDR_START_MEM_TX,ADDR_START_MEM_TX+'h100, 1);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 1);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 2);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 3);
       memory_test_burst(ADDR_START_MEM_TX, ADDR_START_MEM_TX+'h100, 4, 4);
       //-----------------------------------------------------
       repeat (10) @ (posedge ACLK);
       memory_test(ADDR_START_MEM_RX,ADDR_START_MEM_RX+'h100, 4);
       memory_test(ADDR_START_MEM_RX,ADDR_START_MEM_RX+'h100, 2);
       memory_test(ADDR_START_MEM_RX,ADDR_START_MEM_RX+'h100, 1);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 1);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 2);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 3);
       memory_test_burst(ADDR_START_MEM_RX, ADDR_START_MEM_RX+'h100, 4, 4);
end
       //-----------------------------------------------------
if (`TEST_MAC_CSR) begin
       repeat (10) @ (posedge ACLK);
       gig_mac_csr_test;
       repeat (10) @ (posedge ACLK);
       gig_phy_reset(1, 0, data_burst_read[0]);
       data_burst_read[0][30]=1'b1;
       while (data_burst_read[0][30]==1'b1) axi_read(CSRA_CONTROL, 4, 1, status);
       gig_phy_reset(1, 1, data_burst_read[0]);
       repeat (10) @ (posedge ACLK);
end
       //-----------------------------------------------------
if (`TEST_PTP_CSR) begin
       repeat (10) @ (posedge ACLK);
       ptp_csr_test;
       repeat (10) @ (posedge ACLK);
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_SHORT_PAD_SINGLE) begin
       // to check padding: payload 1 to 45
       repeat (10) @ (posedge ACLK);
       if (mac_set==0) begin
           gig_mac_init_frame_buffer_tx({32'h0,ADDR_START_MEM_TX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_TX+32'h100}+(2*1024));
           gig_mac_init_frame_buffer_rx({32'h0,ADDR_START_MEM_RX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_RX+32'h100}+(2*1024));
           gig_mac_set_mac_addr(mac_src);
           gig_mac_set_conf_tx( 1'b0, 1'b0 ); // jumbo_en, no_gen_crc;
           gig_mac_set_conf_rx( 1'b0, 1'b0, 1'b1 ); // jumbo_en, no_chk_crc, promiscuous;
           gig_mac_enable_tx(16<<2); // conf_tx_en & chunk
           gig_mac_enable_rx(16<<2); // conf_rx_en & chunk
           gig_mac_set_ie(1'b1); // enable interrupt
           mac_set = 1;
           num_pkt_sent=0;
       end
//       top.u_tester_rx.wait_for_start = 1'b1;
       idx = 10;
       gig_mac_send_packet(mac_dst // dst
                          ,mac_src // src
                          ,idx); // type-leng
       num_pkt_sent = num_pkt_sent+1;
//if (num_pkt_sent>((1<<u_fpga.u_dut.u_mac.P_RX_DESCRIPTOR_FAW)+10)) top.u_tester_rx.wait_for_start = 1'b0;
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(u_fpga.u_dut.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(u_fpga.u_dut.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
     //wait(top.u_tester_rx.num_pkt_received==num_pkt_sent);
       `endif
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_SHORT_PAD) begin
       // to check padding: payload 1 to 45
       repeat (10) @ (posedge ACLK);
       if (mac_set==0) begin
           gig_mac_init_frame_buffer_tx({32'h0,ADDR_START_MEM_TX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_TX+32'h100}+(2*1024));
           gig_mac_init_frame_buffer_rx({32'h0,ADDR_START_MEM_RX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_RX+32'h100}+(2*1024));
           gig_mac_set_mac_addr(mac_src);
           gig_mac_set_conf_tx( 1'b0, 1'b0 ); // jumbo_en, no_gen_crc;
           gig_mac_set_conf_rx( 1'b0, 1'b0, 1'b1 ); // jumbo_en, no_chk_crc, promiscuous;
           gig_mac_enable_tx(16<<2); // conf_tx_en & chunk
           gig_mac_enable_rx(16<<2); // conf_rx_en & chunk
           gig_mac_set_ie(1'b1); // enable interrupt
           mac_set = 1;
           num_pkt_sent=0;
       end
//       top.u_tester_rx.wait_for_start = 1'b1;
       `ifdef TEST_MAC_RX
       for (idx=1; idx<=45; idx=idx+1) begin // num of bytes of payload
       `else
       for (idx=1; idx<=(1<<u_fpga.u_dut.u_mac.P_RX_DESCRIPTOR_FAW); idx=idx+1) begin // num of bytes of payload
       `endif
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent = num_pkt_sent+1;
//if (num_pkt_sent>((1<<u_fpga.u_dut.u_mac.P_RX_DESCRIPTOR_FAW)+10)) top.u_tester_rx.wait_for_start = 1'b0;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(u_fpga.u_dut.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(u_fpga.u_dut.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
     //wait(top.u_tester_rx.num_pkt_received==num_pkt_sent);
       `endif
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_NORMAL) begin
       // payload 46~1499
       repeat (10) @ (posedge ACLK);
       if (mac_set==0) begin
           gig_mac_init_frame_buffer_tx({32'h0,ADDR_START_MEM_TX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_TX+32'h100}+(2*1024));
           gig_mac_init_frame_buffer_rx({32'h0,ADDR_START_MEM_RX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_RX+32'h100}+(2*1024));
           gig_mac_set_mac_addr(mac_src);
           gig_mac_set_conf_tx( 1'b0, 1'b0 ); // jumbo_en, no_gen_crc;
           gig_mac_set_conf_rx( 1'b0, 1'b0, 1'b1 ); // jumbo_en, no_chk_crc, promiscuous;
           gig_mac_enable_tx(16<<2); // conf_tx_en & chunk
           gig_mac_enable_rx(16<<2); // conf_rx_en & chunk
           gig_mac_set_ie(1'b1); // enable interrupt
           mac_set = 1;
       end else begin
           gig_mac_set_ie(1'b1); // enable interrupt
       end
//       num_pkt_sent=top.u_tester_rx.num_pkt_received;
       `ifdef TEST_MAC_RX
     //for (idx=46; idx<=1500; idx=idx+1) begin // num of bytes of payload
       for (idx=46; idx<=180; idx=idx+1) begin // num of bytes of payload
       `else
       for (idx=46; idx<=46+(1<<u_fpga.u_dut.u_mac.P_RX_DESCRIPTOR_FAW); idx=idx+1) begin // num of bytes of payload
       `endif
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent=num_pkt_sent+1;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(u_fpga.u_dut.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(u_fpga.u_dut.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
     //wait(top.u_tester_rx.num_pkt_received==num_pkt_sent);
       `endif
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_LONG) begin
       // payload ~1500
       repeat (10) @ (posedge ACLK);
       if (mac_set==0) begin
           gig_mac_init_frame_buffer_tx({32'h0,ADDR_START_MEM_TX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_TX+32'h100}+(2*1024));
           gig_mac_init_frame_buffer_rx({32'h0,ADDR_START_MEM_RX+32'h100}
                                       ,{32'h0,ADDR_START_MEM_RX+32'h100}+(2*1024));
           gig_mac_set_mac_addr(mac_src);
           gig_mac_set_conf_tx( 1'b0, 1'b0 ); // jumbo_en, no_gen_crc;
           gig_mac_set_conf_rx( 1'b0, 1'b0, 1'b1 ); // jumbo_en, no_chk_crc, promiscuous;
           gig_mac_enable_tx(16<<2); // conf_tx_en & chunk
           gig_mac_enable_rx(16<<2); // conf_rx_en & chunk
           gig_mac_set_ie(1'b1); // enable interrupt
           mac_set = 1;
       end else begin
           gig_mac_set_ie(1'b1); // enable interrupt
       end
//       num_pkt_sent=top.u_tester_rx.num_pkt_received;
       `ifdef TEST_MAC_RX
       for (idx=1500-10; idx<=1500; idx=idx+1) begin // num of bytes of payload
     //for (idx=1048; idx<=1500; idx=idx+1) begin // num of bytes of payload
     //for (idx=1088; idx<=1500; idx=idx+1) begin // num of bytes of payload
     //for (idx=1088; idx<=1465; idx=idx+1) begin // num of bytes of payload
       `else
       for (idx=1500-(1<<u_fpga.u_dut.u_mac.P_RX_DESCRIPTOR_FAW); idx<=1500; idx=idx+1) begin // num of bytes of payload
       `endif
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent=num_pkt_sent+1;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(u_fpga.u_dut.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(u_fpga.u_dut.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
     //wait(top.u_tester_rx.num_pkt_received==num_pkt_sent);
       `endif
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
       repeat (100) @ (posedge ACLK);
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
