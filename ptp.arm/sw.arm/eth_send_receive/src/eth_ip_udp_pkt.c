//----------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//----------------------------------------------------------------------------
// VERSION = 2018.10.25.
//----------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "eth_ip_udp_pkt.h"

//------------------------------------------------------------------------------
#define PRT_MAC(A,B)\
        printf("%s 0x%02X%02X%02X%02X%02X%02X\n", (A)\
                   ,(B)[0],(B)[1],(B)[2],(B)[3],(B)[4],(B)[5])

#ifndef COMPACT_CODE
//------------------------------------------------------------------------------
static uint32_t crc_table[] = {
  0x4DBDF21C, 0x500AE278, 0x76D3D2D4, 0x6B64C2B0,
  0x3B61B38C, 0x26D6A3E8, 0x000F9344, 0x1DB88320,
  0xA005713C, 0xBDB26158, 0x9B6B51F4, 0x86DC4190,
  0xD6D930AC, 0xCB6E20C8, 0xEDB71064, 0xF0000000
};
//------------------------------------------------------------------------------
// 1. calculate Etherent CRC checksum
// 2. return the host order checksum
//    . ((crc&0x000000FF)    )&0xFF: driven first
//    . ((crc&0x0000FF00)>> 8)&0xFF: driven second
//    . ((crc&0x00FF0000)>>16)&0xFF: driven third
//    . ((crc&0xFF000000)>>24)&0xFF: driven last
uint32_t compute_eth_crc(uint8_t *pkt, uint32_t bnum) {
  unsigned int n;
  uint32_t crc=0;
  for (n=0; n<bnum; n++) {
    crc = (crc>>4)^crc_table[(crc^(pkt[n]>>0))&0x0F]; /* lower nibble */
    crc = (crc>>4)^crc_table[(crc^(pkt[n]>>4))&0x0F]; /* upper nibble */
  }
  return crc;
}
#endif

//------------------------------------------------------------------------------
// 1. clear IP header checksum
// 2. calculate IP header checksum
// 3. return the host order checksum
uint16_t compute_ip_checksum(ip_hdr_t* iphdr) {
    iphdr->ip_sum = 0;
    uint32_t sum = 0;
    uint16_t s_sum = 0;
    int numShorts = iphdr->ip_hdl * 2;
    int i = 0;
    uint16_t* s_ptr = (uint16_t*)iphdr;

    for (i = 0; i < numShorts; ++i) {
        /* sum all except checksum field */
        if (i != 5) {
            sum += ntohs(*s_ptr);
        }
        ++s_ptr;
    }

    /* sum carries */
    sum = (sum >> 16) + (sum & 0xFFFF);
    sum += (sum >> 16);

    /* ones compliment */
    s_sum = sum & 0xFFFF;
    s_sum = (~s_sum);

    return s_sum;
}

//------------------------------------------------------------------------------
// Normal Ethernet Packet
//    (8)   (6)   (6)   (2)   (0-1500)   (46-0)   (4)
//  +-----+-----+-----+-----+-----------+--------+-----+                                              
//  | PRE | DST | SRC | LEN | DATA      | PAD    | CRC |                                              
//  +-----+-----+-----+-----+-----------+--------+-----+                                              
//        |                 |<-- LEN -->|
//        |<--- 64-1518 ------------------------------>|                                              
//
// VLAN
//    (8)   (6)   (6)   (2)    (2)    (2)   (0-1500)   (46-0)   (4)
//  +-----+-----+-----+------+------+-----+-----------+--------+-----+                                
//  | PRE | DST | SRC |0x8100| Vtag | LEN | DATA      | PAD    | CRC |                                
//  +-----+-----+-----+------+------+-----+-----------+--------+-----+                                
//        |           |<----------->|     |<-- LEN -->|
//        |<--- 68-1522 -------------------------------------------->|                                
//
// HSR
//    (8)   (6)   (6)   (2)    (2)    (2)   (2)   (0-1500)   (46-0)   (4)
//  +-----+-----+-----+------+------+-----+-----+-----------+--------+-----+                          
//  | PRE | DST | SRC |0x892F|Pt/SZE| SEQ | LEN | DATA      | PAD    | CRC |                          
//  +-----+-----+-----+------+------+-----+-----+-----------+--------+-----+                          
//        |           |<----------------->|     |<-- LEN -->|                                         
//        |                  |<-- SZE(12-bit) ------------->|
//        |<--- 68-1524 -------------------------------------------------->|                          
//
// HSR with VLAN
//    (8)   (6)   (6)   (2)    (2)    (2)    (2)    (2)   (2)   (0-1500)   (46-0)   (4)
//  +-----+-----+-----+------+------+------+------+-----+-----+-----------+--------+-----+            
//  | PRE | DST | SRC |0x8100| Vtag |0x892F|Pt/SZE| SEQ | LEN | DATA      | PAD    | CRC |            
//  +-----+-----+-----+------+------+------+------+-----+-----+-----------+--------+-----+            
//        |           |<----------->|<----------------->|     |<-- LEN -->|                           
//        |                                |<--- SZE -------------------->|
//        |<--- 68-1528 ---------------------------------------------------------------->|
//------------------------------------------------------------------------------
int populate_eth_hdr( eth_hdr_t *hdr
                    , uint8_t    mac_dst[6]// dest MAC (network order)
                    , uint8_t    mac_src[6]// src MAC (network order)
                    , uint16_t   type_leng // leng or type (host order)
                    , int        pkt_type // VLAN or/and HSR
                    )
{
    uint8_t *pt=(uint8_t*)hdr;
    int bnum;
    if (mac_dst) {
        memcpy((void*)pt, mac_dst, ETH_ADDR_LEN);
        if (pkt_type&PKT_TYPE_BROADCAST) pt[0]|=0x1;
    }
    if (mac_src) {
        memcpy((void*)(pt+6), mac_src, ETH_ADDR_LEN);
    }
    pt += 12;
    bnum = 12;
    if (pkt_type&PKT_TYPE_VLAN) {
        *(uint16_t*)pt = htons(0x8100); pt+=2; // type
        *(uint16_t*)pt = htons(0x0000); pt+=2; // tag
         bnum+=4;
    }
    if (pkt_type&PKT_TYPE_HSR) {
        *(uint16_t*)pt = htons(0x892F); pt+=2; // type
        *(uint16_t*)pt = htons(type_leng+6); pt+=2; // size
        *(uint16_t*)pt = htons(0x0000); pt+=2; // seq
         bnum+=6;
    }
    #if defined(RIGOR)
    uintptr_t ptx=(uintptr_t)pt;
    if (ptx%2) {
            printf("%s:%s() mis-aligned 0x%08X\n", __FILE__, __func__, (unsigned)ptx%2);
    }
    #endif
    *(uint16_t*)pt = htons(type_leng);
    bnum+=2;
    return bnum;
}

//------------------------------------------------------------------------------
// It fills raw Ethernet packet and retuns length.
// Note that it retusns head-length when payload[] is empty.
// It returns the number of bytes this routine touched.
// It returns the length of header when 'payload' is NULL.
// It does not fill padding for less than 46-byte payload.
int gen_eth_packet( uint8_t  *packet
                  , uint8_t   mac_dst[6] // network order
                  , uint8_t   mac_src[6] // network order
                  , int       pkt_type   // VLAN and/or HSR
                  , uint16_t  type_leng  // type-leng (it could be the smae as 'payload_len')
                  , uint16_t  payload_len// payload length
                  , uint8_t  *payload
                  )
{
    static uint16_t hsr_seq=1;
    int loc;
    loc = populate_eth_hdr((eth_hdr_t*)packet, mac_dst, mac_src, type_leng, pkt_type);
    if (pkt_type&PKT_TYPE_HSR) {
        if (pkt_type&PKT_TYPE_VLAN) {
            ((eth_hdr_t*)packet)->vlan_hsr.hsr_size=payload_len+6;
            ((eth_hdr_t*)packet)->vlan_hsr.hsr_seq=hsr_seq++;
        } else {
          ((eth_hdr_t*)packet)->hsr.hsr_size=payload_len+6;
          ((eth_hdr_t*)packet)->hsr.hsr_seq=hsr_seq++;
        }
    }
    if (payload) {
        memcpy(&packet[loc], payload, payload_len);
        return loc+payload_len;
    } else {
        return loc;
    }
}

//------------------------------------------------------------------------------
// Populates an IP header with the usual data.
// Note SrcIp and DstIp must be passed into
// the function in network byte order.
int populate_ip_hdr( ip_hdr_t *hdr
                   , uint32_t  ip_src // host order
                   , uint32_t  ip_dst // host order
                   , uint8_t   protocol
                   , uint16_t  payload_len // pure payload size (not including header)
                   )
{
    hdr->ip_hdl = 5;
    hdr->ip_ver = 4;
    hdr->ip_tos = 0;
    hdr->ip_id  = 0;

    #if defined(RIGOR)
    uintptr_t pt=(uintptr_t)&(hdr->ip_off);
    if (pt%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", __FILE__, __func__, (unsigned)pt%2);
    }
    #endif
    hdr->ip_off = htons(IP_FRAG_DF); // what if mis-aligned

    #if defined(RIGOR)
    pt=(uintptr_t)&(hdr->ip_len);
    if (pt%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", __FILE__, __func__, (unsigned)pt%2);
    }
    #endif
    hdr->ip_len = htons(IP_HDR_LEN + payload_len ); // what if mis-aligned
    hdr->ip_ttl = 0x01;
    hdr->ip_pro = protocol;
    #if defined(RIGOR)
    pt=(uintptr_t)&(hdr->ip_src);
    if (pt%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", __FILE__, __func__, (unsigned)pt%2);
    }
    #endif
    hdr->ip_src = htonl(ip_src); // what if mis-aligned
    hdr->ip_dst = htonl(ip_dst); // what if mis-aligned
    hdr->ip_sum = htons(compute_ip_checksum(hdr));

    return IP_HDR_LEN;
}

//------------------------------------------------------------------------------
// It fills IP packet and return length.
// Note that it retusns head-length when payload[] is empty.
int gen_ip_packet( uint8_t  *packet
                 , uint32_t  ip_src     // host order
                 , uint32_t  ip_dst     // host order
                 , uint8_t   protocol
                 , uint16_t  payload_len // IP payload length
                 , uint8_t  *payload)
{
    populate_ip_hdr((ip_hdr_t*)packet, ip_src, ip_dst, protocol, payload_len);
    if (payload) {
        memcpy(&packet[IP_HDR_LEN], payload, payload_len);
        return IP_HDR_LEN + payload_len;
    } else {
        return IP_HDR_LEN;
    }
}

//------------------------------------------------------------------------------
// It fills IP over Ethernet packet and return length.
// Note that it retusns head-length when payload[] is empty.
// It returns the number of bytes this routine touched.
// It returns the length of header when 'payload' is NULL.
int gen_ip_eth_packet( uint8_t  *packet
                     , uint8_t   mac_dst[6] // network order
                     , uint8_t   mac_src[6] // network order
                     , int       pkt_type   // VLAN and/or HSR
                     , uint32_t  ip_src     // host order
                     , uint32_t  ip_dst     // host order
                     , uint8_t   protocol
                     , uint16_t  payload_len // IP payload length
                     , uint8_t  *payload)
{
    int leng;
    leng  = populate_eth_hdr((eth_hdr_t*)packet, mac_dst, mac_src, ETH_TYPE_IP, pkt_type);
    leng += gen_ip_packet(&packet[ETH_HDR_LEN],
                          ip_src, ip_dst, protocol, payload_len, payload);
    return leng;
    // It returns the number of bytes this routine touched; it returns the length of header when 'payload' is NULL.
}

//------------------------------------------------------------------------------
// Populates an IP header with the usual data.
// Note SrcPort and DstPort must be passed into
// the function in network byte order.
int populate_udp_hdr( udp_hdr_t *hdr
                    , uint16_t   port_src // host order
                    , uint16_t   port_dst // host order
                    , uint16_t   payload_len  // pure payload size (not including header)
                    ) 
{
    #if defined(RIGOR)
    uintptr_t pt=(uintptr_t)&(hdr->udp_src);
    if (pt%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", __FILE__, __func__, (unsigned)pt%2);
    }
    #endif
    hdr->udp_src = htons(port_src); // what if mis-aligned
    hdr->udp_dst = htons(port_dst); // what if mis-aligned
    hdr->udp_len = htons(payload_len  + UDP_HDR_LEN); // what if mis-aligned
    hdr->udp_sum = 0; // what if mis-aligned

    return UDP_HDR_LEN;
}

//------------------------------------------------------------------------------
// It fills IP packet and return length.
// Note that it retusns head-length when payload[] is empty.
int gen_udp_packet( uint8_t  *packet
                  , uint16_t  port_src   // 0x0001; host order
                  , uint16_t  port_dst   // 0x0002; host order
                  , uint16_t  payload_len // UDP payload length
                  , uint8_t  *payload
                  )
{
    populate_udp_hdr((udp_hdr_t*)packet, port_src, port_dst, payload_len);
    if (payload!=0) {
        memcpy(&packet[UDP_HDR_LEN], payload, payload_len);
        return UDP_HDR_LEN+payload_len;
    } else {
        return UDP_HDR_LEN;
    }
}

//------------------------------------------------------------------------------
// Generate UDP/IP over Ethernet packet
// It returns the number of bytes this routine touched.
// It returns the length of header when 'payload' is NULL.
//      +-----------+-----------+
// +0x00| DstMac      DstMac    |
//      +-----------+-----------+
// +0x04| DstMac    | SrcMac    |
//      +-----------+-----------+
// +0x08| SrcMac      SrcMac    |
//      +-----------+-----------+
// +0x0C| 0x0800    | V/H/T     |  <-- Ethernet Hdr (14)
//      +-----------+-----------+
// +0x10| TotalLen  | Identi    |
//      +-----------+-----+-----+
// +0x14| F/Frag    | TTL | 17  |
//      +-----------+-----+-----+
// +0x18| HdrCheck  | SrcIP     |
//      +-----------+-----------+
// +0x1C| SrcIP     | DstIp     |
//      +-----------+-----------+
// +0x20| DstIP     | SrcPort   | <-- IP Hdr (20)
//      +-----------+-----------+
// +0x24| DstPort   | Leng      |
//      +-----------+-----------+
// +0x28| Check     | Data      | <-- UDP Hdr (8)
//      +-----------+-----------+
// +0x2C| Data        Data      |
//      +-----------+-----------+
//        ... ...
// +0x  | Data        Data      |
//      +-----------+-----------+
int gen_udp_ip_eth_packet( uint8_t  *packet
                         , uint8_t   mac_dst[6] // network order
                         , uint8_t   mac_src[6] // network order
                         , int       pkt_type   // VLAN and/or HSR
                         , uint32_t  ip_src     // host order
                         , uint32_t  ip_dst     // host order
                         , uint16_t  port_src   // 0x0001; host order
                         , uint16_t  port_dst   // 0x0002; host order
                         , uint16_t  payload_len// UDP payload length
                         , uint8_t  *payload
                         )
{
    int leng;
    leng = populate_eth_hdr((eth_hdr_t*)packet, mac_dst, mac_src, ETH_TYPE_IP, pkt_type);
    leng += populate_ip_hdr((ip_hdr_t*)&packet[ETH_HDR_LEN], ip_src, ip_dst,
                    IP_PROTO_UDP, UDP_HDR_LEN+payload_len);
    leng += gen_udp_packet( &packet[ETH_HDR_LEN+IP_HDR_LEN],
                            port_src, port_dst, payload_len, payload);
    return leng;
    // It returns the number of bytes this routine touched; it returns the length of header when 'payload' is NULL.
}

//------------------------------------------------------------------------------
#ifndef COMPACT_CODE
int is_broadcast(uint32_t ip_addr, uint32_t ip_local, uint32_t subnet_mask)
{
    if (ip_addr==0xFFFFFFFF) return 1;
    else if (ip_addr==(ip_local|~subnet_mask)) return 1;
    else return 0;
}

int is_multicast(uint32_t ip_addr)
{
    if ((ip_addr>=0xE0000000)&&(ip_addr<=0xEFFFFFFF)) return 1;
    else return 0;
}

int is_outside(uint32_t ip_addr, uint32_t ip_local, uint32_t subnet_mask)
{
    if ((ip_addr&subnet_mask)==(ip_local&subnet_mask)) return 0;
    else return 1;
}
#endif

//------------------------------------------------------------------------------
//#ifndef COMPACT_CODE
int parser_eth_packet(uint8_t *pkt, int leng)
{
    return parser_eth_packet_core(pkt, leng, 4);
}
// level: 1 Ethernet
// level: 2 IP
// level: 3 UDP
// level: 4 HVDC
int parser_eth_packet_core(uint8_t *pkt, int leng, int level)
{
  int idx;
  uint16_t type_leng=0;
  if (level<=0) return 0;
  idx = 0;
  if (leng>=12) {
      int idy;
      printf("ETH mac dst  : 0x");
      for (idy=0; idy<6; idy++) printf("%02X",pkt[idx++]);
      printf("\n");
      printf("ETH mac src  : 0x");
      for (idy=0; idy<6; idy++) printf("%02X",pkt[idx++]);
      printf("\n");
  }
  if (leng>=(idx+2)) {
      type_leng  = pkt[idx++]<<8;
      type_leng |= pkt[idx++];
      printf("ETH type leng: 0x%04X", type_leng);
      switch (type_leng) {
      case 0x0800: printf(" (IPv4  packet)\n"); break;
      case 0x0806: printf(" (ARP   packet)\n"); break;
      case 0x0835: printf(" (RARP  packet)\n"); break;
      case 0x08DD: printf(" (IPv6  packet)\n"); break;
      case 0x8100: printf(" (VLAN  packet)\n"); level++; break;
      case 0x86DD: printf(" (IPv6  packet)\n"); break;
      case 0x8808: printf(" (Ethernet flow control)\n"); break;
      case 0x8892: printf(" (PROFINET protocol)\n"); break;
      case 0x88A4: printf(" (EtherCAT protocol)\n"); break;
      case 0x88CC: printf(" (LLDP  packet)\n"); break;
      case 0x88F7: printf(" (PTPv2 raw packet)\n"); break;
      case 0x88FB: printf(" (PRP   packet)\n"); break;
      case 0x892F: printf(" (HSR   packet)\n"); level++; break;
      default:     printf("\n"); break;
      }
   }

   if (--level>0) {
      switch (type_leng) {
      case 0x0800: return parser_ip_packet_core(pkt+ETH_HDR_LEN, leng-ETH_HDR_LEN, level); break;
      case 0x0806: return parser_arp_packet    (pkt+ETH_HDR_LEN, leng-ETH_HDR_LEN); break;
      case 0x08DD: printf(" (IPv6  packet)\n"); break;
      case 0x8100: level++; return parser_vlan_packet_core(pkt+12, leng-12, level); break;
      case 0x86DD: printf(" (IPv6  packet)\n"); break;
      case 0x8808: printf(" (Ethernet flow control)\n"); break;
      case 0x88CC: printf(" (LLDP  packet)\n"); break;
      case 0x88F7: printf(" (PTPv2 raw packet)\n"); break;
      case 0x88FB: printf(" (PRP   packet)\n"); break;
      case 0x892F: level++; return parser_hsr_packet_core(pkt+12, leng-12, level); break;
      default:     break;
      }
   }
   return 0;
}

//------------------------------------------------------------------------------
int parser_arp_packet(uint8_t *pkt, int leng)
{
    int idy;
    arp_hdr_t *arp_hdr = (arp_hdr_t*)pkt;
    printf("ARP HA      0x%04X\n", arp_hdr->arp_hrd); /* format of hardware address 1 */
    printf("ARP PRO     0x%04X\n", arp_hdr->arp_pro); /* format of protocol address 0x0800  */
    printf("ARP HA LEN  0x%02X\n", arp_hdr->arp_hln); /* length of hardware address 0x06  */
    printf("ARP PRO LEN 0x%02X\n", arp_hdr->arp_pln); /* length of protocol address 0x04  */
    printf("ARP CODE    0x%04X\n", arp_hdr->arp_opc); /* ARP opcode (command) 0:ARP_REQ, 1:ARP_RPY, 3:RARP_REQ, 4:       */
    printf("ARP SND MAC 0x"); for (idy=0; idy<6; idy++) printf("%02X", arp_hdr->arp_sha[idy]); printf("\n");
    printf("ARP SND IP  0x%08X\n", (unsigned int)arp_hdr->arp_sip); /* sender IP address       */
    printf("ARP TAR MAC 0x"); for (idy=0; idy<6; idy++) printf("%02X", arp_hdr->arp_tha[idy]); printf("\n");
    printf("ARP TAR IP  0x%08X\n", (unsigned int)arp_hdr->arp_tip); /* target IP address       */
    return 0;
}

//------------------------------------------------------------------------------
int parser_ip_packet(uint8_t *pkt, int leng)
{
    return parser_ip_packet_core(pkt, leng, 3);
}
// level: 1 IP
// level: 2 UDP
// level: 3 HVDC
int parser_ip_packet_core(uint8_t *pkt, int leng, int level)
{
    if (level<=0) return 0;
    ip_hdr_t *ip_hdr = (ip_hdr_t*)pkt;
    printf("IP header length         0x%01X\n",       ip_hdr->ip_hdl );
    printf("IP version               0x%01X\n",       ip_hdr->ip_ver );
    printf("IP type of service       0x%02X\n",       ip_hdr->ip_tos );
    printf("IP total length          0x%04X\n", ntohs(ip_hdr->ip_len));
    printf("IP identification        0x%04X\n", ntohs(ip_hdr->ip_id ));
    printf("IP fragment offset field 0x%04X\n", ntohs(ip_hdr->ip_off));
    printf("IP time to live          0x%02X\n",       ip_hdr->ip_ttl );
    printf("IP protocol              0x%02X  ",       ip_hdr->ip_pro );
    switch (ip_hdr->ip_pro) {
    case 0x11: printf("(UDP)\n"); break;
    case 0x06: printf("(TCP)\n"); break;
    case 0x01: printf("(ICMP)\n"); break;
    case 0x02: printf("(IGMP)\n"); break;
    case 0x5E: printf("(ICMP)\n"); break;
    default:   printf("\n"); break;
    }
    printf("IP checksum              0x%04X\n", ntohs(ip_hdr->ip_sum));
    printf("IP source address        0x%08X\n", (unsigned int)ntohl(ip_hdr->ip_src));
    printf("IP dest address          0x%08X\n", (unsigned int)ntohl(ip_hdr->ip_dst));

    switch (ip_hdr->ip_pro) {
    case 0x11: // UDP
         if (--level>0) return parser_udp_packet_core(pkt+(ip_hdr->ip_hdl*4), leng-(ip_hdr->ip_hdl*4), level);
         break;
    case 0x06: // TCP
    case 0x01: // ICMP
    case 0x02: // IGMP
    case 0x5E: // ICMP
    default: printf("not implemented yet\n");
    }
    return 0;
}

//------------------------------------------------------------------------------
int parser_udp_packet(uint8_t *pkt, int leng)
{
    return parser_udp_packet_core(pkt, leng, 2);
}
// level: 1 UDP
// level: 2 HVDC
int parser_udp_packet_core(uint8_t *pkt, int leng, int level)
{
    if (level<=0) return 0;
    udp_hdr_t *udp_hdr = (udp_hdr_t*)pkt;
    printf("UDP source port           0x%04X\n", ntohs(udp_hdr->udp_src));
    printf("UDP destination port      0x%04X\n", ntohs(udp_hdr->udp_dst));
    printf("UDP total length in bytes 0x%04X\n", ntohs(udp_hdr->udp_len));
    printf("UDP checksum              0x%04X\n", ntohs(udp_hdr->udp_sum));
    if (((ntohs(udp_hdr->udp_src)==0x13F)&&(ntohs(udp_hdr->udp_dst)==0x13F))||
        ((ntohs(udp_hdr->udp_src)==0x140)&&(ntohs(udp_hdr->udp_dst)==0x140))) {
         parser_ptp_packet(pkt+UDP_HDR_LEN, leng-UDP_HDR_LEN);
    }
    if ((--level>0)&&(ntohs(udp_hdr->udp_src)==0x1221)&&(ntohs(udp_hdr->udp_dst)==0x1221)) {
         return 0;
    }
    return 0;
}

//------------------------------------------------------------------------------
int parser_ptp_packet(uint8_t *pkt, int leng)
{
    return parser_ptp_packet_core(pkt, leng, 2);
}
int parser_ptp_packet_core(uint8_t *pkt, int leng, int level)
{
    if (level<=0) return 0;
    printf("PTPv2 messageType   0x%01X\n", pkt[0]&0x0F);
    printf("PTPv2 versionPTP    0x%01X\n", pkt[1]&0x0F);
    printf("PTPv2 messageLength 0x%02X\n", (pkt[2]<<8)|pkt[3]);
    return 0;
}

//------------------------------------------------------------------------------
// 0x8100,tag,...
int parser_vlan_packet_core(uint8_t *pkt, int leng, int level)
{
  int idx;
  uint16_t type_leng=0;
  if (level<=0) return 0;
  idx = 0;
  if (leng>=4) {
      printf("VLAN    : 0x%04X\n", ntohs(*(uint16_t*)pkt)); idx+=2;
      printf("VLAN tag: 0x%04X\n", ntohs(*(uint16_t*)&pkt[idx])); idx+=2;
  }
  if (leng>=(idx+2)) {
      type_leng  = pkt[idx++]<<8;
      type_leng |= pkt[idx++];
      printf("ETH type leng: 0x%04X", type_leng);
      switch (type_leng) {
      case 0x0800: printf(" (IPv4  packet)\n"); break;
      case 0x0806: printf(" (ARP   packet)\n"); break;
      case 0x0835: printf(" (RARP  packet)\n"); break;
      case 0x08DD: printf(" (IPv6  packet)\n"); break;
      case 0x8100: printf(" (VLAN  packet)\n"); level++; break;
      case 0x86DD: printf(" (IPv6  packet)\n"); break;
      case 0x8808: printf(" (Ethernet flow control)\n"); break;
      case 0x8892: printf(" (PROFINET protocol)\n"); break;
      case 0x88A4: printf(" (EtherCAT protocol)\n"); break;
      case 0x88CC: printf(" (LLDP  packet)\n"); break;
      case 0x88F7: printf(" (PTPv2 raw packet)\n"); break;
      case 0x88FB: printf(" (PRP   packet)\n"); break;
      case 0x892F: printf(" (HSR   packet)\n"); level++; break;
      default:     printf("\n"); break;
      }
   }

   if (--level>0) {
      switch (type_leng) {
      case 0x0800: return parser_ip_packet_core(pkt+ETH_HDR_LEN, leng-ETH_HDR_LEN, level); break;
      case 0x0806: return parser_arp_packet    (pkt+ETH_HDR_LEN, leng-ETH_HDR_LEN); break;
      case 0x08DD: printf(" (IPv6  packet)\n"); break;
      case 0x8100: level++; return parser_vlan_packet_core(pkt+12, leng-12, level); break;
      case 0x86DD: printf(" (IPv6  packet)\n"); break;
      case 0x8808: printf(" (Ethernet flow control)\n"); break;
      case 0x88CC: printf(" (LLDP  packet)\n"); break;
      case 0x88F7: printf(" (PTPv2 raw packet)\n"); break;
      case 0x88FB: printf(" (PRP   packet)\n"); break;
      case 0x892F: level++; return parser_hsr_packet_core(pkt+12, leng-12, level); break;
      default:     break;
      }
   }
   return 0;
}

//------------------------------------------------------------------------------
// 0x892F,siz,seq,...
int parser_hsr_packet_core(uint8_t *pkt, int leng, int level)
{
  int idx;
  uint16_t type_leng=0;
  uint16_t hsr=0;
  if (level<=0) return 0;
  idx = 0;
  if (leng>=6) {
      printf("HSR     : 0x%04X\n", ntohs(*(uint16_t*)pkt)); idx+=2;
      hsr =  ntohs(*(uint16_t*)&pkt[idx]);
      printf("HSR net : 0x%01X\n",  hsr>13);
      printf("HSR path: 0x%01X\n", (hsr>12)&0x1);
      printf("HSR size: 0x%04X\n", hsr&0xFF); idx+=2;
      printf("HSR seq : 0x%04X\n", ntohs(*(uint16_t*)&pkt[idx])); idx+=2;
  }
  if (leng>=(idx+2)) {
      type_leng  = pkt[idx++]<<8;
      type_leng |= pkt[idx++];
      printf("ETH type leng: 0x%04X", type_leng);
      switch (type_leng) {
      case 0x0800: printf(" (IPv4  packet)\n"); break;
      case 0x0806: printf(" (ARP   packet)\n"); break;
      case 0x0835: printf(" (RARP  packet)\n"); break;
      case 0x08DD: printf(" (IPv6  packet)\n"); break;
      case 0x8100: printf(" (VLAN  packet)\n"); level++; break;
      case 0x86DD: printf(" (IPv6  packet)\n"); break;
      case 0x8808: printf(" (Ethernet flow control)\n"); break;
      case 0x8892: printf(" (PROFINET protocol)\n"); break;
      case 0x88A4: printf(" (EtherCAT protocol)\n"); break;
      case 0x88CC: printf(" (LLDP  packet)\n"); break;
      case 0x88F7: printf(" (PTPv2 raw packet)\n"); break;
      case 0x88FB: printf(" (PRP   packet)\n"); break;
      case 0x892F: printf(" (HSR   packet)\n"); level++; break;
      default:     printf("\n"); break;
      }
   }

   if (--level>0) {
      switch (type_leng) {
      case 0x0800: return parser_ip_packet_core(pkt+ETH_HDR_LEN, leng-ETH_HDR_LEN, level); break;
      case 0x0806: return parser_arp_packet    (pkt+ETH_HDR_LEN, leng-ETH_HDR_LEN); break;
      case 0x08DD: printf(" (IPv6  packet)\n"); break;
      case 0x8100: level++; return parser_vlan_packet_core(pkt+12, leng-12, level); break;
      case 0x86DD: printf(" (IPv6  packet)\n"); break;
      case 0x8808: printf(" (Ethernet flow control)\n"); break;
      case 0x88CC: printf(" (LLDP  packet)\n"); break;
      case 0x88F7: printf(" (PTPv2 raw packet)\n"); break;
      case 0x88FB: printf(" (PRP   packet)\n"); break;
      case 0x892F: level++; return parser_hsr_packet_core(pkt+12, leng-12, level); break;
      default:     break;
      }
   }
  return 0;
}

//------------------------------------------------------------------------------
// Revision history:
//
// 2018.10.25: 'mac_dst/mac_src' order bug-fixed
// 2018.10.01: VLAN/HSR added.
// 2018.07.30: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
