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
     #(parameter NUM_OF_HSR_NODE=4
               , HSR_ID=0
               , TX_ENABLE=0)
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
     , input  wire [47:0] mac_addr
     , output reg         done=1'b0 // successfully done
);
   //---------------------------------------------------------------------------
   localparam CLK125_FREQ=125_000_000;
   localparam CLK125_PERIOD_HALF=1_000_000_000/(CLK125_FREQ*2);
   //---------------------------------------------------------------------------
   always #CLK125_PERIOD_HALF gmii_gtxc <= ~gmii_gtxc;
   //---------------------------------------------------------------------------
   `include "task_eth_ip_tcp_udp.v"
   //---------------------------------------------------------------------------
   reg                preamble=1'b0; // prepend 8-byte preamble when 1
   reg                crc=1'b0; // append 4-byte crc when 1
   reg                broadcast;
   reg                vlan=1'b0;
   reg   [47:0]       dst_mac=48'h0;
   reg   [47:0]       src_mac=48'h0;
   reg   [15:0]       eth_type=16'h0;
   reg   [0:2048*8-1] payload={2048*8{1'b1}};
   reg   [15:0]       bnum_payload=16'h0; // pure ethernet payload
   reg   [0:2048*8-1] packet={2048*8{1'b0}};
   reg   [15:0]       bnum_packet=16'h0; // from dst-mac to end of payload
   //---------------------------------------------------------------------------
   integer idx;
   //---------------------------------------------------------------------------
   initial begin
       repeat (5) @ (posedge gmii_gtxc);
       wait (reset==1'b1);
       src_mac=mac_addr;
       wait (reset==1'b0);
       wait (u_fpga.hsr_ready==1'b1);
       repeat (50) @ (posedge gmii_gtxc);
if (TX_ENABLE) begin
if (`TEST_TARGET) begin
       dst_mac[47:8]=mac_addr[47:8];
       dst_mac[ 7:0]=(HSR_ID+1)%NUM_OF_HSR_NODE;
       broadcast=1'b0; //broadcast=1'b1;
       vlan=1'b0;
       eth_type=46;
       bnum_payload=46; // 46
       preamble=1'b1; // prepend 8-byte preamble when 1
       crc=1'b1; // append 4-byte crc when 1
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
      //send_ethernet_packet(
      //        packet
      //      , bnum_packet
      //      , 1 // ifg
      //);
      //send_ethernet_packet(
      //        packet
      //      , bnum_packet
      //      , 1 // ifg
      //);
      //send_ethernet_packet(
      //        packet
      //      , bnum_packet
      //      , 1 // ifg
      //);
      //send_ethernet_packet(
      //        packet
      //      , bnum_packet
      //      , 1 // ifg
      //);
      //send_ethernet_packet(
      //        packet
      //      , bnum_packet
      //      , 1 // ifg
      //);
       repeat (bnum_packet*4) @ (posedge gmii_gtxc);
end
end //if (TX_ENABLE) begin
       done <= 1'b1;
   end
   //---------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2015.10.29: Rewritten by Ando Ki (andoki@gmail.com)
//----------------------------------------------------------------
