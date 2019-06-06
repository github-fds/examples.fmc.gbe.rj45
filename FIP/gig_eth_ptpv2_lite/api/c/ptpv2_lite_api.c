//--------------------------------------------------------------------
// Copyright (c) 2019 Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// ptpv2_lite_api.c
//--------------------------------------------------------------------
// VERSION = 2019.05.20.
//--------------------------------------------------------------------
//#ifndef COMPACT_CODE
//#endif
//--------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "defines_system.h"
#include "ptpv2_lite_api.h"
//#include "memory_map.h"

//--------------------------------------------------------------------
// Register access macros
#ifdef TRX_BFM
#   define REGRD(A,B)         BfmRead((unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define REGWR(A,B)         BfmWrite((unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define MEM_WRITE_N(A,B,N) BfmWrite((unsigned int)(A), (unsigned int*)(B), 4, (N))
#   define MEM_READ_N(A,B,N)  BfmRead ((unsigned int)(A), (unsigned int*)(B), 4, (N))
#else
#   define REGRD(A,V)           (V) = *((volatile uint32_t *)(A))
#   define REGWR(A,V)           *((volatile uint32_t *)(A)) = (V)
#   define REGRDB(A,P,L)        memcpy((void*)(P), (void*)(A), 4*(L))
#   define REGWRB(A,P,L)        memcpy((void*)(A), (void*)(P), 4*(L))
#endif
//--------------------------------------------------------------------
#define PTPV2_MASTER_VERSION   0x20150106

#if !defined(ADDR_GBE_PTP_START)
#define ADDR_GBE_PTP_START 0x4C040000
#endif

#define CSRA_NAME0           (ADDR_GBE_PTP_START+0x00) 
#define CSRA_NAME1           (ADDR_GBE_PTP_START+0x04) 
#define CSRA_NAME2           (ADDR_GBE_PTP_START+0x08) 
#define CSRA_NAME3           (ADDR_GBE_PTP_START+0x0C) 
#define CSRA_COMP0           (ADDR_GBE_PTP_START+0x10) 
#define CSRA_COMP1           (ADDR_GBE_PTP_START+0x14) 
#define CSRA_COMP2           (ADDR_GBE_PTP_START+0x18) 
#define CSRA_COMP3           (ADDR_GBE_PTP_START+0x1C) 
#define CSRA_VERSION         (ADDR_GBE_PTP_START+0x20) 
#define CSRA_CONTROL         (ADDR_GBE_PTP_START+0x30) 
#define CSRA_STATUS          (ADDR_GBE_PTP_START+0x34) 
#define CSRA_LD_NS           (ADDR_GBE_PTP_START+0x40) // load RTC TOD
#define CSRA_LD_SEC_LSB      (ADDR_GBE_PTP_START+0x44) // load RTC TOD
#define CSRA_LD_SEC_MSB      (ADDR_GBE_PTP_START+0x48) // load RTC TOD
#define CSRA_ADJ_NS          (ADDR_GBE_PTP_START+0x4C) // adjust RTC TOD
#define CSRA_ADJ_SEC         (ADDR_GBE_PTP_START+0x50) // adjust RTC TOD
#define CSRA_INC_LD_FRAC     (ADDR_GBE_PTP_START+0x54) // load or adjust RTC TOD INC
#define CSRA_INC_LD_NS       (ADDR_GBE_PTP_START+0x58) // load or adjust RTC TOD INC
#define CSRA_INC_ADJ_FRAC    (ADDR_GBE_PTP_START+0x5C) // load or adjust RTC TOD INC
#define CSRA_INC_ADJ_NS      (ADDR_GBE_PTP_START+0x60) // load or adjust RTC TOD INC
#define CSRA_TOD_RD_NS       (ADDR_GBE_PTP_START+0x64) // RTC TOD (read-only)
#define CSRA_TOD_RD_SEC_LSB  (ADDR_GBE_PTP_START+0x68) // RTC TOD (read-only)
#define CSRA_TOD_RD_SEC_MSB  (ADDR_GBE_PTP_START+0x6C) // RTC TOD (read-only)
#define CSRA_TIMER           (ADDR_GBE_PTP_START+0x70) // periodic timer setting
#define CSRA_TSU_TX_ID       (ADDR_GBE_PTP_START+0x74) // TSU-TX fifo
#define CSRA_TSU_TX_NS       (ADDR_GBE_PTP_START+0x78) // TSU-TX fifo
#define CSRA_TSU_TX_SEC_LSB  (ADDR_GBE_PTP_START+0x7C) // TSU-TX fifo
#define CSRA_TSU_TX_SEC_MSB  (ADDR_GBE_PTP_START+0x80) // TSU-TX fifo
#define CSRA_TSU_RX_ID       (ADDR_GBE_PTP_START+0x84) // TSU-RX fifo
#define CSRA_TSU_RX_NS       (ADDR_GBE_PTP_START+0x88) // TSU-RX fifo
#define CSRA_TSU_RX_SEC_LSB  (ADDR_GBE_PTP_START+0x8C) // TSU-RX fifo
#define CSRA_TSU_RX_SEC_MSB  (ADDR_GBE_PTP_START+0x90) // TSU-RX fifo
#define CSRA_MAC_ADDR_LSB    (ADDR_GBE_PTP_START+0x94) 
#define CSRA_MAC_ADDR_MSB    (ADDR_GBE_PTP_START+0x98) 
#define CSRA_CLOCK_ID_LSB    (ADDR_GBE_PTP_START+0x9C) 
#define CSRA_CLOCK_ID_MSB    (ADDR_GBE_PTP_START+0xA0) 
#define CSRA_PORT_ID         (ADDR_GBE_PTP_START+0xA4) 
#define CSRA_OPA_NSEC        (ADDR_GBE_PTP_START+0xB0)
#define CSRA_OPA_SEC_LSB     (ADDR_GBE_PTP_START+0xB4)
#define CSRA_OPA_SEC_MSB     (ADDR_GBE_PTP_START+0xB8)
#define CSRA_OPB_NSEC        (ADDR_GBE_PTP_START+0xC0)
#define CSRA_OPB_SEC_LSB     (ADDR_GBE_PTP_START+0xC4)
#define CSRA_OPB_SEC_MSB     (ADDR_GBE_PTP_START+0xC8)
#define CSRA_RESULT_NSEC     (ADDR_GBE_PTP_START+0xD0)
#define CSRA_RESULT_SEC_LSB  (ADDR_GBE_PTP_START+0xD4)
#define CSRA_RESULT_SEC_MSB  (ADDR_GBE_PTP_START+0xD8)

//--------------------------------------------------------------------
// bit position
#define PTP_ctl_tsu_tx_en         0
#define PTP_ctl_tsu_tx_rst        1
#define PTP_ctl_tsu_tx_ie         2
#define PTP_ctl_tsu_rx_en         8
#define PTP_ctl_tsu_rx_rst        9
#define PTP_ctl_tsu_rx_ie         10
#define PTP_ctl_rtc_en            16
#define PTP_ctl_rtc_rst           17
#define PTP_ctl_rtc_ie            18
#define PTP_ctl_master            31

#define PTP_stu_tsu_tx_ip         0
#define PTP_stu_tsu_rx_ip         8
#define PTP_stu_rtc_ip            16

#define PTP_ld_ns                 0
#define PTP_ld_sec_lsb            0
#define PTP_ld_sec_msb            0
#define PTP_ld_wr                 31

#define PTP_adj_ns                0
#define PTP_adj_dec               30
#define PTP_adj_wr                31

#define PTP_inc_fns               0
#define PTP_inc_ns                0
#define PTP_inc_wr                31

#define PTP_inc_adj_fns           0
#define PTP_inc_adj_ns            0
#define PTP_inc_adj_dec           30
#define PTP_inc_adj_wr            31

#define PTP_tod_ns                0
#define PTP_tod_sec_lsb           0
#define PTP_tod_sec_msb           0
#define PTP_tod_sec_vld           30
#define PTP_tod_sec_req           31

#define PTP_timer_usec            0
#define PTP_timer_mode            30
#define PTP_timer_en              31

#define PTP_tsu_tx_seq_id         0
#define PTP_tsu_tx_type           16
#define PTP_tsu_tx_mode           20
#define PTP_tsu_tx_valid          21
#define PTP_tsu_tx_full           22
#define PTP_tsu_tx_clr            23
#define PTP_tsu_tx_rd             31
#define PTP_tsu_tx_ns             0
#define PTP_tsu_tx_sec_lsb        0
#define PTP_tsu_tx_sec_msb        0

#define PTP_tsu_rx_seq_id         0
#define PTP_tsu_rx_type           16
#define PTP_tsu_rx_mode           20
#define PTP_tsu_rx_valid          21
#define PTP_tsu_rx_full           22
#define PTP_tsu_rx_clr            23
#define PTP_tsu_rx_rd             31
#define PTP_tsu_rx_ns             0
#define PTP_tsu_rx_sec_lsb        0
#define PTP_tsu_rx_sec_msb        0

#define PTP_mac_lsb               0
#define PTP_mac_msb               0

#define PTP_opa_neg               16
#define PTP_opa_nsec              0
#define PTP_opa_sec               0
#define PTP_opb_neg               16
#define PTP_opb_nsec              0
#define PTP_opb_sec               0
#define PTP_result_over           17
#define PTP_result_neg            16
#define PTP_result_nsec           0
#define PTP_result_sec            0

//--------------------------------------------------------------------
// bit mask
#define PTP_ctl_tsu_tx_en_MSK     (1<<PTP_ctl_tsu_tx_en       )
#define PTP_ctl_tsu_tx_rst_MSK    (1<<PTP_ctl_tsu_tx_rst      )
#define PTP_ctl_tsu_tx_ie_MSK     (1<<PTP_ctl_tsu_tx_ie       )
#define PTP_ctl_tsu_rx_en_MSK     (1<<PTP_ctl_tsu_rx_en       )
#define PTP_ctl_tsu_rx_rst_MSK    (1<<PTP_ctl_tsu_rx_rst      )
#define PTP_ctl_tsu_rx_ie_MSK     (1<<PTP_ctl_tsu_rx_ie       )
#define PTP_ctl_rtc_en_MSK        (1<<PTP_ctl_rtc_en          )
#define PTP_ctl_rtc_rst_MSK       (1<<PTP_ctl_rtc_rst         )
#define PTP_ctl_rtc_ie_MSK        (1<<PTP_ctl_rtc_ie          )
#define PTP_ctl_master_MSK        (1<<PTP_ctl_master          )
                                                              
#define PTP_stu_tsu_tx_ip_MSK     (1<<PTP_stu_tsu_tx_ip       )
#define PTP_stu_tsu_rx_ip_MSK     (1<<PTP_stu_tsu_rx_ip       )
#define PTP_stu_rtc_ip_MSK        (1<<PTP_stu_rtc_ip          )
                                                              
#define PTP_ld_ns_MSK             (0xFFFFFFFF                 )
#define PTP_ld_sec_lsb_MSK        (0xFFFFFFFF                 )
#define PTP_ld_sec_msb_MSK        (0x0000FFFF                 )
#define PTP_ld_wr_MSK             (1<<PTP_ld_wr               )

#define PTP_adj_ns_MSK            (0xFFFFFFFF                 )
#define PTP_adj_dec_MSK           (1<<PTP_adj_dec             )
#define PTP_adj_wr_MSK            (1<<PTP_adj_wr              )
                                                              
#define PTP_inc_fns_MSK           (0xFFFFFFFF                 )
#define PTP_inc_ns_MSK            (0xFF                       )
#define PTP_inc_wr_MSK            (1<<PTP_inc_wr              )

#define PTP_inc_adj_fns_MSK       (0xFFFFFFFF                 )
#define PTP_inc_adj_ns_MSK        (0xFF                       )
#define PTP_inc_adj_dec_MSK       (1<<PTP_inc_adj_dec         )
#define PTP_inc_adj_wr_MSK        (1<<PTP_inc_adj_wr          )

#define PTP_tod_ns_MSK            (0xFFFFFFFF                 )
#define PTP_tod_sec_lsb_MSK       (0xFFFFFFFF                 )
#define PTP_tod_sec_msb_MSK       (0x0000FFFF                 )
#define PTP_tod_sec_vld_MSK       (1<<PTP_tod_sec_vld         )
#define PTP_tod_sec_req_MSK       (1<<PTP_tod_sec_req         )
                                                              
#define PTP_timer_usec_MSK        (0x00FFFFFF                 )
#define PTP_timer_mode_MSK        (1<<PTP_timer_mode          )
#define PTP_timer_en_MSK          (1<<PTP_timer_en            )
                                                              
#define PTP_tsu_tx_seq_id_MSK     (0xFFFF<<PTP_tsu_tx_seq_id  )
#define PTP_tsu_tx_type_MSK       (0x000F<<PTP_tsu_tx_type    )
#define PTP_tsu_tx_mode_MSK       (0x0001<<PTP_tsu_tx_mode    )
#define PTP_tsu_tx_valid_MSK      (0x0001<<PTP_tsu_tx_valid   )
#define PTP_tsu_tx_full_MSK       (0x0001<<PTP_tsu_tx_full    )
#define PTP_tsu_tx_clr_MSK        (0x0001<<PTP_tsu_tx_clr     )
#define PTP_tsu_tx_rd_MSK         (0x0001<<PTP_tsu_tx_rd      )
#define PTP_tsu_tx_ns_MSK         (0xFFFFFFFF                 )
#define PTP_tsu_tx_sec_lsb_MSK    (0xFFFFFFFF                 )
#define PTP_tsu_tx_sec_msb_MSK    (0x0000FFFF                 )
                                                              
#define PTP_tsu_rx_seq_id_MSK     (0xFFFF<<PTP_tsu_rx_seq_id  )
#define PTP_tsu_rx_type_MSK       (0x000F<<PTP_tsu_rx_type    )
#define PTP_tsu_rx_mode_MSK       (0x0001<<PTP_tsu_rx_mode    )
#define PTP_tsu_rx_valid_MSK      (0x0001<<PTP_tsu_rx_valid   )
#define PTP_tsu_rx_full_MSK       (0x0001<<PTP_tsu_rx_full    )
#define PTP_tsu_rx_clr_MSK        (0x0001<<PTP_tsu_rx_clr     )
#define PTP_tsu_rx_rd_MSK         (0x0001<<PTP_tsu_rx_rd      )
#define PTP_tsu_rx_ns_MSK         (0xFFFFFFFF                 )
#define PTP_tsu_rx_sec_lsb_MSK    (0xFFFFFFFF                 )
#define PTP_tsu_rx_sec_msb_MSK    (0x0000FFFF                 )
                                                              
#define PTP_mac_lsb_MSK           (0xFFFFFFFF                 )
#define PTP_mac_msb_MSK           (0x0000FFFF                 )

#define PTP_opa_neg_MSK           (1<<PTP_opa_neg             )
#define PTP_opb_neg_MSK           (1<<PTP_opb_neg             )
#define PTP_result_neg_MSK        (1<<PTP_result_neg          )
#define PTP_result_over_MSK       (1<<PTP_result_over         )

//--------------------------------------------------------------------
int ptpv2_lite_master( int master )
{
    volatile uint32_t value;
    REGRD(CSRA_CONTROL,value);
    if (master) value |=  PTP_ctl_master_MSK;
    else        value &= ~PTP_ctl_master_MSK;
    REGWR(CSRA_CONTROL,value);
    return 0;
}

//--------------------------------------------------------------------
int ptpv2_lite_reset ( int rtc, int tsu_tx, int tsu_rx )
{
    volatile uint32_t value;
    REGRD(CSRA_CONTROL,value);
    if (rtc)    value |=  PTP_ctl_rtc_rst_MSK;
    else        value &= ~PTP_ctl_rtc_rst_MSK;
    if (tsu_tx) value |=  PTP_ctl_tsu_tx_rst_MSK;
    else        value &= ~PTP_ctl_tsu_tx_rst_MSK;
    if (tsu_rx) value |=  PTP_ctl_tsu_rx_rst_MSK;
    else        value &= ~PTP_ctl_tsu_rx_rst_MSK;
    REGWR(CSRA_CONTROL,value);
    return 0;
}
//--------------------------------------------------------------------
int ptpv2_lite_enable( int rtc, int tsu_tx, int tsu_rx )
{
     volatile uint32_t value;
     REGRD(CSRA_CONTROL, value); // read control reg.
     if (rtc) value |=  PTP_ctl_rtc_en_MSK;
     else     value &= ~PTP_ctl_rtc_en_MSK;
     if (tsu_tx) value |=  PTP_ctl_tsu_tx_en_MSK;
     else        value &= ~PTP_ctl_tsu_tx_en_MSK;
     if (tsu_rx) value |=  PTP_ctl_tsu_rx_en_MSK;
     else        value &= ~PTP_ctl_tsu_rx_en_MSK;
     REGWR(CSRA_CONTROL, value); // update control reg.
     return 0;
}
//--------------------------------------------------------------------
int ptpv2_lite_ie( int rtc, int tsu_tx, int tsu_rx )
{
     volatile uint32_t value;
     REGRD(CSRA_CONTROL, value); // read control reg.
     if (rtc) value |=  PTP_ctl_rtc_ie_MSK;
     else     value &= ~PTP_ctl_rtc_ie_MSK;
     if (tsu_tx) value |=  PTP_ctl_tsu_tx_ie_MSK;
     else        value &= ~PTP_ctl_tsu_tx_ie_MSK;
     if (tsu_rx) value |=  PTP_ctl_tsu_rx_ie_MSK;
     else        value &= ~PTP_ctl_tsu_rx_ie_MSK;
     REGWR(CSRA_CONTROL, value); // update control reg.
     return 0;
}
//--------------------------------------------------------------------
int ptpv2_lite_get_ip( int *rtc, int *tsu_tx, int *tsu_rx )
{
     volatile uint32_t value;
     REGRD(CSRA_STATUS, value);
     if (rtc   !=0) *rtc    = (value&PTP_stu_tsu_tx_ip_MSK) ? 1 : 0;
     if (tsu_tx!=0) *tsu_tx = (value&PTP_stu_tsu_rx_ip_MSK) ? 1 : 0;
     if (tsu_rx!=0) *tsu_rx = (value&PTP_stu_rtc_ip_MSK   ) ? 1 : 0;
     return 0;
}
//--------------------------------------------------------------------
// RTC IP will be clear, when argument rtc is 1.
int ptpv2_lite_clr_ip( int rtc, int tsu_tx, int tsu_rx )
{
     volatile uint32_t value;
     REGRD(CSRA_STATUS, value);
     if (rtc) value &= ~PTP_stu_rtc_ip_MSK; // IP will be clear when written to 0.
     if (tsu_tx) value &= ~PTP_stu_tsu_tx_ip_MSK;
     if (tsu_rx) value &= ~PTP_stu_tsu_rx_ip_MSK;
     REGWR(CSRA_STATUS, value);
     return 0;
}
//--------------------------------------------------------------------
int ptpv2_lite_set_mac_addr(uint8_t mac[6])
{
    volatile uint32_t value;
    value = mac[2]<<24
          | mac[3]<<16
          | mac[4]<<8
          | mac[5];
    REGWR(CSRA_MAC_ADDR_LSB, value);
    value = mac[0]<<8
          | mac[1];
    REGWR(CSRA_MAC_ADDR_MSB , value);
    return 0;
}

//--------------------------------------------------------------------
int ptpv2_lite_get_mac_addr(uint8_t mac[6])
{
    volatile uint32_t value;
    REGRD(CSRA_MAC_ADDR_LSB, value);
    mac[2] = (value&0xFF000000)>>24;
    mac[3] = (value&0x00FF0000)>>16;
    mac[4] = (value&0x0000FF00)>> 8;
    mac[5] = (value&0x000000FF);
    REGRD(CSRA_MAC_ADDR_MSB , value);
    mac[0] = (value&0x0000FF00)>>8;
    mac[1] = (value&0x000000FF);
    return 0;
}
//--------------------------------------------------------------------
int ptpv2_lite_set_ptp_id( uint8_t clock_id[8]
                         , uint16_t port_id)
{
    volatile uint32_t value;
    value = clock_id[4]<<24
          | clock_id[5]<<16
          | clock_id[6]<<8
          | clock_id[7];
    REGWR(CSRA_CLOCK_ID_LSB, value);
    value = clock_id[0]<<24
          | clock_id[1]<<16
          | clock_id[2]<<8
          | clock_id[3];
    REGWR(CSRA_CLOCK_ID_MSB , value);
    value = (uint32_t)port_id;
    REGWR(CSRA_PORT_ID, value);
    return 0;
}

//--------------------------------------------------------------------
int ptpv2_lite_get_ptp_id( uint8_t   clock_id[8]
                         , uint16_t *port_id)
{
    volatile uint32_t value;
    REGRD(CSRA_CLOCK_ID_LSB, value);
    clock_id[4] = (value&0xFF000000)>>24;
    clock_id[5] = (value&0x00FF0000)>>16;
    clock_id[6] = (value&0x0000FF00)>> 8;
    clock_id[7] = (value&0x000000FF);
    REGRD(CSRA_CLOCK_ID_MSB , value);
    clock_id[0] = (value&0xFF000000)>>24;
    clock_id[1] = (value&0x00FF0000)>>16;
    clock_id[2] = (value&0x0000FF00)>> 8;
    clock_id[3] = (value&0x000000FF);
    if (port_id!=0) {
        REGRD(CSRA_PORT_ID, value);
        *port_id = value&0xFFFF;
    }
    return 0;
}
//--------------------------------------------------------------------
int ptpv2_lite_get_tod( uint16_t *sec_msb
                      , uint32_t *sec_lsb
                      , uint32_t *nano)
{
    volatile uint32_t value;
    value = PTP_tod_sec_req_MSK;
    REGWR(CSRA_TOD_RD_SEC_MSB,value);
    do { REGRD(CSRA_TOD_RD_SEC_MSB,value); } while (value&PTP_tod_sec_req_MSK);
    if (sec_msb!=0) *sec_msb = value&0xFFFF;
    if (nano   !=0) { REGRD(CSRA_TOD_RD_NS, value); *nano = value; }
    if (sec_lsb!=0) { REGRD(CSRA_TOD_RD_SEC_LSB, value); *sec_lsb = value; }
    return 0;
}

//--------------------------------------------------------------------
int ptpv2_lite_set_tod( uint16_t sec_msb
                      , uint32_t sec_lsb
                      , uint32_t nano)
{
    volatile uint32_t value;
    REGWR(CSRA_LD_NS, nano);
    REGWR(CSRA_LD_SEC_LSB, sec_lsb);
    value = PTP_ld_wr_MSK | (sec_msb&0xFFFF);
    REGWR(CSRA_LD_SEC_MSB, value);
    while (value&PTP_ld_wr_MSK) { // wait until complete
        REGRD(CSRA_LD_SEC_MSB, value);
    }
    return 0;
}

//--------------------------------------------------------------------
// It should be called when RTC is enabled, since it is updated
// at the point of 'ptp_ppus'.
// dec=0 for increment
// dec=1 for decrement
// No second part for this version.
int ptpv2_lite_adj_tod( uint8_t  dec
                      , uint8_t  sec
                      , uint32_t nano)
{
    volatile uint32_t value;
    REGWR(CSRA_ADJ_NS, nano);
    value = PTP_adj_wr_MSK | sec;
    if (dec) value |= PTP_adj_dec_MSK;
    REGWR(CSRA_ADJ_SEC, value);
    while (value&PTP_adj_wr_MSK) { // wait until complete
        REGRD(CSRA_ADJ_SEC, value);
    }
    return 0;
}

//--------------------------------------------------------------------
int ptpv2_lite_set_inc( uint8_t  nano
                      , uint32_t nano_frac)
{
    volatile uint32_t value;
    REGWR(CSRA_INC_LD_FRAC, nano_frac);
    value = PTP_inc_wr_MSK | (nano&PTP_inc_ns_MSK);
    REGWR(CSRA_INC_LD_NS, value);
    while (value&PTP_inc_wr_MSK) { // wait until complete
       REGRD(CSRA_INC_LD_NS, value);
    }
    return 0;
}

//--------------------------------------------------------------------
// It should be called when RTC is enabled, since it is updated
// at the point of 'ptp_ppus'.
// dec=0 for increment
// dec=1 for decrement
int ptpv2_lite_adj_inc( uint8_t  dec
                      , uint8_t  nano
                      , uint32_t nano_frac)
{
    volatile uint32_t value;
    REGWR(CSRA_INC_ADJ_FRAC, nano_frac);
    value = PTP_inc_adj_wr_MSK | (nano&PTP_inc_adj_ns_MSK);
    if (dec) value |= PTP_inc_adj_dec_MSK;
    REGWR(CSRA_INC_ADJ_NS, value);
    while (value&PTP_inc_adj_wr_MSK) { // wait until complete
       REGRD(CSRA_INC_ADJ_NS, value);
    }
    return 0;
}

//--------------------------------------------------------------------
int ptpv2_lite_get_inc( uint8_t  *nano
                      , uint32_t *nano_frac)
{
    volatile uint32_t value;
    REGRD(CSRA_INC_LD_FRAC, value);
    if (nano_frac!=0) *nano_frac = value;
    REGRD(CSRA_INC_LD_NS, value);
    if (nano     !=0) *nano      = (value&PTP_inc_ns_MSK);
    return 0;
}
//--------------------------------------------------------------------
int ptpv2_fifo_clr( uint8_t tsu_tx
                  , uint8_t tsu_rx )
{
    volatile uint32_t value;
    if (tsu_tx) {
        REGRD(CSRA_TSU_TX_ID, value);
        value |=  PTP_tsu_tx_clr_MSK;
        REGWR(CSRA_TSU_TX_ID, value);
    }
    if (tsu_rx) {
        REGRD(CSRA_TSU_RX_ID, value);
        value |=  PTP_tsu_rx_clr_MSK;
        REGWR(CSRA_TSU_RX_ID, value);
    }
    return 0;
}
//--------------------------------------------------------------------
int ptpv2_fifo_status( uint8_t *tsu_tx
                     , uint8_t *tsu_rx)
{
    volatile uint32_t value;
    if (tsu_tx!=0) {
        REGRD(CSRA_TSU_TX_ID, value);
       *tsu_tx = (value&PTP_tsu_tx_valid_MSK) ? 1 : 0;
    }
    if (tsu_rx!=0) {
        REGRD(CSRA_TSU_RX_ID, value);
       *tsu_rx = (value&PTP_tsu_rx_valid_MSK) ? 1 : 0;
    }
    return 0;
}
//--------------------------------------------------------------------
// Return ==1 when timeout.
// Return ==2 when no valid value.
// timeout=0 for blocking.
int ptpv2_fifo_tx_pop_nb( uint8_t  *mode    // 1-bit, 0=raw Ethernet, 1=PTPv2 over UPD/IP
                        , uint8_t  *type    // 4-bit, PTPv2 message type
                        , uint16_t *seq_id  // 16-bit sequencey ID
                        , uint32_t *nsec    // 32-bit nanosec timestamp
                        , uint16_t *sec_msb // higher 16-bit timestamp
                        , uint32_t *sec_lsb // lower 32-bit timestamp
                        , int       timeout)
{
    volatile uint32_t value, tnum;
    uint8_t valid_tx;
    tnum=0;
    do { ptpv2_fifo_status( &valid_tx, 0);
         if ((timeout>0)&&(timeout<=tnum++)) return 1;
    } while (valid_tx==0);

    REGRD(CSRA_TSU_TX_ID, value);
    if (!(value&PTP_tsu_tx_valid_MSK)) return 2;
    *mode   = (value&PTP_tsu_tx_mode_MSK)>>PTP_tsu_tx_mode;// 1-bit, 0=raw Ethernet, 1=PTPv2 over UPD/IP
    *type   = (value&PTP_tsu_tx_type_MSK)>>PTP_tsu_tx_type;// 4-bit, PTPv2 message type
    *seq_id = value&PTP_tsu_tx_seq_id_MSK;// 16-bit sequencey ID

    REGRD(CSRA_TSU_TX_NS     , value); *nsec = value;
    REGRD(CSRA_TSU_TX_SEC_LSB, value); *sec_lsb = value;
    REGRD(CSRA_TSU_TX_SEC_MSB, value); *sec_msb = value*0xFFFF;

    value = PTP_tsu_tx_rd_MSK;
    REGWR(CSRA_TSU_TX_ID, value);
    do {REGRD(CSRA_TSU_TX_ID, value);} while (value&PTP_tsu_tx_rd_MSK);

    return 0;
}
//--------------------------------------------------------------------
// Return 1 when no valid value.
// timeout=0 for blocking.
int ptpv2_fifo_rx_pop_nb( uint8_t  *mode    // 1-bit, 0=raw Ethernet, 1=PTPv2 over UPD/IP
                        , uint8_t  *type    // 4-bit, PTPv2 message type
                        , uint16_t *seq_id  // 16-bit sequencey ID
                        , uint32_t *nsec    // 32-bit nanosec timestamp
                        , uint16_t *sec_msb // higher 16-bit timestamp
                        , uint32_t *sec_lsb // lower 32-bit timestamp
                        , int       timeout)
{
    volatile uint32_t value, tnum;
    uint8_t valid_rx;
    tnum=0;
    do { ptpv2_fifo_status( 0, &valid_rx);
         if ((timeout>0)&&(timeout<=tnum++)) return 1;
    } while (valid_rx==0);

    REGRD(CSRA_TSU_RX_ID, value);
    if (!(value&PTP_tsu_rx_valid_MSK)) return 1;
    *mode   = (value&PTP_tsu_rx_mode_MSK)>>PTP_tsu_rx_mode;// 1-bit, 0=raw Ethernet, 1=PTPv2 over UPD/IP
    *type   = (value&PTP_tsu_rx_type_MSK)>>PTP_tsu_rx_type;// 4-bit, PTPv2 message type
    *seq_id = value&PTP_tsu_rx_seq_id_MSK;// 16-bit sequencey ID

    REGRD(CSRA_TSU_RX_NS     , value); *nsec = value;
    REGRD(CSRA_TSU_RX_SEC_LSB, value); *sec_lsb = value;
    REGRD(CSRA_TSU_RX_SEC_MSB, value); *sec_msb = value*0xFFFF;

    value = PTP_tsu_rx_rd_MSK;
    REGWR(CSRA_TSU_RX_ID, value);
    do {REGRD(CSRA_TSU_RX_ID, value);} while (value&PTP_tsu_rx_rd_MSK);

    return 0;
}
//--------------------------------------------------------------------
int ptpv2_timer( int enable
               , uint32_t usec)
{
    volatile uint32_t value;
    if (usec==0) REGRD(CSRA_TIMER, value);
    else value = usec&PTP_timer_usec_MSK;
    if (enable) value |= PTP_timer_en_MSK;
    REGWR(CSRA_TIMER, value);
    return 0;
}
//--------------------------------------------------------------------
// It is not 2's complement.
// {negA,secA_msb,secA_lsb,nsecA} + {negB,secB_msb,secB_lsb,nsecB}
int ptpv2_add( uint8_t   Aneg     // negative when 1
             , uint16_t  Asec_msb // absolute value
             , uint32_t  Asec_lsb // absolute value
             , uint32_t  Ansec    // absolute value
             , uint8_t   Bneg     // negative when 1
             , uint16_t  Bsec_msb // absolute value
             , uint32_t  Bsec_lsb // absolute value
             , uint32_t  Bnsec    // absolute value
             , uint8_t  *Cover    // overflow when 1
             , uint8_t  *Cneg     // negative when 1
             , uint16_t *Csec_msb // absolute value
             , uint32_t *Csec_lsb // absolute value
             , uint32_t *Cnsec)   // absolute value
{
    volatile uint32_t value;
    value = (uint32_t)Asec_msb;
    if (Aneg) value |= PTP_opa_neg_MSK;
    REGWR(CSRA_OPA_SEC_MSB, value);
    REGWR(CSRA_OPA_SEC_LSB, Asec_lsb);
    REGWR(CSRA_OPA_NSEC   , Ansec);

    value = (uint32_t)Bsec_msb;
    if (Bneg) value |= PTP_opb_neg_MSK;
    REGWR(CSRA_OPB_SEC_MSB, value);
    REGWR(CSRA_OPB_SEC_LSB, Bsec_lsb);
    REGWR(CSRA_OPB_NSEC   , Bnsec);

    if (Cnsec   !=0) { REGRD(CSRA_RESULT_NSEC   , value); *Cnsec    = value; }
    if (Csec_lsb!=0) { REGRD(CSRA_RESULT_SEC_LSB, value); *Csec_lsb = value; }
    if (Csec_msb!=0) { REGRD(CSRA_RESULT_SEC_MSB, value); *Csec_msb = value&0xFFFF;
                       if (Cover!=0) *Cover = (value&PTP_result_over_MSK) ? 1 : 0;
                       if (Cneg!=0)  *Cneg  = (value&PTP_result_neg_MSK ) ? 1 : 0;
                     }
    return 0;
}
//--------------------------------------------------------------------
// It is not 2's complement.
// {negA,secA_msb,secA_lsb,nsecA} - {negB,secB_msb,secB_lsb,nsecB}
int ptpv2_sub( uint8_t   Aneg     // negative when 1
             , uint16_t  Asec_msb // absolute value
             , uint32_t  Asec_lsb // absolute value
             , uint32_t  Ansec // absolute value
             , uint8_t   Bneg     // negative when 1
             , uint16_t  Bsec_msb // absolute value
             , uint32_t  Bsec_lsb // absolute value
             , uint32_t  Bnsec // absolute value
             , uint8_t  *Cover    // overflow when 1
             , uint8_t  *Cneg     // negative when 1
             , uint16_t *Csec_msb // absolute value
             , uint32_t *Csec_lsb // absolute value
             , uint32_t *Cnsec) // absolute value
{
    uint8_t  neg;
    ptpv2_add( 0 // positive
             , Asec_msb
             , Asec_lsb
             , Ansec
             , (Aneg==Bneg) // sub when different signess
             , Bsec_msb
             , Bsec_lsb
             , Bnsec
             , Cover
             , &neg
             , Csec_msb
             , Csec_lsb
             , Cnsec);
    if (Aneg==Bneg) { // both negative or positive
      *Cneg  = (Aneg) ? !neg : neg;
    } else { // differ signess
      *Cneg  = Aneg;
    }
//printf("sub:%c%04X%08X.%08X\n", (*Cneg)?'-':'+',*Csec_msb,*Csec_lsb,*Cnsec);
//printf("    %c%04X%08X.%08X - %c%04X%08X.%08X neg=%c (Aneg==Bneg)=%d\n",
//            (Aneg) ? '-':'+',Asec_msb,Asec_lsb,Ansec,
//            (Bneg) ? '-':'+',Bsec_msb,Bsec_lsb,Bnsec,
//            (neg ) ? '-':'+', (Aneg==Bneg));
    return 0;
}
//--------------------------------------------------------------------
#if !defined(COMPACT_CODE)
#define read_and_check(A,N,E)\
        do {\
        REGRD((A),value);\
        if (value!=(E)) {\
            printf("PTP %10s A=0x%08X D=0x%08X, but 0x%08X expected\n", (N), (A), (unsigned int)value, (E));\
        } else { printf("PTP %10s A=0x%08X D=0x%08X OK\n", (N), (A), (unsigned int)value); }\
        } while (0)

int ptp_csr_check ()
{
     volatile uint32_t value;
     int err = 0;
     read_and_check(CSRA_NAME0         , "NAME0         ",(unsigned int)*((unsigned int*)&"vPTP"));
     read_and_check(CSRA_NAME1         , "NAME1         ",(unsigned int)*((unsigned int*)&"IL 2"));
     read_and_check(CSRA_NAME2         , "NAME2         ",(unsigned int)*((unsigned int*)&"  ET"));
     read_and_check(CSRA_NAME3         , "NAME3         ",(unsigned int)*((unsigned int*)&"    "));
     read_and_check(CSRA_COMP0         , "COMP0         ",(unsigned int)*((unsigned int*)&" SDF"));
     read_and_check(CSRA_COMP1         , "COMP1         ",(unsigned int)*((unsigned int*)&"    "));
     read_and_check(CSRA_COMP2         , "COMP2         ",(unsigned int)*((unsigned int*)&"    "));
     read_and_check(CSRA_COMP3         , "COMP3         ",(unsigned int)*((unsigned int*)&"    "));
     REGRD(CSRA_VERSION,value);
     printf("PTP %10s A=0x%08X D=0x%08X\n", "VERSION       ", CSRA_VERSION, (unsigned int)value);
   //read_and_check(CSRA_VERSION       , "VERSION       ", PTPV2_LITE_VERSION);
     read_and_check(CSRA_CONTROL       , "CONTROL       ",(unsigned int)0x00000000);
     read_and_check(CSRA_STATUS        , "STATUS        ",(unsigned int)0x00000000);
     read_and_check(CSRA_LD_NS         , "LD_NS         ",(unsigned int)0x00000000);
     read_and_check(CSRA_LD_SEC_LSB    , "LD_SEC_LSB    ",(unsigned int)0x00000000);
     read_and_check(CSRA_LD_SEC_MSB    , "LD_SEC_MSB    ",(unsigned int)0x00000000);
     read_and_check(CSRA_ADJ_NS        , "ADJ_NS        ",(unsigned int)0x00000000);
     read_and_check(CSRA_ADJ_SEC       , "ADJ_SEC       ",(unsigned int)0x00000000);
     read_and_check(CSRA_INC_LD_FRAC   , "INC_LD_FRAC   ",(unsigned int)0x00000000);
     read_and_check(CSRA_INC_LD_NS     , "INC_LD_NS     ",(unsigned int)0x00000008);
     read_and_check(CSRA_INC_ADJ_FRAC  , "INC_ADJ_FRAC  ",(unsigned int)0x00000000);
     read_and_check(CSRA_INC_ADJ_NS    , "INC_ADJ_NS    ",(unsigned int)0x00000000);
     read_and_check(CSRA_TOD_RD_NS     , "TOD_RD_NS     ",(unsigned int)0x00000000);
     read_and_check(CSRA_TOD_RD_SEC_LSB, "TOD_RD_SEC_LSB",(unsigned int)0x00000000);
     read_and_check(CSRA_TOD_RD_SEC_MSB, "TOD_RD_SEC_MSB",(unsigned int)0x00000000);
     read_and_check(CSRA_TIMER         , "TIMER         ",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_TX_ID     , "TSU_TX_ID     ",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_TX_NS     , "TSU_TX_NS     ",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_TX_SEC_LSB, "TSU_TX_SEC_LSB",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_TX_SEC_MSB, "TSU_TX_SEC_MSB",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_RX_ID     , "TSU_RX_ID     ",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_RX_NS     , "TSU_RX_NS     ",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_RX_SEC_LSB, "TSU_RX_SEC_LSB",(unsigned int)0x00000000);
     read_and_check(CSRA_TSU_RX_SEC_MSB, "TSU_RX_SEC_MSB",(unsigned int)0x00000000);
     read_and_check(CSRA_MAC_ADDR_LSB  , "MAC_ADDR_LSB  ",(unsigned int)0x22334455);
     read_and_check(CSRA_MAC_ADDR_MSB  , "MAC_ADDR_MSB  ",(unsigned int)0x00000211);
     read_and_check(CSRA_CLOCK_ID_LSB  , "CLOCK_ID_LSB  ",(unsigned int)0x22334455);
     read_and_check(CSRA_CLOCK_ID_MSB  , "CLOCK_ID_MSB  ",(unsigned int)0xACDE4800);
     read_and_check(CSRA_PORT_ID       , "PORT_ID       ",(unsigned int)0x00000001);
     read_and_check(CSRA_OPA_NSEC      , "OPA_NSEC      ",(unsigned int)0x00000000);
     read_and_check(CSRA_OPA_SEC_LSB   , "OPA_SEC_LSB   ",(unsigned int)0x00000000);
     read_and_check(CSRA_OPA_SEC_MSB   , "OPA_SEC_MSB   ",(unsigned int)0x00000000);
     read_and_check(CSRA_OPB_NSEC      , "OPB_NSEC      ",(unsigned int)0x00000000);
     read_and_check(CSRA_OPB_SEC_LSB   , "OPB_SEC_LSB   ",(unsigned int)0x00000000);
     read_and_check(CSRA_OPB_SEC_MSB   , "OPB_SEC_MSB   ",(unsigned int)0x00000000);
     read_and_check(CSRA_RESULT_NSEC   , "RESULT_NSEC   ",(unsigned int)0x00000000);
     read_and_check(CSRA_RESULT_SEC_LSB, "RESULT_SEC_LSB",(unsigned int)0x00000000);
     read_and_check(CSRA_RESULT_SEC_MSB, "RESULT_SEC_MSB",(unsigned int)0x00000000);
     return err;
}
#endif
//--------------------------------------------------------------------
// Revision History
//
// 2019.05.20: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------------------
