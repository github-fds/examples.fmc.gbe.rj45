//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 by Future Design Systems , Inc.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// gig_eth_mac_api.c
//------------------------------------------------------------------------------
// VERSION = 2019.05.20.
//------------------------------------------------------------------------------
//#ifndef COMPACT_CODE
//#endif
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "defines_system.h"
#include "gig_eth_mac_api.h"

//------------------------------------------------------------------------------
// Register access macros
#define REGRD(A,V)    (V) = *((volatile uint32_t *)(A))
#define REGWR(A,V)    *((volatile uint32_t *)(A)) = (V)
#define REGRDB(A,P,L) memcpy((void*)(P), (void*)(A), 4*(L)) //BfmRead((unsigned int)(A), (unsigned int*)(P), 4, (L));
#define REGWRB(A,P,L) memcpy((void*)(A), (void*)(P), 4*(L)) //BfmWrite((unsigned int)(A), (unsigned int*)(P), 4, (L));

//------------------------------------------------------------------------------
#if !defined(ADDR_GBE_MAC_START)
#define ADDR_GBE_MAC_START   0x43000000
#endif
#define CSRA_GBE_BASE        ADDR_GBE_MAC_START
#define CSRA_GBE_CONTROL    (CSRA_GBE_BASE+0x00)
#define CSRA_GBE_STATUS     (CSRA_GBE_BASE+0x04)
#define CSRA_GBE_VERSION    (CSRA_GBE_BASE+0x08)

#define CSRA_GBE_MAC_ADDR0  (CSRA_GBE_BASE+0x10) //[7:0] goes to conf_mac_addr[47:40]
#define CSRA_GBE_MAC_ADDR1  (CSRA_GBE_BASE+0x14)

#define CSRA_GBE_CONF_TX0   (CSRA_GBE_BASE+0x20)
#define CSRA_GBE_CONF_TX1   (CSRA_GBE_BASE+0x24)
#define CSRA_GBE_CONF_RX0   (CSRA_GBE_BASE+0x30)
#define CSRA_GBE_CONF_RX1   (CSRA_GBE_BASE+0x34)

#define CSRA_GBE_DES_TX0    (CSRA_GBE_BASE+0x40) // room,bnum
#define CSRA_GBE_DES_TX1    (CSRA_GBE_BASE+0x44) // dummy to align with 64-bit
#define CSRA_GBE_DES_TX2    (CSRA_GBE_BASE+0x48) // src
#define CSRA_GBE_DES_TX3    (CSRA_GBE_BASE+0x4C) // src

#define CSRA_GBE_DES_RX0    (CSRA_GBE_BASE+0x50) // items,bnum
#define CSRA_GBE_DES_RX1    (CSRA_GBE_BASE+0x54) // dummy to align with 64-bit
#define CSRA_GBE_DES_RX2    (CSRA_GBE_BASE+0x58) // dst
#define CSRA_GBE_DES_RX3    (CSRA_GBE_BASE+0x5C) // dst

#define CSRA_GBE_DMA_TX0    (CSRA_GBE_BASE+0x60) // control (chunk)
#define CSRA_GBE_DMA_TX1    (CSRA_GBE_BASE+0x64) // status (full or empty)
#define CSRA_GBE_DMA_TX2    (CSRA_GBE_BASE+0x68) // start (lower 32-bit)
#define CSRA_GBE_DMA_TX3    (CSRA_GBE_BASE+0x6C) // start (upper 32-bit)
#define CSRA_GBE_DMA_TX4    (CSRA_GBE_BASE+0x70) // end
#define CSRA_GBE_DMA_TX5    (CSRA_GBE_BASE+0x74) // end
#define CSRA_GBE_DMA_TX6    (CSRA_GBE_BASE+0x78) // head
#define CSRA_GBE_DMA_TX7    (CSRA_GBE_BASE+0x7C) // head
#define CSRA_GBE_DMA_TX8    (CSRA_GBE_BASE+0x80) // tail (RO)
#define CSRA_GBE_DMA_TX9    (CSRA_GBE_BASE+0x84) // tail (RO)

#define CSRA_GBE_DMA_RX0    (CSRA_GBE_BASE+0x90) // control (chunk)
#define CSRA_GBE_DMA_RX1    (CSRA_GBE_BASE+0x94) // status (full or empty)
#define CSRA_GBE_DMA_RX2    (CSRA_GBE_BASE+0x98) // start
#define CSRA_GBE_DMA_RX3    (CSRA_GBE_BASE+0x9C) // start
#define CSRA_GBE_DMA_RX4    (CSRA_GBE_BASE+0xA0) // end
#define CSRA_GBE_DMA_RX5    (CSRA_GBE_BASE+0xA4) // end
#define CSRA_GBE_DMA_RX6    (CSRA_GBE_BASE+0xA8) // head (RO)
#define CSRA_GBE_DMA_RX7    (CSRA_GBE_BASE+0xAC) // head (RO)
#define CSRA_GBE_DMA_RX8    (CSRA_GBE_BASE+0xB0) // tail
#define CSRA_GBE_DMA_RX9    (CSRA_GBE_BASE+0xB4) // tail

#define CSRA_GBE_TX_DES        CSRA_GBE_DES_TX0
#define CSRA_GBE_TX_DES_SRC    CSRA_GBE_DES_TX2
#define CSRA_GBE_TX_DMA_CTL    CSRA_GBE_DMA_TX0
#define CSRA_GBE_TX_DMA_STS    CSRA_GBE_DMA_TX1
#define CSRA_GBE_TX_DMA_START  CSRA_GBE_DMA_TX2
#define CSRA_GBE_TX_DMA_END    CSRA_GBE_DMA_TX4
#define CSRA_GBE_TX_DMA_HEAD   CSRA_GBE_DMA_TX6
#define CSRA_GBE_TX_DMA_TAIL   CSRA_GBE_DMA_TX8

#define CSRA_GBE_RX_DES        CSRA_GBE_DES_RX0
#define CSRA_GBE_RX_DES_DST    CSRA_GBE_DES_RX2
#define CSRA_GBE_RX_DMA_CTL    CSRA_GBE_DMA_RX0
#define CSRA_GBE_RX_DMA_STS    CSRA_GBE_DMA_RX1
#define CSRA_GBE_RX_DMA_START  CSRA_GBE_DMA_RX2
#define CSRA_GBE_RX_DMA_END    CSRA_GBE_DMA_RX4
#define CSRA_GBE_RX_DMA_HEAD   CSRA_GBE_DMA_RX6
#define CSRA_GBE_RX_DMA_TAIL   CSRA_GBE_DMA_RX8

//------------------------------------------------------------------------------
#define GBE_CTL_ie           31
#define GBE_CTL_phy_ready    30
#define GBE_CTL_phy_reset    30
#define GBE_CTL_speed         0
#define GBE_STS_ip           31
#define GBE_STS_phy_reset    30
#define GBE_STS_rgmii        29

#define GBE_TX_CONF_reset        0
#define GBE_TX_CONF_enable       1
#define GBE_TX_CONF_jumbo        2
#define GBE_TX_CONF_no_gen_crc   3

#define GBE_RX_CONF_reset        0
#define GBE_RX_CONF_enable       1
#define GBE_RX_CONF_jumbo        2
#define GBE_RX_CONF_no_chk_crc   3
#define GBE_RX_CONF_promiscuous  4

#define GBE_TX_DES_items         0
#define GBE_TX_DES_rooms        16
#define GBE_TX_DMA_full          1
#define GBE_TX_DMA_empty         0

#define GBE_RX_DES_bnum          0
#define GBE_RX_DES_items        16
#define GBE_RX_DMA_full          1
#define GBE_RX_DMA_empty         0

//------------------------------------------------------------------------------
#define GBE_CTL_ie_MSK           (0x1<<GBE_CTL_ie          )
#define GBE_CTL_phy_ready_MSK    (0x1<<GBE_CTL_phy_ready   )
#define GBE_CTL_phy_reset_MSK    (0x1<<GBE_CTL_phy_reset   )
#define GBE_CTL_speed_MSK        (0x3<<GBE_CTL_speed       )
#define GBE_STS_ip_MSK           (0x1<<GBE_STS_ip          )
#define GBE_STS_phy_reset_MSK    (0x1<<GBE_STS_phy_reset   )
#define GBE_STS_rgmii_MSK        (0x1<<GBE_STS_rgmii       )

#define GBE_TX_CONF_reset_MSK       (0x1<<GBE_TX_CONF_reset      )
#define GBE_TX_CONF_enable_MSK      (0x1<<GBE_TX_CONF_enable     )
#define GBE_TX_CONF_jumbo_MSK       (0x1<<GBE_TX_CONF_jumbo      )
#define GBE_TX_CONF_no_gen_crc_MSK  (0x1<<GBE_TX_CONF_no_gen_crc )
#define GBE_TX_DMA_bchunk_MSK       (0xFFFF)

#define GBE_RX_CONF_reset_MSK       (0x1<<GBE_RX_CONF_reset      )
#define GBE_RX_CONF_enable_MSK      (0x1<<GBE_RX_CONF_enable     )
#define GBE_RX_CONF_jumbo_MSK       (0x1<<GBE_RX_CONF_jumbo      )
#define GBE_RX_CONF_no_chk_crc_MSK  (0x1<<GBE_RX_CONF_no_chk_crc )
#define GBE_RX_CONF_promiscuous_MSK (0x1<<GBE_RX_CONF_promiscuous)
#define GBE_RX_DMA_bchunk_MSK       (0xFFFF)

#define GBE_TX_DES_items_MSK        (0xFFFF<<GBE_TX_DES_items    )
#define GBE_TX_DES_rooms_MSK        (0xFFFF<<GBE_TX_DES_rooms    )
#define GBE_TX_DMA_full_MSK         (0x1<<GBE_TX_DMA_full        )
#define GBE_TX_DMA_empty_MSK        (0x1<<GBE_TX_DMA_empty       )

#define GBE_RX_DES_bnum_MSK         (0xFFFF<<GBE_RX_DES_bnum     )
#define GBE_RX_DES_items_MSK        (0xFFFF<<GBE_RX_DES_items    )
#define GBE_RX_DMA_full_MSK         (0x1<<GBE_RX_DMA_full        )
#define GBE_RX_DMA_empty_MSK        (0x1<<GBE_RX_DMA_empty       )

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

//------------------------------------------------------------------------------
// actuallly these are pointer
static uint32_t tx_head ;
static uint32_t tx_tail ;
static uint32_t tx_start;
static uint32_t tx_end  ;

//------------------------------------------------------------------------------
// rooms  : returns the number of available rooms.
// head   : runting head value (not HW value)
// current: 0=read flag of hw, 1=use local value
static int gig_eth_mac_tx_get_rooms( uint16_t *rooms
                                   , uint32_t  head
                                   , int       current ) // determines which head
{
    if (rooms==NULL) return -1;
    volatile uint32_t value;
    tx_head = head;
    REGRD(CSRA_GBE_TX_DMA_TAIL , value); tx_tail  = value;
    uint8_t full ;
    uint8_t empty;
    if (current) {
        if (head==tx_tail) { full = 1; empty = 0; }
        else               { full = 0; empty = 0; }
    } else {
        REGRD(CSRA_GBE_TX_DMA_STS  , value);
        full   = value&GBE_TX_DMA_full_MSK ;
        empty  = value&GBE_TX_DMA_empty_MSK;
    }
#if defined(VERBOSE)
static int y=0;
printf("%s() %d current=%d tx_tail=0x%08X head=0x%08X full/empyt=%d/%d\n",
__FUNCTION__, y++, current, tx_tail, head, full, empty); fflush(stdout);
#endif
    //----------------------------------------------------------------------
    // calculate room
    if (empty) {
        //      Astart                Aend
        //      |--------------------|
        //      |--------------------|
        //       ||
        //      Tail==Head
        //
        //      Astart                Aend
        //      |--------------------|
        //      |--------------------|
        //                ||
        //               Tail==Head
        *rooms = tx_end - tx_head;
    } else if (full) {
        //      Astart                Aend
        //      |--------------------|
        //      |XXXXXXXXXXXXXXXXXXXX|
        //       ||
        //      Tail==Head
        //
        //      Astart                Aend
        //      |--------------------|
        //      |XXXXXXXXXXXXXXXXXXXX|
        //              ||
        //             Tail==Head
        *rooms = 0x0;
    } else if (tx_tail>tx_head) {
        //      Astart                Aend
        //      |--------------------|
        //      |XXX------------XXXXX|
        //          ||          ||
        //         Head        Tail
        *rooms = tx_tail - tx_head;
    } else {
        //      Astart                Aend
        //      |--------------------|
        //      |---XXXXXXXXXXXX-----|
        //          ||          ||
        //         Tail        Head
        *rooms = tx_end - tx_head;
    }

    return 0;
}

//------------------------------------------------------------------------------
static uint32_t rx_head ;
static uint32_t rx_tail ;
static uint32_t rx_start;
static uint32_t rx_end  ;

//------------------------------------------------------------------------------
// items  : returns the number of available rooms.
// tail   : runing head value (not HW value)
// current: 0=read flag of hw, 1=use local value
static int gig_eth_mac_rx_get_items( uint16_t *items
                                   , uint32_t  tail
                                   , int       current // determines which tail
                                                       // 1=SW-tail
                                                       // 0=HW flags
                                   )
{
    if (items==NULL) return -1;
    volatile uint32_t value;
    REGRD(CSRA_GBE_RX_DMA_HEAD , value); rx_head  = value;
    rx_tail = tail;
    uint8_t full ;
    uint8_t empty;
    if (current==0) {
        REGRD(CSRA_GBE_RX_DMA_STS  , value);
        full   = value&GBE_RX_DMA_full_MSK ;
        empty  = value&GBE_RX_DMA_empty_MSK;
    } else {
        if (tail==rx_head) { full = 0; empty = 1; }
        else               { full = 0; empty = 0; }
    }
    //----------------------------------------------------------------------
    // calculate items
    if (empty) {
        //      Astart                Aend
        //      |--------------------|
        //      |--------------------|
        //       ||
        //      Tail==Head
        *items = 0x0;
    } else if (full) {
        //      Astart                Aend
        //      |--------------------|
        //      |XXXXXXXXXXXXXXXXXXXX|
        //       ||
        //      Tail==Head
        //
        //      Astart                Aend
        //      |--------------------|
        //      |XXXXXXXXXXXXXXXXXXXX|
        //             ||
        //         Tail==Head
        //
        //      Astart                Aend
        //      |--------------------|
        //      |XXXXXXXXXXXXXXXXXXXX|
        //                          ||
        //                      Tail==Head
        //*items = rx_end - rx_start;
        *items = rx_end - rx_tail;
    } else if (rx_tail>rx_head) {
        //      Astart                Aend
        //      |--------------------|
        //      |XXX------------XXXXX|
        //          ||          ||
        //         Head        Tail
        *items = rx_end - rx_tail;
    } else {
        //      Astart                Aend
        //      |--------------------|
        //      |---XXXXXXXXXXXX-----|
        //          ||          ||
        //         Tail        Head
        *items = rx_head - rx_tail;
    }

    return 0;
}

//------------------------------------------------------------------------------
//
// return == 0 on success
// return >0 the num of bytes has been sent
// return -1 on failture
// It moves packet data in the host memory to the frame memory.
int gig_eth_mac_send( uint8_t  *buf // host pointer
                    , uint16_t  bnum // num of byte: dst-src-payload
                    , int       time_out) // 0=blocking
{
    volatile uint32_t value;
    int num = 0;
    //--------------------------------------------------------------------------
#undef  VERBOSE
#if defined(VERBOSE)
int idz;
printf("%s() [%d] ", __FUNCTION__, bnum);
for (idz=0; idz<bnum; idz++) {
     printf("%02X:", buf[idz]);
}
printf("\n");
#endif
    //--------------------------------------------------------------------------
    // check full or not of TX-frame-buffer-memory
    num = 0;
    do { REGRD(CSRA_GBE_DMA_TX1, value);
         if (!(value&GBE_TX_DMA_full_MSK)) break;
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return -1;
    //--------------------------------------------------------------------------
    // check available descriptor-room of TX-descriptor-FIFO
    uint16_t rooms;
    num = 0;
    do { if (gig_eth_mac_peek_descriptor_tx ( &rooms )<0) return -1;
         if (rooms>0) break;
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return -1;
#if defined(VERBOSE)
printf("%s() tx descriptor rooms=%d\n", __FUNCTION__, rooms);
#endif
    //--------------------------------------------------------------------------
    // align check
    uint32_t head, src;
    REGRD(CSRA_GBE_TX_DMA_HEAD, head);
    if (head%4) return -1; // need to be word-aligned
#if defined(VERBOSE)
printf("%s() tx head=0x%08X\n", __FUNCTION__, (unsigned int)head);
#endif
    src = head;
    //--------------------------------------------------------------------------
    uint32_t *loc = (uint32_t*)buf;
    uint16_t brem = bnum;
    uint8_t  conti=0;
    while (brem>0) {
#if defined(VERBOSE)
printf("%s() tx brem=%d\n", __FUNCTION__, brem);
#endif
        // check frame-buffer rooms to fill
        do { if (gig_eth_mac_tx_get_rooms(&rooms, head, conti)) return -1;
             conti = 1; // now on: conti=1: use 'head' in order to reflect current move
        } while (rooms==0);
#if defined(VERBOSE)
printf("%s() tx descriptor rooms=%d\n", __FUNCTION__, rooms);
#endif
        if (rooms>=brem) { // sufficient room to fill packet
            if (brem/4>0) {
                // what if (brem/4) is too big BFM to handle.
#if defined(VERBOSE)
printf("%s() tx REGWRB(0x%08X, loc, %d)\n", __FUNCTION__, (unsigned int)head, brem/4);
#endif
                REGWRB(head, loc, brem/4); // it may cause page-fault due to non-word aligned packet
                head += (brem/4)*4;
                brem -= (brem/4)*4;
                if (head>tx_end) return -1;
                if (head==tx_end) head = tx_start;
            }
            if (brem>=4) {
#if defined(VERBOSE)
printf("%s() brem should be less than 4, but %d\n", __FUNCTION__, brem);
#endif
                return -1;
            }
            if (brem>0) {
                if (brem==1) value =  buf[bnum-1];
                if (brem==2) value = (buf[bnum-1]<<8)|buf[bnum-2];
                if (brem==3) value = (buf[bnum-1]<<16)|(buf[bnum-2]<<8)|buf[bnum-3];
#if defined(VERBOSE)
printf("%s() tx REGWR(0x%08X, 0x%08X)\n", __FUNCTION__, (unsigned int)head, (unsigned int)value);
#endif
                REGWR(head, value); // it may cause page-fault due to non-word aligned packet
                head += brem;
                brem  = 0;
                if (head>tx_end) return -1;
                if (head==tx_end) head = tx_start;
            }
        } else {
            // what if (rooms/4) is too big BFM to handle.
            if (rooms%4) return -1; // should be word aligned
#if defined(VERBOSE)
printf("%s() tx REGWRB(0x%08X, loc, %d)\n", __FUNCTION__, (unsigned int)head, rooms/4);
#endif
            REGWRB(head, loc, rooms/4); // it may cause page-fault due to non-word aligned packet
            head += rooms;
            loc  += rooms;
            brem -= rooms;
            if (head>tx_end) return -1;
            if (head==tx_end) head = tx_start;
        }
    }
    //--------------------------------------------------------------------------
    // update head
#if defined(VERBOSE)
printf("%s() tx head=0x%08X to update\n", __FUNCTION__, (unsigned int)head);
#endif
    head = ((head+3)>>2)<<2; // make word aligned
    if (head>tx_end) return -1;
    if (head==tx_end) head = tx_start;
    REGWR(CSRA_GBE_TX_DMA_HEAD, head);
#if defined(VERBOSE)
REGRD(CSRA_GBE_TX_DMA_HEAD, value); printf("%s() tx head=0x%08X updated\n", __FUNCTION__, (unsigned int)value);
#endif
    //--------------------------------------------------------------------------
    // update tx descriptor
    REGWR(CSRA_GBE_TX_DES_SRC, src);
    value = bnum|(1<<31);
    REGWR(CSRA_GBE_TX_DES, value);
    return bnum;
#undef VERBOSE
}

//------------------------------------------------------------------------------
// This version does update tail when any data movement occurs.
//
// return == 0 on success
// return >0 the num of bytes has been received
// return <0 on failture
//
// -1: timeout while waiting RX DESCriptor
// -2: bnum and to_read mis-match
// -3: tail is not word aligned
// -4: fail to get items and tail
// -5: tail overtakes head
// -6: brem should be less than or equal 4
// -7: tail exceed the end of buffer
// -8: tail should be word aligned
// -9: itmes should be word aligned
// -10: tail exceed the end of buffer
// -11: tail exceed the end of buffer
int gig_eth_mac_receive( uint8_t  *buf
                       , uint16_t  bnum // num of byte: dst-src-payload
                                        // if not known use 0
                       , int       time_out) // 0=blocking
{
    volatile uint32_t value;
#undef  VERBOSE
#if defined(VERBOSE)
printf("%s()\n", __FUNCTION__); fflush(stdout);
#endif
    //--------------------------------------------------------------------------
    // wait RX descriptor
    int num = 0;
    do { REGRD(CSRA_GBE_RX_DES, value);
         if ((value&GBE_RX_DES_items_MSK)) break;
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return -1;
    uint16_t to_read = (value&GBE_RX_DES_bnum_MSK)>>GBE_RX_DES_bnum;
#if defined(VERBOSE)
printf("%s() rx descriptor bnum=%d\n", __FUNCTION__, to_read);
    if ((bnum!=0)&&(to_read!=bnum)) {
printf("%s() to_read(%d) and bnum(%d) mis-match\n", __FUNCTION__, to_read, bnum);
        return -2;
    }
#endif
    //--------------------------------------------------------------------------
    // get tail
    uint32_t tail;
    REGRD(CSRA_GBE_RX_DES_DST, tail);
    if (tail%4) return -3; // need to be word-aligned
#if defined(VERBOSE)
printf("%s() rx tail=0x%08X\n", __FUNCTION__, (unsigned int)tail); fflush(stdout);
#endif
    //--------------------------------------------------------------------------
    uint16_t brem=to_read;
    uint32_t *loc=(uint32_t*)buf;
  //uint8_t  conti=0;
    uint16_t items;
    while (brem>0) {
        #if 0
        do { if (gig_eth_mac_rx_get_items(&items, tail, conti)) return -4;
             conti = 1; // use 'tail' in order to reflect current move
        } while (items==0);
        #else
        do { if (gig_eth_mac_rx_get_items(&items, tail, 0)) return -4;
        } while (items==0);
        #endif
        if (items>=brem) { // sufficient items to read
            if (brem/4>0) {
#if defined(VERBOSE)
printf("%s() rx REGRDB(0x%08X, loc, %d) %d\n", __FUNCTION__, (unsigned int)tail, brem/4, items);
#endif
                REGRDB(tail, loc, brem/4);
                tail += (brem/4)*4;
                brem -= (brem/4)*4;
                if (tail>rx_end) return -5;
                if (tail==rx_end) tail = rx_start;
            }
            if (brem>=4) {
#if defined(VERBOSE)
printf("%s() brem should be less than 4, but %d\n", __FUNCTION__, brem);
#endif
                return -6;
            }
            if (brem>0) {
                REGRD(tail, value);
#if defined(VERBOSE)
printf("%s() rx REGRD(0x%08X, 0x%08X)\n", __FUNCTION__, (unsigned int)tail, (unsigned int)value);
#endif
                if (brem==1) { buf[to_read-1] =  value&0xFF; }
                if (brem==2) { buf[to_read-1] = (value&0xFF00)>>8;    buf[to_read-2] = value&0xFF; }
                if (brem==3) { buf[to_read-1] = (value&0xFF0000)>>16; buf[to_read-2] = (value&0xFF00)>>8; buf[to_read-3] = value&0xFF; }
                tail += brem;
                brem  = 0;
                if (tail>rx_end) return -7;
                if (tail==rx_end) tail = rx_start;
            }
        } else {
            if (tail%4) return -8; // should be word aligned
            if (items%4) return -9; // should be word aligned
#if defined(VERBOSE)
printf("%s() tx REGRDB(0x%08X, loc, %d)\n", __FUNCTION__, (unsigned int)tail, items/4);
#endif
            REGRDB(tail, loc, items/4);
            tail += items;
            loc  += items;
            brem -= items;
            if (tail>rx_end) return -10;
            if (tail==rx_end) tail = rx_start;
        }
        //--------------------------------------------------------------------------
        // update tail
#if defined(VERBOSE)
printf("%s() rx tail=0x%08X to update\n", __FUNCTION__, (unsigned int)tail);
#endif
        tail = ((tail+3)>>2)<<2; // make word aligned
        if (tail>rx_end) return -11;
        if (tail==rx_end) tail = rx_start;
        REGWR(CSRA_GBE_RX_DMA_TAIL, tail);
#if defined(VERBOSE)
REGRD(CSRA_GBE_RX_DMA_TAIL, value); printf("%s() rx tail=0x%08X updated\n", __FUNCTION__, (unsigned int)value);
#endif
    }
    //--------------------------------------------------------------------------
    // pop one descriptor
    value = (1<<31);
    REGWR(CSRA_GBE_RX_DES, value);
#if defined(VERBOSE)
printf("%s() tx REGWR(0x%08X, 0x%08X)\n", __FUNCTION__, CSRA_GBE_RX_DES, (unsigned int)value);
#endif
#undef VERBOSE
    return to_read;
}

//--------------------------------------------------------------------
// keep other bits
// =0:disable, !=0:enable
int gig_eth_mac_interrupt( int enable )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_CONTROL, value);
    if (enable) value |= GBE_CTL_ie_MSK;
    else        value &=~GBE_CTL_ie_MSK;
    REGWR(CSRA_GBE_CONTROL, value);

    return 0;
}

//--------------------------------------------------------------------
// pt: return 0 for non IP
//
// return 0 on success
// return -1 when pointer is invalid
int gig_eth_mac_check_ip( uint8_t *pt )
{
    if (pt==NULL) return -1;

    volatile uint32_t value;
    REGRD(CSRA_GBE_STATUS, value);
    if (value&GBE_STS_ip_MSK) *pt = 1;
    else                      *pt = 0;

    return 0;
}

//--------------------------------------------------------------------
// clear ip bit, while keep other bits
int gig_eth_mac_clear_ip( void )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_STATUS, value);
    value |= GBE_STS_ip_MSK;
    REGWR(CSRA_GBE_STATUS, value);

    return 0;
}

//--------------------------------------------------------------------
// It does not push any entry of TX descrptor.
//
// return the num of rooms including 0.
// return negative vlaue when error occurs.
//
int gig_eth_mac_peek_descriptor_tx ( uint16_t *rooms )
{
#if defined(VERBOSE)
static int x=0;
printf("%s() %d\n", __FUNCTION__, x++); fflush(stdout);
#endif
    volatile uint32_t value;
    REGRD(CSRA_GBE_DES_TX0, value); // {rx_fifo_items,rx_fifo_bnum}
                                    // rx_fifo_bnum is valid when rx_fifo_items>0
    if (rooms!=NULL) *rooms = (value&GBE_TX_DES_rooms_MSK)>>GBE_TX_DES_rooms;

    return (value&GBE_TX_DES_rooms_MSK)>>GBE_TX_DES_rooms;
}

//--------------------------------------------------------------------
// It pushes an entry of TX descrptor.
//
// ptr:      pointer to variable to store address to read packet data
// bnum:     the number of bytes to read from *pkt
// time_out: 0=blocking until a descriptor available
//
// return 0 on success
// return 1 on time-out
int gig_eth_mac_push_descriptor_tx( uint32_t ptr
                                  , uint16_t bnum
                                  , int      time_out)
{
    volatile uint32_t value;
    int num = 0;
    do { REGRD(CSRA_GBE_DES_TX0, value); // {tx_fifo_rooms,tx_fifo_items}
                                          // tx_fifo_items has no meaning
         if (value&GBE_TX_DES_rooms_MSK) break;
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return 1;

    // push an entry
    REGWR(CSRA_GBE_DES_TX2, ptr);
    value = (1<<31)|bnum;
    REGWR(CSRA_GBE_DES_TX0, value);

    return 0;
}

//--------------------------------------------------------------------
// It does not pop any entry of RX descrptor.
//
// return the num of items including 0.
// return negative vlaue when error occurs.
//
int gig_eth_mac_peek_descriptor_rx ( uint16_t *items
                                   , uint16_t *bnum  )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_DES_RX0, value); // {rx_fifo_items,rx_fifo_bnum}
                                    // rx_fifo_bnum is valid when rx_fifo_items>0
    if (items!=NULL) *items = (value&GBE_RX_DES_items_MSK)>>GBE_RX_DES_items;
    if (bnum!=NULL)  *bnum  = (value&GBE_RX_DES_bnum_MSK);

    return (value&GBE_RX_DES_items_MSK)>>GBE_RX_DES_items;
}

//--------------------------------------------------------------------
// It pops an entry of RX descrptor.
//
// ptr:      pointer to variable to store address to read packet data
// bnum:     the number of bytes to read from *pkt
// time_out: 0=blocking until a descriptor available
//
// return 0 on success
// return 1 on time-out
int gig_eth_mac_pop_descriptor_rx ( uint32_t *ptr
                                  , uint16_t *bnum
                                  , int       time_out)
{
    volatile uint32_t value;
    int num = 0;
    do { REGRD(CSRA_GBE_DES_RX0, value); // {rx_fifo_items,rx_fifo_bnum}
                                          // rx_fifo_bnum is valid when rx_fifo_items>0
         if (value&GBE_RX_DES_items_MSK) break;
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return 1;
    
    if (bnum!=NULL) *bnum = (value&GBE_RX_DES_bnum_MSK);
    // get address
    REGRD(CSRA_GBE_DES_RX2, value);
    if (ptr!=NULL) *ptr = value;

    // remove one entry from descriptor fifo
    value = 1<<31;
    REGWR(CSRA_GBE_DES_RX0, value);

    return 0;
}

//--------------------------------------------------------------------
// conf_mac_addr[47:40] = mac[0] = WDATA[ 7: 0]
// conf_mac_addr[39:32] = mac[1] = WDATA[15: 8]
// conf_mac_addr[31:24] = mac[2] = WDATA[23:16]
// conf_mac_addr[23:16] = mac[3] = WDATA[31:24]
// conf_mac_addr[16: 8] = mac[4] = WDATA[ 7: 0]
// conf_mac_addr[ 7: 0] = mac[5] = WDATA[15: 8]
//
// mac[0] will be the MSByte - bit 0 determines boradcasting or not.
int gig_eth_mac_set_mac_addr( uint8_t mac[6] )
{
    volatile uint32_t value;
    value = mac[3]<<24
          | mac[2]<<16
          | mac[1]<< 8
          | mac[0];
    REGWR(CSRA_GBE_MAC_ADDR0, value);
    value = mac[5]<<8
          | mac[4];
    REGWR(CSRA_GBE_MAC_ADDR1, value);
    return 0;
}

//--------------------------------------------------------------------
// mac[0] will be the MSByte - bit 0 determines boradcasting or not.
int gig_eth_mac_get_mac_addr( uint8_t mac[6] )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_MAC_ADDR0, value);
    mac[0] = (value&0xFF);
    mac[1] = (value&0xFF00)>>8;
    mac[2] = (value&0xFF0000)>>16;
    mac[3] = (value&0xFF000000)>>24;
    REGRD(CSRA_GBE_MAC_ADDR1, value);
    mac[4] = (value&0xFF);
    mac[5] = (value&0xFF00)>>8;
    return 0;
}

//--------------------------------------------------------------------
// Frame buffer
//   high     |        |
//            |        |
//   end   -> |        |
//            +--------+
//            |        |
//            |        | <- head
//            |XXXXXXXX|
//            |XXXXXXXX|
//            |XXXXXXXX| <- tail
//   start -> |        |
//            +--------+
//            |        |
//   low      |        |
//
// conf_tx_reset should be applied in order to make effective.
int gig_eth_mac_set_frame_buffer_tx( uint32_t start
                                   , uint32_t end )
{
    volatile uint32_t value=0;
    REGRD(CSRA_GBE_CONF_TX0, value);
    if (value&GBE_TX_CONF_enable_MSK) {
        // frame buffer should be set when MAC is not active
        return -1;
    }
    value = (unsigned int)start;
    REGWR(CSRA_GBE_TX_DMA_START, value); // rx_addr_start
    REGWR(CSRA_GBE_TX_DMA_HEAD , value); // rx_addr_head
    REGWR(CSRA_GBE_TX_DMA_TAIL , value); // rx_addr_tail (read-only) hw update it
    value = (unsigned int)end;
    REGWR(CSRA_GBE_TX_DMA_END, end); // rx_addr_end

    tx_start = start;
    tx_end   = end;
    tx_head  = start;
    tx_tail  = start;

    gig_eth_mac_tx_enable(1, 0); // make a reset auto return
    return 0;
}
int gig_eth_mac_get_frame_buffer_tx( uint32_t *start
                                   , uint32_t *end
                                   , uint32_t *head
                                   , uint32_t *tail)
{
    uint32_t value;
    if (start!=NULL) { REGRD(CSRA_GBE_TX_DMA_START, value); *start = value; }
    if (end  !=NULL) { REGRD(CSRA_GBE_TX_DMA_END  , value); *end   = value; }
    if (head !=NULL) { REGRD(CSRA_GBE_TX_DMA_HEAD , value); *head  = value; }
    if (tail !=NULL) { REGRD(CSRA_GBE_TX_DMA_TAIL , value); *tail  = value; }
    return 0;
}

//--------------------------------------------------------------------
// Frame buffer
//   high     |        |
//            |        |
//   end   -> |        |
//            +--------+
//            |        |
//            |        | <- head
//            |XXXXXXXX|
//            |XXXXXXXX|
//            |XXXXXXXX| <- tail
//   start -> |        |
//            +--------+
//            |        |
//   low      |        |
//
// conf_rx_reset should be applied in order to make effective.
int gig_eth_mac_set_frame_buffer_rx( uint32_t start
                                   , uint32_t end )
{
    volatile uint32_t value=0;
    REGRD(CSRA_GBE_CONF_RX0, value);
    if (value&GBE_RX_CONF_enable_MSK) {
        // frame buffer should be set when MAC is not active
        return -1;
    }
    value = (unsigned int)start;
    REGWR(CSRA_GBE_RX_DMA_START, value); // rx_addr_start
    REGWR(CSRA_GBE_RX_DMA_HEAD , value); // rx_addr_head (read-only) hw update it
    REGWR(CSRA_GBE_RX_DMA_TAIL , value); // rx_addr_tail
    value = (unsigned int)end;
    REGWR(CSRA_GBE_RX_DMA_END, end); // rx_addr_end

    rx_start = start;
    rx_end   = end;
    rx_head  = start;
    rx_tail  = start;

    gig_eth_mac_rx_enable(1, 0); // make a reset auto return
    return 0;
}
int gig_eth_mac_get_frame_buffer_rx( uint32_t *start
                                   , uint32_t *end
                                   , uint32_t *head
                                   , uint32_t *tail)
{
    uint32_t value;
    if (start!=NULL) { REGRD(CSRA_GBE_RX_DMA_START, value); *start = value; }
    if (end  !=NULL) { REGRD(CSRA_GBE_RX_DMA_END  , value); *end   = value; }
    if (head !=NULL) { REGRD(CSRA_GBE_RX_DMA_HEAD , value); *head  = value; }
    if (tail !=NULL) { REGRD(CSRA_GBE_RX_DMA_TAIL , value); *tail  = value; }
    return 0;
}

//--------------------------------------------------------------------
// conf_tx_jumbo_en
// conf_tx_no_gen_crc
// conf_tx_bchunk:        num of bytes for a burst
// conf_rx_jumbo_en
// conf_rx_no_chk_crc
// conf_rx_promiscuous
// conf_rx_bchunk:        num of bytes for a burst
int gig_eth_mac_set_config( uint8_t   conf_tx_jumbo_en
                          , uint8_t   conf_tx_no_gen_crc
                          , uint16_t  conf_tx_bchunk
                          , uint8_t   conf_rx_jumbo_en
                          , uint8_t   conf_rx_no_chk_crc
                          , uint8_t   conf_rx_promiscuous
                          , uint16_t  conf_rx_bchunk )
{
#define SET_CONF(A,M)\
        if ((A)) value |= (M); else value &= ~(M);

    volatile uint32_t value=0;
    SET_CONF(conf_tx_jumbo_en  ,GBE_TX_CONF_jumbo_MSK     )
    SET_CONF(conf_tx_no_gen_crc,GBE_TX_CONF_no_gen_crc_MSK)
    REGWR(CSRA_GBE_CONF_TX0, value);
    value = conf_rx_bchunk&GBE_TX_DMA_bchunk_MSK;
    REGWR(CSRA_GBE_DMA_TX0, value);


    value=0;
    SET_CONF(conf_rx_jumbo_en   ,GBE_RX_CONF_jumbo_MSK      )
    SET_CONF(conf_rx_no_chk_crc ,GBE_RX_CONF_no_chk_crc_MSK )
    SET_CONF(conf_rx_promiscuous,GBE_RX_CONF_promiscuous_MSK)
    REGWR(CSRA_GBE_CONF_RX0, value);
    value = conf_rx_bchunk&GBE_RX_DMA_bchunk_MSK;
    REGWR(CSRA_GBE_DMA_RX0, value);

#undef SET_CONF
    return 0;
}

//--------------------------------------------------------------------
// conf_tx_reset
// conf_tx_en
// conf_tx_jumbo_en
// conf_tx_no_gen_crc
// conf_tx_bchunk:        num of bytes for a burst
// conf_rx_reset
// conf_rx_en
// conf_rx_jumbo_en
// conf_rx_no_chk_crc
// conf_rx_promiscuous
// conf_rx_bchunk:        num of bytes for a burst
int gig_eth_mac_get_config( uint8_t  *conf_tx_reset
                          , uint8_t  *conf_tx_en
                          , uint8_t  *conf_tx_jumbo_en
                          , uint8_t  *conf_tx_no_gen_crc
                          , uint16_t *conf_tx_bchunk    
                          , uint8_t  *conf_rx_reset
                          , uint8_t  *conf_rx_en
                          , uint8_t  *conf_rx_jumbo_en
                          , uint8_t  *conf_rx_no_chk_crc
                          , uint8_t  *conf_rx_promiscuous
                          , uint16_t *conf_rx_bchunk )    
{
#define GET_CONF(A,M)\
        if ((A)!=NULL) { if (value&(M)) *(A) = 0x1; else *(A) = 0x0; }
        
    volatile uint32_t value=0;
    REGRD(CSRA_GBE_CONF_TX0, value);
    GET_CONF(conf_tx_reset     ,GBE_TX_CONF_reset_MSK     )
    GET_CONF(conf_tx_en        ,GBE_TX_CONF_enable_MSK    )
    GET_CONF(conf_tx_jumbo_en  ,GBE_TX_CONF_jumbo_MSK     )
    GET_CONF(conf_tx_no_gen_crc,GBE_TX_CONF_no_gen_crc_MSK)
    if (conf_tx_bchunk!=NULL) {
        REGRD(CSRA_GBE_DMA_TX0, value);
        *conf_tx_bchunk = value&GBE_TX_DMA_bchunk_MSK;
    }

    REGRD(CSRA_GBE_CONF_RX0, value);
    GET_CONF(conf_rx_reset      ,GBE_RX_CONF_reset_MSK      )
    GET_CONF(conf_rx_en         ,GBE_RX_CONF_enable_MSK     )
    GET_CONF(conf_rx_jumbo_en   ,GBE_RX_CONF_jumbo_MSK      )
    GET_CONF(conf_rx_no_chk_crc ,GBE_RX_CONF_no_chk_crc_MSK )
    GET_CONF(conf_rx_promiscuous,GBE_RX_CONF_promiscuous_MSK)
    if (conf_rx_bchunk!=NULL) {
        REGRD(CSRA_GBE_DMA_RX0, value);
        *conf_rx_bchunk = value&GBE_RX_DMA_bchunk_MSK;
    }

    return 0;
}

//------------------------------------------------------------------------------
// tx_reset:  1=reset pulse of conf_tx_reset (auto return 0)
// tx_enable: 1=enable
int gig_eth_mac_tx_enable( uint8_t tx_reset
                         , uint8_t tx_enable )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_CONF_TX0, value);
    if (tx_reset)  value  = GBE_TX_CONF_reset_MSK;
    else           value &=~GBE_TX_CONF_reset_MSK;
    if (tx_enable) value |= GBE_TX_CONF_enable_MSK;
    else           value &=~GBE_TX_CONF_enable_MSK;
    REGWR(CSRA_GBE_CONF_TX0, value);
    return 0;
}

//------------------------------------------------------------------------------
// rx_reset:  1=reset pulse of conf_rx_reset (auto return 0)
// rx_enable: 1=enable
int gig_eth_mac_rx_enable( uint8_t rx_reset
                         , uint8_t rx_enable )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_CONF_RX0, value);
    if (rx_reset) value |= GBE_RX_CONF_reset_MSK;
    else          value &=~GBE_RX_CONF_reset_MSK;
    if (rx_enable) value |= GBE_RX_CONF_enable_MSK;
    else           value &=~GBE_RX_CONF_enable_MSK;
    REGWR(CSRA_GBE_CONF_RX0, value);
    return 0;
}

//------------------------------------------------------------------------------
// phy_reset:  1=caluse phy_reset, auto return to normal after >10msec.
//             0=simply return currtne phy_reset_n (0 means reset status)
// wait: 0=do not wait until PHY_RESET_N returns 1
//       1=wait until PHY_RESET_N rturns 1 and additional 5msec.
//
// return current PHY-RESET-N value
// return 0 when PHY-RESET-N is progress
// return 1 when PHY-RESET-N is high, i.e., normal
//
// Note for 88E1111 to reset
// 1. Keep Marvell PHYs' RESET_N pin (enta_resetn and enetb_resetn) to be low
//    for 10 ms (Marvell PHY spec is 10 ms min.).
//    If the reset duration is short, the Marvell PHY might transmit K30.7
//    (octet value 0xFE) instead of IDLE to the Arria 10 device.
// 2. Wait for 5 ms after the reset deassertion (Marvell PHY spec is 5 ms min.).
//    MDIO is ready now.

int gig_eth_phy_reset( uint8_t phy_reset
                     , int     wait )
{
    volatile uint32_t value;
    if (phy_reset) {
        REGRD(CSRA_GBE_CONTROL, value);
        value |= GBE_CTL_phy_reset_MSK;
        REGWR(CSRA_GBE_CONTROL, value);
    }
    while (wait&&(value&GBE_CTL_phy_reset_MSK)) {
           REGRD(CSRA_GBE_CONTROL, value);
    }
    REGRD(CSRA_GBE_STATUS, value);
    return (value&GBE_STS_phy_reset_MSK) ? 1 : 0;
}

//------------------------------------------------------------------------------
// It check MACs if it runs RGMII mode.
//  - RGMII mode will be 1, when 'RGMII' macro is defined when synthesis of MAC.
//
// Retrun 1 when RGMII mode.
// Return 0 when GMII mode.
int gig_eth_mac_rgmii( void )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_STATUS, value);
    return (value&GBE_STS_rgmii_MSK) ? 1 : 0;
}

//------------------------------------------------------------------------------
// It checks MAC if it is ready.
//
// Retrun 1 when ready.
// Return 0 when not ready.
int gig_eth_mac_ready( void )
{
    volatile uint32_t value;
    REGRD(CSRA_GBE_CONTROL, value);
    return (value&GBE_CTL_phy_ready_MSK) ? 1 : 0;
}

//------------------------------------------------------------------------------
#ifndef COMPACT_CODE
#define AMBA_AXI4
#define read_and_check(A,N,E)\
        do {\
        REGRD((A),value);\
        if (value!=(E)) {\
            printf("MAC %10s A=0x%08X D=0x%08X, but 0x%08X expected\n", (N), (A), (unsigned int)value, (E));\
        } else { printf("MAC %10s A=0x%08X D=0x%08X OK\n", (N), (A), (unsigned int)value); }\
        } while (0)

void gig_eth_mac_csr_check ( void )
{
     uint32_t value;

     read_and_check(CSRA_GBE_CONTROL  , "CONTROL  ", 0x00000002);
     read_and_check(CSRA_GBE_STATUS   , "STATUS   ", 0x00000000);

     REGRD(CSRA_GBE_VERSION,value);
     printf("MAC %10s A=0x%08X D=0x%08X\n", "VERSION  ", CSRA_GBE_VERSION, (unsigned int)value);

     read_and_check(CSRA_GBE_MAC_ADDR0, "MAC_ADDR0", 0x56341202);
     read_and_check(CSRA_GBE_MAC_ADDR1, "MAC_ADDR1", 0x00000178);

     read_and_check(CSRA_GBE_CONF_TX0 , "CONF_TX0 ", 0x00000000);
     read_and_check(CSRA_GBE_CONF_TX1 , "CONF_TX1 ", 0x00000000);
     read_and_check(CSRA_GBE_CONF_RX0 , "CONF_RX0 ", 0x00000000);
     read_and_check(CSRA_GBE_CONF_RX1 , "CONF_RX1 ", 0x00000000);

     read_and_check(CSRA_GBE_DES_TX0  , "DES_TX0  ", 0x0100000); // TX_DESCIPTOR_FAW=4
     read_and_check(CSRA_GBE_DES_TX1  , "DES_TX1  ", 0x0000000);
     read_and_check(CSRA_GBE_DES_TX2  , "DES_TX2  ", 0x0000000);
     read_and_check(CSRA_GBE_DES_TX3  , "DES_TX3  ", 0x0000000);

     read_and_check(CSRA_GBE_DES_RX0  , "DES_RX0  ", 0x0000000); // TX_DESCIPTOR_FAW=4
     read_and_check(CSRA_GBE_DES_RX1  , "DES_RX1  ", 0x0000000);
     read_and_check(CSRA_GBE_DES_RX2  , "DES_RX2  ", 0x0000000);
     read_and_check(CSRA_GBE_DES_RX3  , "DES_RX3  ", 0x0000000);

     #ifndef AMBA_AXI4
     read_and_check(CSRA_GBE_DMA_TX0  , "DMA_TX0  ", 0x00000040);
     #else
     read_and_check(CSRA_GBE_DMA_TX0  , "DMA_TX0  ", 0x00000400);
     #endif
     read_and_check(CSRA_GBE_DMA_TX1  , "DMA_TX1  ", 0x00000001);
     read_and_check(CSRA_GBE_DMA_TX2  , "DMA_TX2  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX3  , "DMA_TX3  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX4  , "DMA_TX4  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX5  , "DMA_TX5  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX6  , "DMA_TX6  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX7  , "DMA_TX7  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX8  , "DMA_TX8  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_TX9  , "DMA_TX9  ", 0x00000000);

     #ifndef AMBA_AXI4
     read_and_check(CSRA_GBE_DMA_RX0  , "DMA_RX0  ", 0x00000040);
     #else
     read_and_check(CSRA_GBE_DMA_RX0  , "DMA_RX0  ", 0x00000400);
     #endif
     read_and_check(CSRA_GBE_DMA_RX1  , "DMA_RX1  ", 0x00000001);
     read_and_check(CSRA_GBE_DMA_RX2  , "DMA_RX2  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX3  , "DMA_RX3  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX4  , "DMA_RX4  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX5  , "DMA_RX5  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX6  , "DMA_RX6  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX7  , "DMA_RX7  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX8  , "DMA_RX8  ", 0x00000000);
     read_and_check(CSRA_GBE_DMA_RX9  , "DMA_RX9  ", 0x00000000);
}
#endif

//------------------------------------------------------------------------------
// Revision History
//
// 2019.05.20: 'gig_eth_mac_interrupt()' <- gig_eth_interrupt()
// 2019.03.01: 'gig_eth_mac_set_config()' bug-fixed.
//             'gig_eth_mac_get_config()' bug-fixed.
// 2018.10.17: 'gig_eth_mac_rx_get_items()' bug-fixed for full case.
//             'gig_eth_mac_receive()' updated.
// 2018.09.30: 'gig_eth_mac_send()' bug-fixed, which did not handle 4-byte payload
//              case.
//              'if (brem==2) value = (buf[bnum-2]<<8)|buf[bnum-1];'
//              should be
//              'if (brem==2) value = (buf[bnum-1]<<8)|buf[bnum-2];'
// 2018.07.20: 'gig_eth_phy_rgmii()' added.
// 2018.07.05: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
