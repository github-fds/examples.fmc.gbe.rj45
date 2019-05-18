//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 by Future Design Systems , Inc.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// gig_eth_hsr_api.c
//------------------------------------------------------------------------------
// VERSION = 2019.03.02.
//------------------------------------------------------------------------------
//#ifndef COMPACT_CODE
//#endif
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "defines_system.h"
#include "gig_eth_hsr_api.h"

//------------------------------------------------------------------------------
// Register access macros
#define REGRD(A,V)    (V) = *((volatile uint32_t *)(A))
#define REGWR(A,V)    *((volatile uint32_t *)(A)) = (V)
#define REGRDB(A,P,L) memcpy((void*)(P), (void*)(A), 4*(L)) //BfmRead((unsigned int)(A), (unsigned int*)(P), 4, (L));
#define REGWRB(A,P,L) memcpy((void*)(A), (void*)(P), 4*(L)) //BfmWrite((unsigned int)(A), (unsigned int*)(P), 4, (L));

//------------------------------------------------------------------------------
#if !defined(ADDR_GBE_HSR_START)
#define ADDR_GBE_HSR_START   0x4C010000
#endif
#define CSRA_HSR_BASE           ADDR_GBE_HSR_START
#define CSRA_HSR_VERSION       (CSRA_HSR_BASE+0x00)
#define CSRA_HSR_MAC_ADDR0     (CSRA_HSR_BASE+0x10)// MAC[47:16]
#define CSRA_HSR_MAC_ADDR1     (CSRA_HSR_BASE+0x14)// MAC[15:0]
#define CSRA_HSR_HSR_NET_ID    (CSRA_HSR_BASE+0x18)
#define CSRA_HSR_CONTROL       (CSRA_HSR_BASE+0x1C)
#define CSRA_HSR_PHY           (CSRA_HSR_BASE+0x20)// to check and drive PHY RESET
#define CSRA_HSR_PROXY         (CSRA_HSR_BASE+0x24)// read-only (num of entries)
#define CSRA_HSR_QR            (CSRA_HSR_BASE+0x28)// read-only (num of entries)
#define CSRA_HSR_CRC_ERR_HOST  (CSRA_HSR_BASE+0x30)// read-only
#define CSRA_HSR_RCV_PKT       (CSRA_HSR_BASE+0x40)// read-only
#define CSRA_HSR_CRC_ERR       (CSRA_HSR_BASE+0x44)// read-only
#define CSRA_HSR_DROP_UNKNOWN  (CSRA_HSR_BASE+0x48)// read-only
#define CSRA_HSR_DROP_FULL     (CSRA_HSR_BASE+0x4C)// read-only
#define CSRA_HSR_DROP_SRC      (CSRA_HSR_BASE+0x50)// read-only
#define CSRA_HSR_DROP_NON_HSR  (CSRA_HSR_BASE+0x54)// read-only
#define CSRA_HSR_DROP_NON_QR   (CSRA_HSR_BASE+0x58)// read-only
#define CSRA_HSR_BOTH          (CSRA_HSR_BASE+0x5C)// read-only
#define CSRA_HSR_UPSTREAM      (CSRA_HSR_BASE+0x60)// read-only
#define CSRA_HSR_FORWARD       (CSRA_HSR_BASE+0x64)// read-only

//------------------------------------------------------------------------------
#define HSR_CTL_redbox       31
#define HSR_CTL_performance  30
#define HSR_CTL_snoop         3
#define HSR_CTL_hsr_qr        2
#define HSR_CTL_drop_non_hsr  1
#define HSR_CTL_promiscuous   0

#define HSR_PHY_ready         6
#define HSR_PHY_resetB        2
#define HSR_PHY_resetA        1
#define HSR_PHY_resetU        0

//------------------------------------------------------------------------------
#define HSR_CTL_redbox_MSK       (0x1<<HSR_CTL_redbox      )
#define HSR_CTL_performance_MSK  (0x1<<HSR_CTL_performance )
#define HSR_CTL_snoop_MSK        (0x1<<HSR_CTL_snoop       )
#define HSR_CTL_hsr_qr_MSK       (0x1<<HSR_CTL_hsr_qr      )
#define HSR_CTL_drop_non_hsr_MSK (0x1<<HSR_CTL_drop_non_hsr)
#define HSR_CTL_promiscuous_MSK  (0x1<<HSR_CTL_promiscuous )
                                                           
#define HSR_PHY_ready_MSK        (0x1<<HSR_PHY_ready       )
#define HSR_PHY_resetB_MSK       (0x1<<HSR_PHY_resetB      )
#define HSR_PHY_resetA_MSK       (0x1<<HSR_PHY_resetA      )
#define HSR_PHY_resetU_MSK       (0x1<<HSR_PHY_resetU      )

//------------------------------------------------------------------------------
// What if (n) is misaligned
#define htons(n) (uint16_t)( (((uint16_t) (n)) << 8)\
		            |(((uint16_t) (n)) >> 8))
#define ntohs(n) htons(n)
#define htonl(n) (uint32_t)( (((uint32_t)(n)&0xFF)<<24)\
                            |(((uint32_t)(n)&0xFF00)<<8)\
                            |(((uint32_t)(n)&0xFF0000)>>8)\
                            |(((uint32_t)(n)&0xFF000000)>>24))
#define ntohl(n) htonl(n)

//--------------------------------------------------------------------
// conf_mac_addr[47:40] = mac[0] = WDATA[ 7: 0]
// conf_mac_addr[39:32] = mac[1] = WDATA[15: 8]
// conf_mac_addr[31:24] = mac[2] = WDATA[23:16]
// conf_mac_addr[23:16] = mac[3] = WDATA[31:24]
// conf_mac_addr[16: 8] = mac[4] = WDATA[ 7: 0]
// conf_mac_addr[ 7: 0] = mac[5] = WDATA[15: 8]
//
// mac[0] will be the MSByte - bit 0 determines boradcasting or not.
int gig_eth_hsr_set_mac_addr( uint8_t mac[6] )
{
    volatile uint32_t value;
    value = mac[3]<<24
          | mac[2]<<16
          | mac[1]<< 8
          | mac[0];
    REGWR(CSRA_HSR_MAC_ADDR0, value);
    value = mac[5]<<8
          | mac[4];
    REGWR(CSRA_HSR_MAC_ADDR1, value);
    return 0;
}

//--------------------------------------------------------------------
// mac[0] will be the MSByte - bit 0 determines boradcasting or not.
int gig_eth_hsr_get_mac_addr( uint8_t mac[6] )
{
    volatile uint32_t value;
    REGRD(CSRA_HSR_MAC_ADDR0, value);
    mac[0] = (value&0xFF);
    mac[1] = (value&0xFF00)>>8;
    mac[2] = (value&0xFF0000)>>16;
    mac[3] = (value&0xFF000000)>>24;
    REGRD(CSRA_HSR_MAC_ADDR1, value);
    mac[4] = (value&0xFF);
    mac[5] = (value&0xFF00)>>8;
    return 0;
}

//------------------------------------------------------------------------------
int gig_eth_hsr_set_control( uint8_t snoop // 3
                           , uint8_t enable_qr    // 2
                           , uint8_t drop_non_hsr // 1
                           , uint8_t promiscuous // 0
                           )
{
#define SET_CONT(A,M)\
        if ((A)) value |= (M); else value &= ~(M);
    volatile uint32_t value=0;
    SET_CONT(snoop       , HSR_CTL_snoop_MSK       );
    SET_CONT(enable_qr   , HSR_CTL_hsr_qr_MSK      );
    SET_CONT(drop_non_hsr, HSR_CTL_drop_non_hsr_MSK);
    SET_CONT(promiscuous , HSR_CTL_promiscuous_MSK );
    REGWR(CSRA_HSR_CONTROL, value);
#undef SET_CONT
    return 0;
}

//------------------------------------------------------------------------------
int gig_eth_hsr_get_control( uint8_t *hsr_type  // 31
                           , uint8_t *hsr_perf  // 30
                           , uint8_t *hsr_snoop // 3
                           , uint8_t *hsr_enable_qr    // 2
                           , uint8_t *hsr_drop_non_hsr // 1
                           , uint8_t *hsr_promiscuous  // 0
                           )
{
    volatile uint32_t value;
    REGRD(CSRA_HSR_CONTROL, value);
    if (hsr_type        !=NULL) *hsr_type        =(value&HSR_CTL_redbox_MSK      ) ? 1 : 0;
    if (hsr_perf        !=NULL) *hsr_perf        =(value&HSR_CTL_performance_MSK ) ? 1 : 0;
    if (hsr_snoop       !=NULL) *hsr_snoop       =(value&HSR_CTL_snoop_MSK       ) ? 1 : 0;
    if (hsr_enable_qr   !=NULL) *hsr_enable_qr   =(value&HSR_CTL_hsr_qr_MSK      ) ? 1 : 0;
    if (hsr_drop_non_hsr!=NULL) *hsr_drop_non_hsr=(value&HSR_CTL_drop_non_hsr_MSK) ? 1 : 0;
    if (hsr_promiscuous !=NULL) *hsr_promiscuous =(value&HSR_CTL_promiscuous_MSK ) ? 1 : 0;
    return 0;
}

//------------------------------------------------------------------------------
// It checks MAC if it is ready.
//
// Retrun 1 when ready.
// Return 0 when not ready.
int gig_eth_hsr_ready( void )
{
    volatile uint32_t value;
    REGRD(CSRA_HSR_CONTROL, value);
    return (value&HSR_PHY_ready_MSK) ? 1 : 0;
}

//------------------------------------------------------------------------------
#ifndef COMPACT_CODE
#define AMBA_AXI4
#define read_and_check(A,N,E)\
        do {\
        REGRD((A),value);\
        if (value!=(E)) {\
            printf("HSR %10s A=0x%08X D=0x%08X, but 0x%08X expected\n", (N), (A), (unsigned int)value, (E));\
        } else { printf("HSR %10s A=0x%08X D=0x%08X OK\n", (N), (A), (unsigned int)value); }\
        } while (0)

void gig_eth_hsr_csr_check ( void )
{
     uint32_t value;
     int perf=0;

     read_and_check(CSRA_HSR_VERSION     , "VERSION     ", 0x20181001);
     read_and_check(CSRA_HSR_MAC_ADDR0   , "MAC_ADDR0   ", 0x56341202);
     read_and_check(CSRA_HSR_MAC_ADDR1   , "MAC_ADDR1   ", 0x00000078);
     read_and_check(CSRA_HSR_HSR_NET_ID  , "HSR_NET_ID  ", 0x00000000);
     read_and_check(CSRA_HSR_CONTROL     , "CONTROL     ", 0x00000006);
#if 0
     if (value&HSR_CTL_redbox_MSK      ) printf("     DANH \n"); else printf("     RedBOX\n");
     if (value&HSR_CTL_hsr_qr_MSK      ) printf("     QR ON\n"); else printf("     QR OFF\n");
#endif
     if (value&HSR_CTL_performance_MSK ) perf=1;
     read_and_check(CSRA_HSR_PHY         , "PHY         ", 0x0000007F);
     read_and_check(CSRA_HSR_PROXY       , "PROXY       ", 0x00000010);
     read_and_check(CSRA_HSR_QR          , "QR          ", 0x00000010);
     if (perf==1) {
     read_and_check(CSRA_HSR_CRC_ERR_HOST, "CRC_ERR_HOST", 0x00000000);
     read_and_check(CSRA_HSR_RCV_PKT     , "RCV_PKT     ", 0x00000000);
     read_and_check(CSRA_HSR_CRC_ERR     , "CRC_ERR     ", 0x00000000);
     read_and_check(CSRA_HSR_DROP_UNKNOWN, "DROP_UNKNOWN", 0x00000000);
     read_and_check(CSRA_HSR_DROP_FULL   , "DROP_FULL   ", 0x00000000);
     read_and_check(CSRA_HSR_DROP_SRC    , "DROP_SRC    ", 0x00000000);
     read_and_check(CSRA_HSR_DROP_NON_HSR, "DROP_NON_HSR", 0x00000000);
     read_and_check(CSRA_HSR_DROP_NON_QR , "DROP_NON_QR ", 0x00000000);
     read_and_check(CSRA_HSR_BOTH        , "BOTH        ", 0x00000000);
     read_and_check(CSRA_HSR_UPSTREAM    , "UPSTREAM    ", 0x00000000);
     read_and_check(CSRA_HSR_FORWARD     , "FORWARD     ", 0x00000000);
     }
}
#endif

//------------------------------------------------------------------------------
// Revision History
//
// 2019.03.02: Updated
//             gig_eth_hsr_get_control()/gig_eth_hsr_set_control() added.
// 2018.07.05: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
