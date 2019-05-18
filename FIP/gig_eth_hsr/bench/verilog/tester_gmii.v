//----------------------------------------------------------------
//  Copyright (c) 2013-2015 by Ando Ki.
//  All right reserved.
//
//  andoki@gmail.com
//----------------------------------------------------------------
// tester_gmii.v
//----------------------------------------------------------------
// VERSION: 2015.10.29.
//----------------------------------------------------------------
//  [MACROS]
//----------------------------------------------------------------
`timescale 1ns/1ns

module tester_gmii
(
       input  wire        reset
     , output reg         gmii_gtxc=1'b1
     , output reg   [7:0] gmii_txd=8'h0
     , output reg         gmii_txen=1'b0
     , output reg         gmii_txer=1'b0
     , input  wire        gmii_rxc
     , input  wire  [7:0] gmii_rxd
     , input  wire        gmii_rxdv
     , input  wire        gmii_rxer
     //-----------------------------------------------------------
     , output reg         done=1'b0 // successfully done
     //-----------------------------------------------------------
     , input   wire         PCLK
     , output  reg          PSEL=1'b0
     , output  reg          PENABLE=1'b0
     , output  reg   [31:0] PADDR=32'h0
     , output  reg          PWRITE=1'b0
     , output  reg   [31:0] PWDATA=32'h0
     , input   wire  [31:0] PRDATA
);
   //---------------------------------------------------------------------------
   localparam CLK125_FREQ=125_000_000;
   localparam CLK125_PERIOD_HALF=1_000_000_000/(CLK125_FREQ*2);
   //---------------------------------------------------------------------------
   always #CLK125_PERIOD_HALF gmii_gtxc <= ~gmii_gtxc;
   //---------------------------------------------------------------------------
   `undef AMBA_APB3
   `undef AMBA_APB4
   `include "apb_tasks.v"
   `include "task_eth_ip_tcp_udp.v"
   //---------------------------------------------------------------------------
   localparam CSRA_VERSION   = 8'h00
            , CSRA_MAC_ADDR0 = 8'h10 // MAC[47:16]
            , CSRA_MAC_ADDR1 = 8'h14 // MAC[15:0]
            , CSRA_HSR_NET_ID= 8'h18
            , CSRA_CONTROL   = 8'h1C
            , CSRA_PHY       = 8'h20 // to check and drive PHY RESET
            , CSRA_PROXY     = 8'h24 // read-only (num of entries)
            , CSRA_QR        = 8'h28 // read-only (num of entries)
            `ifdef HSR_PERFORMANCE
            , CSRA_CRC_ERR_HOST  = 8'h30 // read-only
            , CSRA_RCV_PKT       = 8'h40 // read-only
            , CSRA_CRC_ERR       = 8'h44 // read-only
            , CSRA_DROP_UNKNOWN  = 8'h48 // read-only
            , CSRA_DROP_FULL     = 8'h4C // read-only
            , CSRA_DROP_SRC      = 8'h50 // read-only
            , CSRA_DROP_NON_HSR  = 8'h54 // read-only
            , CSRA_DROP_NON_QR   = 8'h58 // read-only
            , CSRA_BOTH          = 8'h5C // read-only
            , CSRA_UPSTREAM      = 8'h60 // read-only
            , CSRA_FORWARD       = 8'h64 // read-only
            `endif
            ;
   //---------------------------------------------------------------------------
   reg                preamble=1'b0; // prepend 8-byte preamble when 1
   reg                crc=1'b0; // append 4-byte crc when 1
   reg                broadcast=1'b0;
   reg                vlan=1'b0;
   reg   [47:0]       dst_mac=48'hF0_11_22_33_44_55;
   reg   [47:0]       src_mac=48'h0;
   reg   [15:0]       eth_type=16'h0;
   reg   [0:2048*8-1] payload={2048*8{1'b1}};
   reg   [15:0]       bnum_payload=16'h0; // pure ethernet payload
   reg   [0:2048*8-1] packet={2048*8{1'b0}};
   reg   [15:0]       bnum_packet=16'h0; // from dst-mac to end of payload
   //---------------------------------------------------------------------------
   integer idx;
   reg [31:0] dataR=32'h0;
   reg [31:0] dataW=32'h0;
   reg        status=1'b0;
   reg [31:0] tmp_dat=32'h0;
   reg [47:0] tmp_mac=48'h0;
   reg [31:0] tmp_net=32'h0;
   reg [31:0] tmp_ctl=32'h0;
   reg [31:0] tmp_num=32'h0;
   //---------------------------------------------------------------------------
   initial begin
       repeat (5) @ (posedge gmii_gtxc);
       wait (reset==1'b1);
       wait (reset==1'b0);
       repeat (10) @ (posedge gmii_gtxc);
       wait (u_hsr.RESETn_sync==1'b1);
       repeat (10) @ (posedge gmii_gtxc);
       //------------------------------------------------------------------------
       apb_read(CSRA_MAC_ADDR0, dataR, status); tmp_dat = swap32(dataR);
       apb_read(CSRA_MAC_ADDR1, dataR, status); src_mac = {tmp_dat,swap16(dataR[15:0])};
       //------------------------------------------------------------------------
if (`TEST_CSR) begin
       apb_read(CSRA_VERSION, dataR, status);
       $display("RTL VERSION: 0x%08X", dataR);

       apb_read(CSRA_MAC_ADDR0  , dataR, status); tmp_mac[47:16] = swap32(dataR);
       apb_read(CSRA_MAC_ADDR1  , dataR, status); tmp_mac[15: 0] = swap16(dataR[15:0]);
       apb_read(CSRA_HSR_NET_ID , dataR, status); tmp_net = dataR;
       apb_read(CSRA_CONTROL    , dataR, status); tmp_ctl = dataR;
       $display("MAC: 48'h%12X" , tmp_mac);
       $display("HSR NET ID  : %03b", tmp_net[2:0]);
       $display("%s", (tmp_ctl[0]==1'b0) ? "RedBox" : "DANH");
       $display("PROMISCUOUS : %s", (tmp_ctl[0]==1'b0) ? "OFF" : "ON");
       $display("DROP_NON_HSR: %s", (tmp_ctl[1]==1'b0) ? "OFF" : "ON");
       $display("HSR_QR      : %s", (tmp_ctl[2]==1'b0) ? "OFF" : "ON");

       // change
       dataW = swap32(32'hCB_A9_87_65);       apb_write(CSRA_MAC_ADDR0  , dataW, 4, status);
       dataW = {16'h00_00,swap16(16'h43_21)}; apb_write(CSRA_MAC_ADDR1  , dataW, 4, status);
       dataW = 32'b111;                       apb_write(CSRA_HSR_NET_ID , dataW, 4, status);
       dataW = ~tmp_ctl;                      apb_write(CSRA_CONTROL    , dataW, 4, status);

       apb_read(CSRA_MAC_ADDR0  , dataR, status); tmp_dat = swap32(dataR);
       apb_read(CSRA_MAC_ADDR1  , dataR, status); $display("MAC: 48'h%12X", {tmp_dat,swap16(dataR[15:0])});
       apb_read(CSRA_HSR_NET_ID , dataR, status); $display("HSR NET ID  : %03b", dataR[2:0]);
       apb_read(CSRA_CONTROL    , dataR, status);
       $display("%s", (dataR[0]==1'b0) ? "RedBox" : "DANH");
       $display("PROMISCUOUS : %s", (dataR[0]==1'b0) ? "OFF" : "ON");
       $display("DROP_NON_HSR: %s", (dataR[1]==1'b0) ? "OFF" : "ON");
       $display("HSR_QR      : %s", (dataR[2]==1'b0) ? "OFF" : "ON");

       // return to orginal
       dataW = swap32(tmp_mac[47:16]);        apb_write(CSRA_MAC_ADDR0  , dataW, 4, status);
       dataW = {16'h0,swap16(tmp_mac[15:0])}; apb_write(CSRA_MAC_ADDR1  , dataW, 4, status);
       dataW = tmp_net;                       apb_write(CSRA_HSR_NET_ID , dataW, 4, status);
       dataW = tmp_ctl;                       apb_write(CSRA_CONTROL    , dataW, 4, status);

       apb_read(CSRA_MAC_ADDR0  , dataR, status); tmp_dat = swap32(dataR);
       apb_read(CSRA_MAC_ADDR1  , dataR, status); $display("MAC: 48'h%12X", {tmp_dat,swap16(dataR[15:0])});
       apb_read(CSRA_HSR_NET_ID , dataR, status); $display("HSR NET ID  : %03b", dataR[2:0]);
       apb_read(CSRA_CONTROL    , dataR, status);
       $display("%s", (dataR[0]==1'b0) ? "RedBox" : "DANH");
       $display("PROMISCUOUS : %s", (dataR[0]==1'b0) ? "OFF" : "ON");
       $display("DROP_NON_HSR: %s", (dataR[1]==1'b0) ? "OFF" : "ON");
       $display("HSR_QR      : %s", (dataR[2]==1'b0) ? "OFF" : "ON");

       // generate PHY-RESET-DRIVE
       dataW = 32'h1;        apb_write(CSRA_PHY, dataW, 4, status);
       dataW = 32'h0;        apb_write(CSRA_PHY, dataW, 4, status);
end
       //------------------------------------------------------------------------
if (`TEST_SHORT_SINGLE_PACKET) begin
`ifdef XXYY
       dst_mac=48'h11_23_45_67_89_AB;
       src_mac=48'hC0_DE_F0_12_34_56;
top.mac_addr=dst_mac&~broadcast; // to see dst-hit ==> upward, forward packet
//top.mac_addr=src_mac&~broadcast; // to see src-hit ==> no upward, no forward packets
//top.mac_addr=48'h00_10_20_30_40_50&~broadcast; // to see no-hit, upward, forward packet
                                               // it cause loop NET-A TX <==> NET-B RX
                                               // host TX as well
`else
       dst_mac=48'h10_23_45_67_89_AB;
       src_mac=48'hC0_DE_F0_12_34_56;
top.mac_addr=dst_mac&~broadcast; // to see dst-hit ==> upward, no forward packet
//top.mac_addr=src_mac&~broadcast; // to see src-hit ==> no upward, no forward packets
//top.mac_addr=48'h00_10_20_30_40_50&~broadcast; // to see no-hit ==> no upward, forward packet
                                               // it cause loop NET-A TX <==> NET-B RX
`endif
       eth_type=1;
       bnum_payload=1; // 46
       preamble=1'b1; // prepend 8-byte preamble when 1
       crc=1'b1; // append 4-byte crc when 1
       broadcast=1'b1;
       vlan=1'b0;
       for (idx=0; idx<bnum_payload; idx=idx+1) begin
            payload[8*idx+:8] = idx+1;
       end
       build_ethernet_packet(
               preamble
             , crc
             , broadcast
             , vlan
             , dst_mac
             , src_mac
             , eth_type
             , payload
             , bnum_payload
             , packet
             , bnum_packet
       );
       send_ethernet_packet(
               packet
             , bnum_packet
             , 1 // ifg
       );
end
if (`TEST_SHORT_PACKETS) begin
       eth_type=46;
       bnum_payload=46; // 46
       preamble=1'b1; // prepend 8-byte preamble when 1
       crc=1'b1; // append 4-byte crc when 1
       broadcast=1'b1;
       vlan=1'b0;
       for (idx=0; idx<bnum_payload; idx=idx+1) begin
            payload[8*idx+:8] = idx+1;
       end
       build_ethernet_packet(
               preamble
             , crc
             , broadcast
             , vlan
             , dst_mac
             , src_mac
             , eth_type
             , payload
             , bnum_payload
             , packet
             , bnum_packet
       );
       tmp_num = 2;
       for (idx=0; idx<tmp_num; idx=idx+1) begin
            send_ethernet_packet(
                    packet
                  , bnum_packet
                  , 1 // ifg
            );
       end
end
if (`TEST_LONG_SINGLE_PACKET) begin
       dataW = 32'h0;
       dataW[31] = 1'b0; // RedBox
       dataW[3]  = 1'b0; // snoop
       dataW[2]  = 1'b1; // hsr_qr
       dataW[1]  = 1'b1; // drop non hsr
       dataW[0]  = 1'b1; // promiscuous
       apb_write(CSRA_CONTROL, dataW, 4, status);
       preamble=1'b1; // prepend 8-byte preamble when 1
       crc=1'b1; // append 4-byte crc when 1
       broadcast=1'b1;
       vlan=1'b0;
       bnum_payload=100;
       eth_type=bnum_payload;
       for (idx=0; idx<bnum_payload; idx=idx+1) begin
            payload[8*idx+:8] = idx+1;
       end
       build_ethernet_packet(
               preamble
             , crc
             , broadcast
             , vlan
             , dst_mac
             , src_mac
             , eth_type
             , payload
             , bnum_payload
             , packet
             , bnum_packet
       );
       send_ethernet_packet(
               packet
             , bnum_packet
             , 1 // ifg
       );
end
if (`TEST_LONG_PACKETS) begin
       dataW = 32'h0;
       dataW[31] = 1'b0; // RedBox
       dataW[2]  = 1'b1; // hsr_qr
       dataW[1]  = 1'b1; // drop non hsr
       dataW[0]  = 1'b1; // promiscuous
       apb_write(CSRA_CONTROL, dataW, 4, status);
       preamble=1'b1; // prepend 8-byte preamble when 1
       crc=1'b1; // append 4-byte crc when 1
       broadcast=1'b1;
       vlan=1'b0;
       for (bnum_payload=1000; bnum_payload<1050; bnum_payload=bnum_payload+1) begin
            eth_type=bnum_payload;
            for (idx=0; idx<bnum_payload; idx=idx+1) begin
                 payload[8*idx+:8] = idx+1;
            end
            build_ethernet_packet(
                    preamble
                  , crc
                  , broadcast
                  , vlan
                  , dst_mac
                  , src_mac
                  , eth_type
                  , payload
                  , bnum_payload
                  , packet
                  , bnum_packet
            );
            send_ethernet_packet(
                    packet
                  , bnum_packet
                  , 1 // ifg
            );
       end
end
       repeat (bnum_packet*4) @ (posedge gmii_gtxc);
       done <= 1'b1;
   end
   //---------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2015.10.29: Rewritten by Ando Ki (andoki@gmail.com)
//----------------------------------------------------------------
