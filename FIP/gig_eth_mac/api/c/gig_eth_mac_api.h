#ifndef GIG_ETH_MAC_API_H
#define GIG_ETH_MAC_API_H
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// gig_eth_mac_api.h
//------------------------------------------------------------------------------
// VERSION = 2018.10.17.
//------------------------------------------------------------------------------
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int gig_eth_mac_send( uint8_t  *addr
                           , uint16_t  blen // num of byte: dst-src-payload
                           , int       time_out); // 0=blocking
extern int gig_eth_mac_receive( uint8_t  *addr
                              , uint16_t  bnum // num of byte: dst-src-payload
                              , int       time_out); // 0=blocking
extern int gig_eth_mac_interrupt( int enable ); // <0:disable, 0:read, >0:enable
extern int gig_eth_mac_check_ip( uint8_t *pt );
extern int gig_eth_mac_clear_ip( void );
extern int gig_eth_mac_peek_descriptor_tx( uint16_t *rooms );
extern int gig_eth_mac_push_descriptor_tx( uint32_t  ptr
                                         , uint16_t  bnum
                                         , int       time_out);
extern int gig_eth_mac_peek_descriptor_rx( uint16_t *items
                                         , uint16_t *bnum  );
extern int gig_eth_mac_pop_descriptor_rx ( uint32_t *ptr
                                         , uint16_t *bnum
                                         , int       time_out);
extern int gig_eth_mac_set_mac_addr( uint8_t mac[6] );
extern int gig_eth_mac_get_mac_addr( uint8_t mac[6] );
extern int gig_eth_mac_set_frame_buffer_tx( uint32_t  start
                                          , uint32_t  end );
extern int gig_eth_mac_get_frame_buffer_tx( uint32_t *start
                                          , uint32_t *end
                                          , uint32_t *head
                                          , uint32_t *tail );
extern int gig_eth_mac_set_frame_buffer_rx( uint32_t  start
                                          , uint32_t  end );
extern int gig_eth_mac_get_frame_buffer_rx( uint32_t *start
                                          , uint32_t *end
                                          , uint32_t *head
                                          , uint32_t *tail );
extern int gig_eth_mac_set_config( uint8_t   conf_tx_jumbo_en
                                 , uint8_t   conf_tx_no_gen_crc
                                 , uint16_t  conf_tx_bchunk
                                 , uint8_t   conf_rx_jumbo_en
                                 , uint8_t   conf_rx_no_chk_crc
                                 , uint8_t   conf_rx_promiscuous
                                 , uint16_t  conf_rx_bchunk );
extern int gig_eth_mac_get_config( uint8_t  *conf_tx_reset
                                 , uint8_t  *conf_tx_en
                                 , uint8_t  *conf_tx_jumbo_en
                                 , uint8_t  *conf_tx_no_gen_crc
                                 , uint16_t *conf_tx_bchunk
                                 , uint8_t  *conf_rx_reset
                                 , uint8_t  *conf_rx_en
                                 , uint8_t  *conf_rx_jumbo_en
                                 , uint8_t  *conf_rx_no_chk_crc
                                 , uint8_t  *conf_rx_promiscuous
                                 , uint16_t *conf_rx_bchunk );
extern int gig_eth_mac_tx_enable( uint8_t tx_reset
                                , uint8_t tx_enable );
extern int gig_eth_mac_rx_enable( uint8_t rx_reset
                                , uint8_t rx_enable );
extern int gig_eth_phy_reset( uint8_t phy_reset
                            , int     wait );
extern int gig_eth_mac_rgmii( void );
extern int gig_eth_mac_ready( void );

#ifndef COMPACT_CODE
extern void gig_eth_mac_csr_check ( void );
#endif

#ifdef __cplusplus
}
#endif
//------------------------------------------------------------------------------
// Revision History
//
// 2018.10.17: updated.
// 2018.07.20: 'gig_eth_phy_rgmii()' added.
// 2018.07.05: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
#endif
