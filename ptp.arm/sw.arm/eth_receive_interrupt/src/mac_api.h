#ifndef MAC_H
#define MAC_H
//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 by Future Design Systems.
// All right reserved.
// http://www.future-ds.com
//------------------------------------------------------------------------------
/// @file mac_api.h
/// @brief This header file contains function prototypes for Gigabit MAC.
/// @author Ando Ki
/// @data 05/20/2019
//------------------------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

#define ETHERNET_DEC_SEND     1
#define ETHERNET_DEC_RECEIVE  2
#define ETHERNET_DEC_RAS      3
#define ETHERNET_DEC_SAR      4 // loopback

extern int eth_send_packet( uint8_t  mac_dst[6]
                          , uint8_t  mac_src[6]
                          , uint8_t  pkt_type
                          , uint16_t bnum
                          , int      timeout
                          , unsigned int      verbose);
extern int eth_send_packets( uint8_t  mac_dst[6]
                           , uint8_t  mac_src[6]
                           , uint8_t  pkt_type
                           , unsigned int      verbose
                           , int      inter_mode
                           , uint16_t bnum_start);
extern int eth_receive_packet( int timeout
                             , unsigned int verbose );
extern int eth_receive_packets( unsigned int verbose
                              , int inter_mode );
extern int eth_receive_after_send( uint8_t mac_dst[6]
                                 , uint8_t mac_src[6]
                                 , uint8_t pkt_type
                                 , unsigned int     verbose
                                 , int     inter_mode   );
extern int eth_send_after_receive( unsigned int verbose );

extern int mac_init( uint8_t  mac_addr[6]
                   , uint8_t  conf_tx_jumbo_en
                   , uint8_t  conf_tx_no_gen_crc
                   , uint16_t conf_tx_bchunk
                   , uint8_t  conf_rx_jumbo_en
                   , uint8_t  conf_rx_no_chk_crc
                   , uint8_t  conf_rx_promiscuous
                   , uint16_t conf_rx_bchunk
                   , uint32_t buff_tx_start
                   , uint32_t buff_tx_size
                   , uint32_t buff_rx_start
                   , uint32_t buff_rx_size
                   , unsigned int      verbose);

#if defined(GIG_ETH_HSR)
extern int hsr_init( uint8_t mac_addr[6]
                   , uint8_t promiscuous
                   , uint8_t drop_non_hsr
                   , uint8_t enable_qr
                   , uint8_t snoop
                   , unsigned int     verbose);
#endif

extern int phy_init( uint32_t phyaddr );
extern int phy_init_rtl8211( uint32_t phyaddr );
extern int phy_init_88e1111( uint32_t phyaddr );

#ifdef __cplusplus
}
#endif
//------------------------------------------------------------------------------
// Revision history
//
// 2019.05.20: 'verbose': int --> unsigned int
// 2018.10.04: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
#endif //MAC_H
