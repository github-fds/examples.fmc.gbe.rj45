#ifndef ETH_IP_UDP_H
#define ETH_IP_UDP_H
//----------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//----------------------------------------------------------------------------
// VERSION = 2018.10.01.
//----------------------------------------------------------------------------
#include "eth_ip_udp_data_type.h"

//----------------------------------------------------------------------------
#ifndef COMPACT_CODE
extern uint32_t compute_eth_crc(uint8_t *pkt, uint32_t bnum);
#endif
extern uint16_t compute_ip_checksum( ip_hdr_t* iphdr );

//----------------------------------------------------------------------------
// It fills Ethernet header and returns header length.
extern int populate_eth_hdr( eth_hdr_t *hdr
                           , uint8_t    mac_dst[6] // network order
                           , uint8_t    mac_src[6] // network order
                           , uint16_t   type_leng  // host order
                           , int        pkt_type); // VLAN and/or HSR
// It fills IP header and returns header length.
extern int populate_ip_hdr( ip_hdr_t *hdr
                          , uint32_t  ip_src    // host order
                          , uint32_t  ip_dst    // host order
                          , uint8_t   protocol
                          , uint16_t  payload_len);// pure payload size in host order
// It fills UDP header and returns header length.
extern int populate_udp_hdr( udp_hdr_t *hdr
                           , uint16_t   port_src    // host order
                           , uint16_t   port_dst    // host order
                           , uint16_t   payload_len); // pure payload size in host order

//----------------------------------------------------------------------------
// It fills raw Ethernet packet and returns length.
extern int gen_eth_packet( uint8_t  *packet
                         , uint8_t   mac_dst[6] // network order
                         , uint8_t   mac_src[6] // network order
                         , int       pkt_type   // VLAN and/or HSR
                         , uint16_t  type_leng  // host order
                         , uint16_t  payload_len// payload length
                         , uint8_t  *payload);  // payload if not 0
// It fills IP packet and returns length.
extern int gen_ip_packet( uint8_t  *packet
                        , uint32_t  ip_src     // host order
                        , uint32_t  ip_dst     // host order
                        , uint8_t   protocol   //
                        , uint16_t  payload_len// IP payload length
                        , uint8_t  *payload);  // payload if not 0
// It fills UDP packet and returns length
extern int gen_udp_packet( uint8_t  *packet
                         , uint16_t  port_src   // host order
                         , uint16_t  port_dst   // host order
                         , uint16_t  payload_len// UDP payload length
                         , uint8_t  *payload); // payload if not 0

//----------------------------------------------------------------------------
// It fills IP/Ethernet packet and returns length.
extern int gen_ip_eth_packet( uint8_t  *packet
                            , uint8_t   mac_dst[6] // network order
                            , uint8_t   mac_src[6] // network order
                            , int       pkt_type   // VLAN and/or HSR
                            , uint32_t  ip_src     // host order
                            , uint32_t  ip_dst     // host order
                            , uint8_t   protocol   //
                            , uint16_t  payload_len// IP payload length
                            , uint8_t  *payload);  // IP payload if not 0
// It fills UDP/IP/Ethernet packet and returns length.
extern int gen_udp_ip_eth_packet( uint8_t  *packet
                                , uint8_t   mac_dst[6] // network order
                                , uint8_t   mac_src[6] // network order
                                , int       pkt_type   // VLAN and/or HSR
                                , uint32_t  ip_src     // host order
                                , uint32_t  ip_dst     // host order
                                , uint16_t  port_src   // host order
                                , uint16_t  port_dst   // host order
                                , uint16_t  payload_len// UDP payload length
                                , uint8_t  *payload);  // UDP payload if not 0

//----------------------------------------------------------------------------
#ifndef COMPACT_CODE
extern int is_broadcast(uint32_t ip_addr, uint32_t ip_local, uint32_t subnet_mask);
extern int is_multicast(uint32_t ip_addr);
extern int is_outside(uint32_t ip_addr, uint32_t ip_local, uint32_t subnet_mask);
#endif
//#ifndef COMPACT_CODE
extern int parser_eth_packet_core (uint8_t *pkt, int leng, int level);
extern int parser_ip_packet_core  (uint8_t *pkt, int leng, int level);
extern int parser_udp_packet_core (uint8_t *pkt, int leng, int level);
extern int parser_ptp_packet_core (uint8_t *pkt, int leng, int level);
extern int parser_eth_packet (uint8_t *pkt, int leng);
extern int parser_arp_packet (uint8_t *pkt, int leng);
extern int parser_ip_packet  (uint8_t *pkt, int leng);
extern int parser_udp_packet (uint8_t *pkt, int leng);
extern int parser_ptp_packet (uint8_t *pkt, int leng);
extern int parser_vlan_packet_core (uint8_t *pkt, int leng, int level);
extern int parser_hsr_packet_core  (uint8_t *pkt, int leng, int level);
//#endif

//-----------------------------------------------------------------------------
// Revision history:
//
// 2018.10.01: VLAN/HSR added.
// 2018.07.30: Started by Ando Ki (adki@future-ds.com)
//----------------------------------------------------------------------------
#endif /*DP_IP_H_*/
