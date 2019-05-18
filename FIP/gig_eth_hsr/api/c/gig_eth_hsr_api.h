#ifndef GIG_ETH_HSR_API_H
#define GIG_ETH_HSR_API_H
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// gig_eth_hsr_api.h
//------------------------------------------------------------------------------
// VERSION = 2018.10.17.
//------------------------------------------------------------------------------
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int gig_eth_hsr_set_mac_addr( uint8_t mac[6] );
extern int gig_eth_hsr_get_mac_addr( uint8_t mac[6] );
extern int gig_eth_hsr_set_control( uint8_t snoop // 3
                                  , uint8_t enable_qr    // 2
                                  , uint8_t drop_non_hsr // 1
                                  , uint8_t promiscuous // 0
                                  );
extern int gig_eth_hsr_get_control( uint8_t *hsr_type  // 31
                                  , uint8_t *hsr_perf  // 30
                                  , uint8_t *hsr_snoop // 3
                                  , uint8_t *hsr_enable_qr    // 2
                                  , uint8_t *hsr_drop_non_hsr // 1
                                  , uint8_t *hsr_promiscuous  // 0
                                  );
extern int gig_eth_hsr_ready(void);

#ifndef COMPACT_CODE
extern void gig_eth_hsr_csr_check ( void );
#endif

#ifdef __cplusplus
}
#endif
//------------------------------------------------------------------------------
// Revision History
//
// 2018.07.05: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
#endif
