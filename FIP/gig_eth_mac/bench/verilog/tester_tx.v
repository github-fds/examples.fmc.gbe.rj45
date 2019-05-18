//----------------------------------------------------------------
//  Copyright (c) 2013-2015 by Ando Ki.
//  All right reserved.
//
//  andoki@gmail.com
//----------------------------------------------------------------
// tester_tx.v
//----------------------------------------------------------------
// VERSION: 2015.10.29.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4       - AMBA AXI4
//    AMBA_AXI_CACHE  -
//    AMBA_AXI_PROT   -
//----------------------------------------------------------------
`timescale 1ns/1ns

module tester_tx
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
     `include "axi_tasks.v"
     `include "mem_test_tasks.v"
     `include "gig_mac_tasks.v"
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
     reg [47:0] mac_src = 48'h10_32_54_76_98_BA;// src
     reg [47:0] mac_dst = 48'hA1_98_76_54_32_10;// dst
     //-----------------------------------------------------------
     initial begin
       wait (ARESETn==1'b0);
       wait (ARESETn==1'b1);
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
       top.u_tester_rx.wait_for_start = 1'b1;
       `ifdef TEST_MAC_RX
       for (idx=1; idx<=45; idx=idx+1) begin // num of bytes of payload
       `else
       for (idx=1; idx<=(1<<top.u_mac.P_RX_DESCRIPTOR_FAW); idx=idx+1) begin // num of bytes of payload
       `endif
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent = num_pkt_sent+1;
if (num_pkt_sent>((1<<top.u_mac.P_RX_DESCRIPTOR_FAW)+10)) top.u_tester_rx.wait_for_start = 1'b0;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(top.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
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
       num_pkt_sent=top.u_tester_rx.num_pkt_received;
       `ifdef TEST_MAC_RX
     //for (idx=46; idx<=1500; idx=idx+1) begin // num of bytes of payload
       for (idx=46; idx<=180; idx=idx+1) begin // num of bytes of payload
       `else
       for (idx=46; idx<=46+(1<<top.u_mac.P_RX_DESCRIPTOR_FAW); idx=idx+1) begin // num of bytes of payload
       `endif
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent=num_pkt_sent+1;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(top.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
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
       num_pkt_sent=top.u_tester_rx.num_pkt_received;
       `ifdef TEST_MAC_RX
       for (idx=1500-10; idx<=1500; idx=idx+1) begin // num of bytes of payload
     //for (idx=1048; idx<=1500; idx=idx+1) begin // num of bytes of payload
     //for (idx=1088; idx<=1500; idx=idx+1) begin // num of bytes of payload
     //for (idx=1088; idx<=1465; idx=idx+1) begin // num of bytes of payload
       `else
       for (idx=1500-(1<<top.u_mac.P_RX_DESCRIPTOR_FAW); idx<=1500; idx=idx+1) begin // num of bytes of payload
       `endif
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent=num_pkt_sent+1;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(top.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
     //wait(top.u_tester_rx.num_pkt_received==num_pkt_sent);
       `endif
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_NORMAL_RANDOM) begin
       // payload 1~1500
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
       num_pkt_sent=top.u_tester_rx.num_pkt_received;
       `ifdef TEST_MAC_RX
       for (idy=46; idy<=1500; idy=idy+1) begin // num of bytes of payload
     //for (idy=46; idy<=50; idy=idy+1) begin // num of bytes of payload
       `else
     //for (idy=46; idy<=46+(1<<top.u_mac.P_RX_DESCRIPTOR_FAW); idy=idy+1) begin // num of bytes of payload
       `endif
            value = $random(seed);
            idx = (value%1500)+1; // make 1-1500
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent=num_pkt_sent+1;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (50) @ (posedge ACLK); // in order to see CRC
       wait(top.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
     //wait(top.u_tester_rx.num_pkt_received==num_pkt_sent);
       `endif
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_SHORT_PAD_MANY_DROP_AT_RX) begin
       // need set 'wait_for_start' at tester_rx.v
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
          top.u_tester_rx.wait_for_start = 1'b1;
          gig_mac_set_ie(1'b1); // enable interrupt
          mac_set = 1;
       end else begin
           gig_mac_set_ie(1'b1); // enable interrupt
       end
       num_pkt_sent=0;
       tmp_val = (1<<top.u_mac.P_RX_FIFO_BNUM_FAW)+7;
       for (idx=1; idx<=((1<<top.u_mac.P_RX_FIFO_BNUM_FAW)+7); idx=idx+1) begin // num of bytes of payload
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
            num_pkt_sent = num_pkt_sent+1;
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       `ifdef TEST_MAC_RX
       repeat (5) @ (posedge ACLK); // in order to see CRC
       top.u_tester_rx.wait_for_start = 1'b0;
       repeat (50) @ (posedge ACLK); // in order to see CRC
       if (num_pkt_sent>(1<<top.u_mac.P_RX_DESCRIPTOR_FAW)) begin
           wait(top.u_tester_rx.num_pkt_received>=(num_pkt_sent-(1<<top.u_mac.P_RX_DESCRIPTOR_FAW)));
       `else
           wait(top.u_tester_rx.num_pkt_received>=num_pkt_sent);
       `endif
       end
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_LONG_DROP) begin
       // payload 1501~
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
       for (idx=1501; idx<=1510; idx=idx+1) begin // num of bytes of payload
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_LONG_DROP_LONG) begin
       // payload 1501~
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
       for (idx=1541; idx<=1550; idx=idx+1) begin // num of bytes of payload
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idx); // type-leng
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_RX_CRC_ERROR) begin
       // DMA does not start work before BNUM arrives,
       // which comes with goodframe.
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
       idz = 20;
       for (idx=1; idx<=10; idx=idx+1) begin // num of bytes of payload
            wait (top.gmii_rxdv==1'b0);
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idz); // type-leng
            num_pkt_sent = num_pkt_sent+1;
            wait (top.gmii_rxdv==1'b1);
            if (idx==3) begin
                wait (top.rx_cnt==60); top.gmii_rxd_error = 8'hAA; // error inserstion
                wait (top.rx_cnt==61); top.gmii_rxd_error = 8'h00;
            end
            if (idx==4) begin
                wait (top.rx_cnt==60); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==61); top.gmii_rxer_error = 1'b0;
            end
            if (idx==5) begin
                wait (top.rx_cnt==61); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==62); top.gmii_rxer_error = 1'b0;
            end
            if (idx==6) begin
                wait (top.rx_cnt==62); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==63); top.gmii_rxer_error = 1'b0;
            end
            if (idx==7) begin
                wait (top.rx_cnt==63); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==64); top.gmii_rxer_error = 1'b0;
            end
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       wait(top.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_RX_CRC_ERROR_LONG) begin
       // DMA does not start work before BNUM arrives,
       // which comes with goodframe.
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
       idz = 150;
       for (idx=1; idx<=10; idx=idx+1) begin // num of bytes of payload
            wait (top.gmii_rxdv==1'b0);
            gig_mac_send_packet(mac_dst // dst
                               ,mac_src // src
                               ,idz); // type-leng
            num_pkt_sent = num_pkt_sent+1;
            wait (top.gmii_rxdv==1'b1);
            if (idx==3) begin
                wait (top.rx_cnt==100); top.gmii_rxd_error = 8'hAA; // error inserstion
                wait (top.rx_cnt==101); top.gmii_rxd_error = 8'h00;
            end
            if (idx==4) begin
                wait (top.rx_cnt==101); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==102); top.gmii_rxer_error = 1'b0;
            end
            if (idx==5) begin
                wait (top.rx_cnt==102); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==103); top.gmii_rxer_error = 1'b0;
            end
            if (idx==6) begin
                wait (top.rx_cnt==103); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==104); top.gmii_rxer_error = 1'b0;
            end
            if (idx==7) begin
                wait (top.rx_cnt==104); top.gmii_rxer_error = 1'b1; // error inserstion
                wait (top.rx_cnt==105); top.gmii_rxer_error = 1'b0;
            end
       end
       tx_items=10;
       while (tx_items!=0) gig_mac_get_descriptor_tx(tx_rooms, tx_items);
       wait(top.u_mac.client_tx_empty==1'b1);
       wait(top.u_mac.u_csr_axi.u_csr.rx_desc_empty==1);
       repeat (60) @ (posedge ACLK); // in order to see CRC
       gig_mac_set_ie(1'b0); // enable interrupt
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_NO_CRC) begin
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_JUMBO) begin
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_JUMBO_DROP) begin
end
       //-----------------------------------------------------
if (`TEST_MAC_TX_JUMBO_NO_CRC) begin
end
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
