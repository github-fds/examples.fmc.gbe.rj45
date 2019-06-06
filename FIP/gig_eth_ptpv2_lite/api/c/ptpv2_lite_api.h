#ifndef PTPV2_LITE_API_H
#define PTPV2_LITE_API_H
//--------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// ptpv2_lite_api.h
//--------------------------------------------------------------------
// VERSION = 2019.05.20.
//--------------------------------------------------------------------
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int ptpv2_lite_master( int master); // 1 for master
extern int ptpv2_lite_reset ( int rtc      // reset RTC when 1
                            , int tsu_tx   // reset TSU-TX when 1
                            , int tsu_rx );// reset TSU-RX when 1
extern int ptpv2_lite_enable( int rtc      // enable RTC when 1
                            , int tsu_tx   // enable TSU-TX when 1
                            , int tsu_rx );// enable TSU-RX when 1
extern int ptpv2_lite_ie( int rtc      // interrupt enable RTC when 1
                        , int tsu_tx   // interrupt enable TSU-TX when 1
                        , int tsu_rx );// interrupt enable TSU-RX when 1
extern int ptpv2_lite_get_ip( int *rtc
                            , int *tsu_tx
                            , int *tsu_rx);
extern int ptpv2_lite_clr_ip( int rtc // clear interrupt pending when 1
                            , int tsu_tx
                            , int tsu_rx);
extern int ptpv2_lite_set_mac_addr( uint8_t mac[6]); // mac[0] will be MSB
extern int ptpv2_lite_get_mac_addr( uint8_t mac[6]); // mac[0] will be MSB
extern int ptpv2_lite_set_ptp_id( uint8_t  clock_id[8] // [0] will be MSB
                                , uint16_t port_id);
extern int ptpv2_lite_get_ptp_id( uint8_t   clock_id[8] // [0] will be MSB
                                , uint16_t *port_id);
extern int ptpv2_lite_get_tod( uint16_t *sec_msb
                             , uint32_t *sec_lsb
                             , uint32_t *nano );
extern int ptpv2_lite_set_tod( uint16_t sec_msb
                             , uint32_t sec_lsb
                             , uint32_t nano);
// ptpv2_lite_adj_tod() should be called when RTC is enabled.
extern int ptpv2_lite_adj_tod( uint8_t  dec // 0(ADD), 1(SUB)
                             , uint8_t  sec
                             , uint32_t nano);
extern int ptpv2_lite_set_inc( uint8_t  nano
                             , uint32_t nano_frac);
// ptpv2_lite_adj_inc() should be called when RTC is enabled.
extern int ptpv2_lite_adj_inc( uint8_t   dec // 0(ADD), 1(SUB)
                             , uint8_t   nano
                             , uint32_t  nano_frac);
extern int ptpv2_lite_get_inc( uint8_t  *nano
                             , uint32_t *nano_frac);
extern int ptpv2_fifo_clr( uint8_t  tsu_tx
                         , uint8_t  tsu_rx);
extern int ptpv2_fifo_status( uint8_t *tsu_tx
                            , uint8_t *tsu_rx);
extern int ptpv2_fifo_tx_pop_nb( uint8_t  *mode
                               , uint8_t  *type
                               , uint16_t *seq_id
                               , uint32_t *nsec
                               , uint16_t *sec_msb // higher 16-bit
                               , uint32_t *sec_lsb // lower 32-bit
                               , int       timeout);
#define ptpv2_fifo_tx_pop_b(mode,type,seq_id,nsec,sec_msb,sec_lsb)\
        ptpv2_fifo_tx_pop_nb((mode),(type),(seq_id),(nsec,sec_msb),(sec_lsb),0)
extern int ptpv2_fifo_rx_pop_nb( uint8_t  *mode
                               , uint8_t  *type
                               , uint16_t *seq_id
                               , uint32_t *nsec
                               , uint16_t *sec_msb // higher 16-bit
                               , uint32_t *sec_lsb // lower 32-bit
                               , int       timeout);
#define ptpv2_fifo_rx_pop_b(mode,type,seq_id,nsec,sec_msb,sec_lsb)\
        ptpv2_fifo_rx_pop_nb((mode),(type),(seq_id),(nsec),(sec_msb),(sec_lsb),0)
extern int ptpv2_timer( int enable // 
                      , uint32_t usec); // use previous value when 0
extern int ptpv2_add( uint8_t   Aneg // negative when 1
                    , uint16_t  Asec_msb // absolute value
                    , uint32_t  Asec_lsb // absolute value
                    , uint32_t  Ansec // absolute value
                    , uint8_t   Bneg // negative when 1
                    , uint16_t  Bsec_msb // absolute value
                    , uint32_t  Bsec_lsb // absolute value
                    , uint32_t  Bnsec // absolute value
                    , uint8_t  *Cover // overflow when 1
                    , uint8_t  *Cneg // negative when 1
                    , uint16_t *Csec_msb // absolute value
                    , uint32_t *Csec_lsb // absolute value
                    , uint32_t *Cnsec); // absolute value
extern int ptpv2_sub( uint8_t   Aneg
                    , uint16_t  Asec_msb // absolute value
                    , uint32_t  Asec_lsb // absolute value
                    , uint32_t  Ansec // absolute value
                    , uint8_t   Bneg // negative when 1
                    , uint16_t  Bsec_msb // absolute value
                    , uint32_t  Bsec_lsb // absolute value
                    , uint32_t  Bnsec // absolute value
                    , uint8_t  *Cover // overflow when 1
                    , uint8_t  *Cneg // negative when 1
                    , uint16_t *Csec_msb // absolute value
                    , uint32_t *Csec_lsb // absolute value
                    , uint32_t *Cnsec); // absolute value

#ifndef COMPACT_CODE
extern int ptp_csr_check ();
#endif

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2019.05.20: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif
