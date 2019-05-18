//`ifndef TASK_ETH_IP_TCP_UDP_V
//`define TASK_ETH_IP_TCP_UDP_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Ando Ki.
// All right reserved.
// andoki@gmail.com
//------------------------------------------------------------------------------
// VERSION: 2018.09.12.
//------------------------------------------------------------------------------
// Limitations:
//------------------------------------------------------------------------------
// build_ethernet_packet_ip;
// build_arp_packet;
// build_ip_packet_udp;
// build_udp_packet;
// build_udp_ip_packet;
//------------------------------------------------------------------------------
// build_udp_ip_packet;
//------------------------------------------------------------------------------
// How to call:
// 1. To build udp/ip/eth packet
//    - call build_udp_packet(): build an UDP packet on pkt_udp_data[]
//    - call build_ip_packet_udp(): build an IP packet on pkt_ip_data[] using pkt_udp_data[]
//    - call build_ethernet_packet_ip(): build an Ethernet packet on pkt_eth_data[] using pkt_ip_data[]
//------------------------------------------------------------------------------
reg [31:0] pkt_eth_data[0:2047]; // ethernet-packet buffer
reg [15:0] pkt_ip_data [0:2047]; // ip packet buffer
reg [15:0] pkt_udp_data[0:2047]; // udp packet buffer
//------------------------------------------------------------------------------
// Make an Ethernet packet on packet[] buffer
// using payload[] that contains bnum_payload.
// Finnaly, num of bytes from start to end of pkt_eth_data[]
// is returned through bnum_packet.
task build_ethernet_packet;
     input         preamble; // prepend 8-byte preamble when 1
     input         crc; // append 4-byte crc when 1
     input         broadcast;
     input         vlan;
     input  [47:0] dst_mac;
     input  [47:0] src_mac;
     input  [15:0] eth_type;
     input  [0:2048*8-1] payload;
     input  [15:0] bnum_payload; // pure ethernet payload
     output [0:2048*8-1] packet;
     output [15:0] bnum_packet; // from pre-dst-mac-payload-crc
     integer idx, idy;
begin
     idx = 0;
     if (preamble) begin
         for (idx=0; idx<7; idx=idx+1) packet[8*idx+:8] = 8'h55;
         packet[8*idx+:8] = 8'hD5; // SFD
         idx = idx + 1; // reflect SFD (start frame delimiter)
     end
     packet[8*idx+:48] = dst_mac ; if (broadcast) packet[8*idx+7] = 1'b1; idx = idx + 6;
     packet[8*idx+:48] = src_mac ; idx = idx + 6;
     `ifdef RIGOR
     if ((bnum_payload<=16'h05DC)&&(bnum_payload!=eth_type)) begin
         $display("%d %m WARNING eth-type mis-match", $time);
     end
     `endif
     if (vlan) begin
         packet[8*idx+:16] = 16'h8100; idx = idx + 2;
         packet[8*idx+:16] = 16'h1234; idx = idx + 2;
     end
     packet[8*idx+:16] = eth_type; idx = idx + 2;
     for (idy=0; idy<bnum_payload; idy=idy+1) begin
          packet[8*(idx+idy)+:8] = payload[8*idy+:8];
     end
     idx = idx + idy;
     if (crc) begin
         if ((eth_type<=16'h05DC)&&(bnum_payload<46)) begin
              for (idy=0; idy<(46-bnum_payload); idy=idy+1) begin
                   packet[8*(idx+idy)+:8] = 8'h00;
              end
              idx = idx + idy;
         end
         if (preamble) begin
             packet[8*idx+:32] = crc_gen(packet,8,idx-8);
         end else begin
             packet[8*idx+:32] = crc_gen(packet,0,idx);
         end
         bnum_packet = idx+4;
     end else begin
         bnum_packet = idx;
     end
end
endtask
//------------------------------------------------------------------------------
task send_ethernet_packet;
     input  [0:2048*8-1] packet;
     input  [15:0] bnum_packet; // pure ethernet payload
     input         ifg; // inter-frame gap when 1
     integer idx;
begin
     for (idx=0; idx<bnum_packet; idx=idx+1) begin
          @ (posedge gmii_gtxc);
          gmii_txd  = packet[8*idx+:8];
          gmii_txen = 1'b1;
          gmii_txer = 1'b0;
     end
     @ (posedge gmii_gtxc);
     gmii_txen = 1'b0;
     if (ifg) begin
         for (idx=0; idx<11; idx=idx+1) @ (posedge gmii_gtxc);
     end
end
endtask
//------------------------------------------------------------------------------
// note that it expect D[0] first as bit.
// new_crc = func_crc32_d8(D, crc)
`include "func_crc32_d8.v"
//------------------------------------------------------------------------------
// It takes the nuber of bytes of message in 'packet[]'.
// It generates 32-bit CRC32.
function [0:31] crc_gen;
     input  [0:8*2048-1] pkt;
     input  [15: 0] offset; // starting index(8-bit wise) of pkt
     input  [15: 0] bnum; // num of bytes of message
     reg    [31: 0] crc_reg;
reg    [ 7: 0] tmp;
     integer idx, idy;
begin
     crc_reg = ~32'h0;
     for (idx=0; idx<bnum; idx=idx+1) begin
          crc_reg = func_crc32_d8(pkt[8*(idx+offset)+:8], crc_reg);
     end
     for (idy=0; idy<4; idy=idy+1) begin
          crc_gen[idy*8+:8] = ~{crc_reg[24],crc_reg[25],crc_reg[26],crc_reg[27]
                               ,crc_reg[28],crc_reg[29],crc_reg[30],crc_reg[31]};
          crc_reg = {crc_reg[23:0],8'hFF};
     end
end
endfunction
//------------------------------------------------------------------------------
// return 1 for OK
function crc_chk;
     input  [0:8*2048-1] pkt;
     input  [15: 0] offset; // starting index(8-bit wise) of pkt
     input  [15:0] bnum; // num of bytes of message
     reg    [31:0] crc_reg;
     reg    [ 7:0] tmp;
     integer idx, idy;
begin
     crc_reg = ~32'h0;
     for (idx=0; idx<bnum; idx=idx+1) begin
          crc_reg = func_crc32_d8(pkt[8*(idx+offset)+:8], crc_reg);
     end
     crc_chk = (crc_reg===32'hC704DD7B);
end
endfunction
//------------------------------------------------------------------------------
// Revision history
//
// 2018.09.12: Started by Ando Ki
//
// andoki@gmail.com
//------------------------------------------------------------------------------
//`endif
