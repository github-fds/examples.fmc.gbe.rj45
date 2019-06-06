`ifndef PTPV2_TASKS_V
`define PTPV2_TASKS_V
//--------------------------------------------------------
// Copyright (c) 2019 by Ando Ki.
// All right reserved.
//
// http://www.future-ds.com
// adki@future-ds.com
//--------------------------------------------------------
localparam PTPV2_TWO_STEP=1'b1
         , PTPV2_MULTICAST=1'b1;
localparam CLOCK_ID_OUI=24'hAC_DE_48
         , CLOCK_ID_UUID=40'h23_45_67_AB_CD
         , PORT_ID=16'h00_01
         , MASTER_CLOCK_ID={CLOCK_ID_OUI,CLOCK_ID_UUID}
         , MASTER_PORT_ID=PORT_ID
         , SLAVE_CLOCK_ID={CLOCK_ID_OUI,CLOCK_ID_UUID}+1
         , SLAVE_PORT_ID=PORT_ID+1;
localparam USE_PTPV2_TX_IRQ=1'b0
         , USE_PTPV2_RX_IRQ=1'b0;
//--------------------------------------------------------
task ptpv2_test;
reg [47:0] sec;
reg [31:0] nsec;
reg        mode;
reg [ 3:0] type;
reg [15:0] seq_id;
reg [31:0] value;
begin
   sec  = 48'h12_34_56_78_9A_BC;
   nsec = 32'h00_00_00_00;
   //------------------------------------------------------
   // RTC write
   apb_write(CSRA_LD_NS     , nsec);
   apb_write(CSRA_LD_SEC_LSB, sec[31:0]);
   value = (1'b1<<31) | sec[47:32];
   apb_write(CSRA_LD_SEC_MSB, value);
   // wait until complete
   while (value[31]) apb_read(CSRA_LD_SEC_MSB, value);
   //------------------------------------------------------
   ptp_enable(1, 1, 1);
   //------------------------------------------------------
if (1) ptpv2_sync_follow_up_test;
   //------------------------------------------------------
if (0) ptpv2_delay_req_resp_test;
   //------------------------------------------------------
end
endtask
//--------------------------------------------------------
task ptpv2_sync_follow_up_test;
reg [47:0] sec;
reg [31:0] nsec;
reg        mode;
reg [ 3:0] type;
reg [15:0] seq_id;
reg [31:0] value;
begin
   //------------------------------------------------------
   // send PTPv2 Sync message
   ptpv2_sync(48'h02_11_22_33_44_55, 32'hC0_00_00_00, 48'h0, 32'h0);
   //------------------------------------------------------
   if (USE_PTPV2_TX_IRQ) begin
       ptp_enable_ie(0, 1, 0);
       wait (u_ptpv2_lite.IRQ_PTP);
       apb_read(CSRA_STATUS, value);
       if (value[0]==1'b0) $display($time,,"%m ERROR PTP TX IRQ expected");
       if (value[8]==1'b1) $display($time,,"%m ERROR PTP RX IRQ not expected");
       ptp_fifo_tx_pop(mode, type, seq_id, nsec, sec);
       value[0] = 1'b0;
       apb_write(CSRA_STATUS, value);
       if (u_ptpv2_lite.IRQ_PTP==1'b1) $display($time,,"%m ERROR PTP TX IRQ should be 0");
   end else begin
       ptp_enable_ie(0, 0, 0);
       apb_read(CSRA_TSU_TX_ID, value);
       while (value[21]==1'b0) apb_read(CSRA_TSU_TX_ID, value);
       ptp_fifo_tx_pop(mode, type, seq_id, nsec, sec);
   end
   //------------------------------------------------------
   // send PTPv2 Follow_Up message
   ptpv2_follow_up(48'h02_11_22_33_44_55, 32'hC0_00_00_00
                  , seq_id
                  , sec
                  , nsec
                  );
   //------------------------------------------------------
end
endtask
//--------------------------------------------------------
task ptpv2_delay_req_resp_test;
reg [47:0] sec;
reg [31:0] nsec;
reg        mode;
reg [ 3:0] type;
reg [15:0] seq_id;
reg [31:0] value;
begin
   //------------------------------------------------------
   // send PTPv2 Sync message
   ptpv2_delay_req(48'h02_11_22_33_44_55, 32'hC0_00_00_00, 48'h0, 32'h0);
   //------------------------------------------------------
   if (USE_PTPV2_RX_IRQ) begin
       ptp_enable_ie(0, 0, 1);
       wait (u_ptpv2_lite.IRQ_PTP);
       apb_read(CSRA_STATUS, value);
       if (value[0]==1'b1) $display($time,,"%m ERROR PTP TX IRQ not expected");
       if (value[8]==1'b0) $display($time,,"%m ERROR PTP RX IRQ expected");
       ptp_fifo_tx_pop(mode, type, seq_id, nsec, sec);
       value[0] = 1'b0;
       apb_write(CSRA_STATUS, value);
       if (u_ptpv2_lite.IRQ_PTP==1'b1) $display($time,,"%m ERROR PTP RX IRQ should be 0");
   end else begin
       ptp_enable_ie(0, 0, 0);
       apb_read(CSRA_TSU_RX_ID, value);
       while (value[21]==1'b0) apb_read(CSRA_TSU_RX_ID, value);
       ptp_fifo_rx_pop(mode, type, seq_id, nsec, sec);
   end
   //------------------------------------------------------
   // send PTPv2 Follow_Up message
   ptpv2_delay_resp(48'h02_11_22_33_44_55
                   , 32'hC0_00_00_00
                   , seq_id
                   , sec
                   , nsec
                   );
   //------------------------------------------------------
end
endtask
//--------------------------------------------------------
  reg  [ 7:0] pkt_snd[0:1023];
  reg  [15:0] sync_flag;
  reg  [63:0] sync_corr=64'h0000_0000_0000_0000;
  reg  [15:0] sync_seq_id=16'h0000;
  wire [63:0] sync_req_clock_id; // not used for Sync
  wire [15:0] sync_req_port_id; // not used for Sync
  integer    idx;
//-----------------------------------------------------
task ptpv2_sync;
  input [47:0] mac_addr;
  input [31:0] ip_addr ;
  input [47:0] rtc_tod_sec;
  input [31:0] rtc_tod_ns;
  reg  [15:0] bnum_pkt_snd;
begin
       sync_flag[ 9]=PTPV2_TWO_STEP;
       sync_flag[10]=~PTPV2_MULTICAST;
       sync_seq_id=sync_seq_id+1;
          if (PTPV2_UDP==1'b0) begin
              $msg_ptpv2_ethernet ( pkt_snd
                                  , bnum_pkt_snd
                                  , mac_addr
                                  , 4'h0 //messageType[3:0] Sync
                                  , sync_flag
                                  , sync_corr
                                  , MASTER_CLOCK_ID
                                  , MASTER_PORT_ID
                                  , sync_seq_id
                                  , rtc_tod_sec
                                  , rtc_tod_ns
                                  , sync_req_clock_id
                                  , sync_req_port_id
                                  , 1'b1 //add_crc
                                  , 1'b1 //add_preamble
                                  );
          end else begin
              $msg_ptpv2_udp_ip_ethernet ( pkt_snd
                                         , bnum_pkt_snd
                                         , mac_addr
                                         , ip_addr
                                         , 4'h0 // Sync
                                         , sync_flag
                                         , sync_corr
                                         , MASTER_CLOCK_ID
                                         , MASTER_PORT_ID
                                         , sync_seq_id
                                         , rtc_tod_sec
                                         , rtc_tod_ns
                                         , sync_req_clock_id
                                         , sync_req_port_id
                                         , 1'b1
                                         , 1'b1
                                         );
          end
//$pkt_ethernet_parser(pkt_snd, bnum_pkt_snd, 1'b1, 1'b1);
          @ (posedge gmii_tx_clk);
          for (idx=0; idx<bnum_pkt_snd; idx=idx+1) begin
               gmii_txd  <= pkt_snd[idx];
               gmii_txen <= 1'b1;
               gmii_txer <= 1'b0;
               @ (posedge gmii_tx_clk);
          end
          gmii_txd  <= 8'hFF;
          gmii_txen <= 1'b0;
          gmii_txer <= 1'b0;
          repeat (20) @ (posedge gmii_tx_clk);
end
endtask
//-----------------------------------------------------
task ptpv2_follow_up;
  input [47:0] mac_addr;
  input [31:0] ip_addr ;
  input [15:0] seq_id  ;
  input [47:0] rtc_tod_sec;
  input [31:0] rtc_tod_ns;
  reg  [15:0] bnum_pkt_snd;
begin
       sync_flag[ 9]=PTPV2_TWO_STEP;
       sync_flag[10]=~PTPV2_MULTICAST;
          if (PTPV2_UDP==1'b0) begin // use UDP when 1
              $msg_ptpv2_ethernet ( pkt_snd
                                  , bnum_pkt_snd
                                  , mac_addr
                                  , 4'h8 //messageType[3:0] Follow_Up
                                  , sync_flag
                                  , sync_corr
                                  , MASTER_CLOCK_ID
                                  , MASTER_PORT_ID
                                  , seq_id
                                  , rtc_tod_sec
                                  , rtc_tod_ns
                                  , sync_req_clock_id
                                  , sync_req_port_id
                                  , 1'b1 //add_crc
                                  , 1'b1 //add_preamble
                                  );
          end else begin
              $msg_ptpv2_udp_ip_ethernet ( pkt_snd
                                         , bnum_pkt_snd
                                         , mac_addr
                                         , ip_addr
                                         , 4'h8
                                         , sync_flag
                                         , sync_corr
                                         , MASTER_CLOCK_ID
                                         , MASTER_PORT_ID
                                         , seq_id
                                         , rtc_tod_sec
                                         , rtc_tod_ns
                                         , sync_req_clock_id
                                         , sync_req_port_id
                                         , 1'b1
                                         , 1'b1
                                         );
          end
//$pkt_ethernet_parser(pkt_snd, bnum_pkt_snd, 1'b1, 1'b1);
          @ (posedge gmii_tx_clk);
          for (idx=0; idx<bnum_pkt_snd; idx=idx+1) begin
               gmii_txd  <= pkt_snd[idx];
               gmii_txen <= 1'b1;
               gmii_txer <= 1'b0;
               @ (posedge gmii_tx_clk);
          end
          gmii_txd  <= 8'hFF;
          gmii_txen <= 1'b0;
          gmii_txer <= 1'b0;
          sync_seq_id <= sync_seq_id + 1;
          @ (posedge gmii_tx_clk);
end
endtask
//-----------------------------------------------------
  reg  [ 7:0] pkt_rcv[0:1023];
  integer    idy;
  reg  [15:0] dly_flag;
  reg  [63:0] dly_corr=64'h0000_0000_0000_0000;
  reg  [15:0] dly_seq_id=16'h0000;
  wire [63:0] dly_req_clock_id; // not used for Sync
  wire [15:0] dly_req_port_id; // not used for Sync
//-----------------------------------------------------
task ptpv2_delay_req;
  input [47:0] mac_addr;
  input [31:0] ip_addr ;
  input [47:0] rtc_tod_sec;
  input [31:0] rtc_tod_ns;
  reg  [15:0] bnum_pkt_rcv;
begin
           dly_seq_id = dly_seq_id + 1;
           // gnerate Delay_Resp message
           if (PTPV2_UDP==1'b0) begin // use UDP when 1
               $msg_ptpv2_ethernet ( pkt_rcv
                                   , bnum_pkt_rcv
                                   , mac_addr
                                   , 4'h1 //messageType[3:0] Delay_Resp
                                   , dly_flag
                                   , dly_corr
                                   , SLAVE_CLOCK_ID
                                   , SLAVE_PORT_ID
                                   , dly_seq_id
                                   , rtc_tod_sec
                                   , rtc_tod_ns
                                   , 64'h0
                                   , 32'h0
                                   , 1'b1 //add_crc
                                   , 1'b1 //add_preamble
                                   );
           end else begin
              $msg_ptpv2_udp_ip_ethernet ( pkt_rcv
                                         , bnum_pkt_rcv
                                         , mac_addr
                                         , ip_addr
                                         , 4'h1
                                         , dly_flag
                                         , dly_corr
                                         , SLAVE_CLOCK_ID
                                         , SLAVE_PORT_ID
                                         , dly_seq_id
                                         , rtc_tod_sec
                                         , rtc_tod_ns
                                         , 64'h0
                                         , 32'h0
                                         , 1'b1
                                         , 1'b1
                                         );
           end
//$pkt_ethernet_parser(pkt_rcv, bnum_pkt_rcv, 1'b1, 1'b1);
           @ (posedge gmii_rx_clk);
           for (idy=0; idy<bnum_pkt_rcv; idy=idy+1) begin
                gmii_rxd  <= pkt_rcv[idy];
                gmii_rxdv <= 1'b1;
                gmii_rxer <= 1'b0;
                @ (posedge gmii_rx_clk);
           end
           gmii_rxd  <= 8'hFF;
           gmii_rxdv <= 1'b0;
           gmii_rxer <= 1'b0;
           @ (posedge gmii_rx_clk);
end
endtask
//-----------------------------------------------------
task ptpv2_delay_resp;
  input [47:0] mac_addr;
  input [31:0] ip_addr ;
  input [15:0] seq_id;
  input [47:0] rtc_tod_sec;
  input [31:0] rtc_tod_ns;
  reg  [15:0] bnum_pkt_rcv;
begin
           // gnerate Delay_Resp message
           if (PTPV2_UDP==1'b0) begin // use UDP when 1
               $msg_ptpv2_ethernet ( pkt_rcv
                                   , bnum_pkt_rcv
                                   , mac_addr
                                   , 4'h9 //messageType[3:0] Delay_Resp
                                   , dly_flag
                                   , dly_corr
                                   , MASTER_CLOCK_ID
                                   , MASTER_PORT_ID
                                   , seq_id
                                   , rtc_tod_sec
                                   , rtc_tod_ns
                                   , SLAVE_CLOCK_ID
                                   , SLAVE_PORT_ID
                                   , 1'b1 //add_crc
                                   , 1'b1 //add_preamble
                                   );
           end else begin
              $msg_ptpv2_udp_ip_ethernet ( pkt_rcv
                                         , bnum_pkt_rcv
                                         , mac_addr
                                         , ip_addr
                                         , 4'h9
                                         , dly_flag
                                         , dly_corr
                                         , MASTER_CLOCK_ID
                                         , MASTER_PORT_ID
                                         , seq_id
                                         , rtc_tod_sec
                                         , rtc_tod_ns
                                         , SLAVE_CLOCK_ID
                                         , SLAVE_PORT_ID
                                         , 1'b1
                                         , 1'b1
                                         );
           end
//$pkt_ethernet_parser(pkt_rcv, bnum_pkt_rcv, 1'b1, 1'b1);
           @ (posedge gmii_tx_clk);
           for (idy=0; idy<bnum_pkt_rcv; idy=idy+1) begin
                gmii_txd  <= pkt_rcv[idy];
                gmii_txen <= 1'b1;
                gmii_txer <= 1'b0;
                @ (posedge gmii_tx_clk);
           end
           gmii_txd  <= 8'hFF;
           gmii_txen <= 1'b0;
           gmii_txer <= 1'b0;
           @ (posedge gmii_tx_clk);
end
endtask
//-----------------------------------------------------
// Revision history
//
// 2019.05.20: Started by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
`endif
