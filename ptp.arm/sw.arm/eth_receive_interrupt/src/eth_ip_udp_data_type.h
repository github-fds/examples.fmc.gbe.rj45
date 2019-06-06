#ifndef ETH_IP_UDP_DATA_TYPES_H
#define ETH_IP_UDP_DATA_TYPES_H
//----------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//----------------------------------------------------------------------------
// VERSION = 2018.10.01.
//----------------------------------------------------------------------------

//#include <sys/types.h>
//#include <arpa/inet.h>
//#include <pthread.h>
//#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

#define htons(n) (uint16_t)( (((uint16_t) (n)) << 8)\
		            |(((uint16_t) (n)) >> 8))
#define ntohs(n) htons(n)
#define htonl(n) (uint32_t)( (((uint32_t)(n)&0xFF)<<24)\
                            |(((uint32_t)(n)&0xFF00)<<8)\
                            |(((uint32_t)(n)&0xFF0000)>>8)\
                            |(((uint32_t)(n)&0xFF000000)>>24))
#define ntohl(n) htonl(n)

/** ETHERNET HEADER STRUCTURE **/
#define ETH_ADDR_LEN  6
#define ETH_HDR_LEN   14
typedef union eth_hdr
{
    struct {
       uint8_t  eth_dhost[ETH_ADDR_LEN];    /* destination ethernet address, i.e. mac_dst */
       uint8_t  eth_shost[ETH_ADDR_LEN];    /* source ethernet address, i.e. mac_src */
       uint16_t eth_type;                   /* packet type ID */
    } __attribute__((packed)) normal;
    struct {
       uint8_t  eth_dhost[ETH_ADDR_LEN];    /* destination ethernet address, i.e. mac_dst */
       uint8_t  eth_shost[ETH_ADDR_LEN];    /* source ethernet address, i.e. mac_src */
       uint16_t vlan_type;                  /* packet type ID: 0x8100 */
       uint16_t vlan_tag;                   /* packet tag: priority(3).CFI(1).ID(12) */
       uint16_t eth_type;                   /* packet type ID */
    } __attribute__((packed)) vlan;
    struct {
       uint8_t  eth_dhost[ETH_ADDR_LEN];    /* destination ethernet address, i.e. mac_dst */
       uint8_t  eth_shost[ETH_ADDR_LEN];    /* source ethernet address, i.e. mac_src */
       uint16_t hsr_type;                   /* packet type ID: 0x892F */
       uint16_t hsr_size;                   /* packet size: netid(3).path(1).size(12) */
       uint16_t hsr_seq;                    /* packet seq */
       uint16_t eth_type;                   /* packet type ID */
    } __attribute__((packed)) hsr;
    struct {
       uint8_t  eth_dhost[ETH_ADDR_LEN];    /* destination ethernet address, i.e. mac_dst */
       uint8_t  eth_shost[ETH_ADDR_LEN];    /* source ethernet address, i.e. mac_src */
       uint16_t vlan_type;                  /* packet type ID: 0x8100 */
       uint16_t vlan_tag;                   /* packet tag: priority(3).CFI(1).ID(12) */
       uint16_t hsr_type;                   /* packet type ID: 0x892F */
       uint16_t hsr_size;                   /* packet size: netid(3).path(1).size(12) */
       uint16_t hsr_seq;                    /* packet seq */
       uint16_t eth_type;                   /* packet type ID */
    } __attribute__((packed)) vlan_hsr;
} eth_hdr_t;

/** DEFINES FOR Packet Type (pkt_type) of VLAN and/or HSR **/
#define PKT_TYPE_BROADCAST 0x01 // bit-filed definition
#define PKT_TYPE_VLAN      0x02 // bit-filed definition
#define PKT_TYPE_HSR       0x04 // bit-filed definition

/** DEFINES FOR ETHERNET **/
#define ETH_TYPE_ARP  0x0806  /* Addr. resolution protocol */
#define ETH_TYPE_IP   0x0800  /* IP protocol */
#define ETH_TYPE_VLAN 0x8100  /* VLAN */
#define ETH_TYPE_HSR  0x892F  /* HSR High-availability Seamless Redundancy */
#define ETH_TYPE_PTP  0x88F7  /* PTP IEEE1588 Precision Time Protocol */
#define ETH_TYPE_PRP  0x88F7  /* PRP Parallel Redundancy Protocol */

/** ARP HEADER STRUCTURE **/
typedef struct arp_hdr
{
    uint16_t  arp_hrd; /* format of hardware address   */
    uint16_t  arp_pro; /* format of protocol address   */
    uint8_t   arp_hln; /* length of hardware address   */
    uint8_t   arp_pln; /* length of protocol address   */
    uint16_t  arp_opc; /* ARP opcode (command)         */
    uint8_t   arp_sha[ETH_ADDR_LEN];/* sender hardware address */
    uint32_t  arp_sip;              /* sender IP address       */
    uint8_t   arp_tha[ETH_ADDR_LEN];/* target hardware address */
    uint32_t  arp_tip;              /* target IP address       */
} __attribute__ ((packed)) arp_hdr_t;

/** DEFINES FOR ARP **/
#define ARP_HRD_ETHERNET    0x0001
#define ARP_PRO_IP          0x0800
#define ARP_OP_REQUEST      1
#define ARP_OP_REPLY        2

/** IP HEADER STRUCTURE **/
#define IP_ADDR_LEN 4
#define IP_HDR_LEN 20
typedef struct ip_hdr
{
    uint8_t  ip_hdl:4; /* header length */
    uint8_t  ip_ver:4; /* version */
    uint8_t  ip_tos;   /* type of service */
    uint16_t ip_len;   /* total length */
    uint16_t ip_id;    /* identification */
    uint16_t ip_off;   /* fragment offset field */
    uint8_t  ip_ttl;   /* time to live */
    uint8_t  ip_pro;   /* protocol */
    uint16_t ip_sum;   /* checksum */
    uint32_t ip_src;   /* source address */
    uint32_t ip_dst;   /* dest address */
} __attribute__ ((packed)) ip_hdr_t;

/** UDP HEADER STRUCTURE **/
#define UDP_HDR_LEN 8
typedef struct udp_hdr
{
    uint16_t udp_src; // source port
    uint16_t udp_dst; // destination port
    uint16_t udp_len; // total length in bytes
    uint16_t udp_sum; // checksum
} __attribute__ ((packed)) udp_hdr_t;

/** DEFINES FOR IP **/
#define IP_PROTO_ICMP      0x01  // ICMP protocol
#define IP_PROTO_TCP       0x06  // TCP protocol
#define IP_PROTO_UDP       0x11  // UDP protocol
#define IP_PROTO_PWOSPF    0x59  // PWOSPF protocol
#define IP_FRAG_RF         0x8000  // reserved fragment flag
#define IP_FRAG_DF         0x4000  // dont fragment flag
#define IP_FRAG_MF         0x2000  // more fragments flag
#define IP_FRAG_OFFMASK    0x1fff  // mask for fragmenting bits

/** ICMP HEADER STRUCTURE **/
typedef struct icmp_hdr
{
    uint8_t  icmp_type;
    uint8_t  icmp_code;
    uint16_t icmp_sum;
} __attribute__ ((packed)) icmp_hdr_t;

/** DEFINES FOR ICMP **/
#define ICMP_TYPE_DESTINATION_UNREACHABLE  0x3
#define ICMP_CODE_NET_UNREACHABLE          0x0
#define ICMP_CODE_HOST_UNREACHABLE         0x1
#define ICMP_CODE_PROTOCOL_UNREACHABLE     0x2
#define ICMP_CODE_PORT_UNREACHABLE         0x3
#define ICMP_CODE_NET_UNKNOWN              0x6

#define ICMP_TYPE_TIME_EXCEEDED            0xB
#define ICMP_CODE_TTL_EXCEEDED             0x0

#define ICMP_TYPE_ECHO_REQUEST             0x8
#define ICMP_TYPE_ECHO_REPLY               0x0
#define ICMP_CODE_ECHO                     0x0

#ifdef __cplusplus
}
#endif

//-----------------------------------------------------------------------------
// Revision history:
//
// 2018.10.01: Added more EtherTypes: VLAN/HSR
// 2018.07.30: Started by Ando Ki (adki@future-ds.com)
//----------------------------------------------------------------------------
#endif /*OR_DATA_TYPES_H_*/
