//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2018.09.30.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "defines_system.h"
#include "gig_eth_mac_api.h"
#include "gig_eth_hsr_api.h"
#include "eth_ip_udp_pkt.h"
//------------------------------------------------------------------------------
#define PRT_MAC(A,B)\
        printf("%s 0x%02X%02X%02X%02X%02X%02X\n", (A)\
                   ,(B)[0],(B)[1],(B)[2],(B)[3],(B)[4],(B)[5])
//------------------------------------------------------------------------------
// (B): num of bytes to be send
#define PKT_GEN_SEND(B,T)\
        do { uint16_t type_leng = (B);\
             for (int idx=0; idx<(B); idx++) payload[idx] = idx+1;\
             int len = gen_eth_packet(buffer_tx, mac_dst, mac_src, pkt_type,\
                            type_leng, (B), payload);\
             if (verbose>=1) printf("[%d] ", (B));\
             if (verbose>=2) {\
                 for (int idy=0; idy<len; idy++) {\
                      printf("%02X:", buffer_tx[idy]);\
                 }\
                 if ((B)<46) {\
                     for (int idz=len; idz<60; idz++) {\
                          buffer_tx[idz] = 0x0;\
                          printf("%02X:", buffer_tx[idz]);\
                     }\
                 }\
                 uint32_t crc;\
                 crc = compute_eth_crc(buffer_tx, ((B)<46) ? 60 : len);\
                 printf("[%02X:",(unsigned char)(((crc&0x000000FF)    )&0xFF));\
                 printf("%02X:" ,(unsigned char)(((crc&0x0000FF00)>> 8)&0xFF));\
                 printf("%02X:" ,(unsigned char)(((crc&0x00FF0000)>>16)&0xFF));\
                 printf("%02X]" ,(unsigned char)(((crc&0xFF000000)>>24)&0xFF));\
             }\
             if (verbose>0) { printf("\n"); fflush(stdout);}\
             ret = gig_eth_mac_send(buffer_tx, len, (T));\
             if (ret<0) {\
                 printf("gig_eth_mac_send() causes error\n");\
             }\
        } while (0)

//------------------------------------------------------------------------------
// (B): num of bytes to be received, if positive. -1 for time-out
// (T): 0 for blocking, >0 number of tries
#define PKT_RCV(B,T)\
        do { ret = gig_eth_mac_receive(buffer_rx, (B), (T));\
             (B) = (ret<0) ? 0 : ret;\
             if (ret==-1) {\
                 if (verbose>=3) {\
                     printf("gig_eth_mac_receive() time-out\n");\
                 }\
             } else if (ret<0) {\
                 printf("gig_eth_mac_receive() causes error\n");\
             } else {\
                 if (verbose>=3) parser_eth_packet(buffer_rx, (B));\
                 if (verbose>=1) printf("[%d] ", (B));\
                 if (verbose>=2) {\
                     for (int idz=0; idz<(B); idz++) {\
                          printf("%02X:", buffer_rx[idz]);\
                     }\
                 }\
                 if (verbose>0) { printf("\n"); fflush(stdout); }\
             }\
        } while (0)
     
//------------------------------------------------------------------------------
// pkt_type: PKT_TYPE_BROADCAST,PKT_TYPE_VLAN,PKT_TYPE_HSR      
//
int eth_send_packet( uint8_t  mac_dst[6]
                   , uint8_t  mac_src[6]
                   , uint8_t  pkt_type
                   , uint16_t bnum // 1-1500
                   , int      timeout // 0 or <0 for blocking
                   , int      verbose    // verbose level
                   )
{
    int ret;
    uint8_t  buffer_tx[2*1024];
    uint8_t  payload[2*1024];
    PKT_GEN_SEND(bnum, (timeout<=0) ? 0 : timeout);
    return 0;
}
//------------------------------------------------------------------------------
// pkt_type: PKT_TYPE_BROADCAST,PKT_TYPE_VLAN,PKT_TYPE_HSR      
//
int eth_send_packets( uint8_t  mac_dst[6]
                    , uint8_t  mac_src[6]
                    , uint8_t  pkt_type
                    , int      verbose    // verbose level
                    , int      inter_mode // interactive mode
                    , uint16_t bnum_start // 1-1500
                    )
{
    int ret;
    uint8_t  buffer_tx[2*1024];
    uint8_t  payload[2*1024];
    while (1) {
       for (uint16_t bnum=bnum_start; bnum<=1500; bnum++) {
              if (inter_mode>0) { printf("[SND] Enter for %d(0x%X)-byte payload: ",
                                          bnum, bnum);
                            fflush(stdout);
                            getchar();
              }
              PKT_GEN_SEND(bnum, 0);
       }
    }
    return 0;
}

//------------------------------------------------------------------------------
int eth_receive_packet( int timeout  // 0 or <0 for blocking
                      , int verbose )
{
    int ret;
    uint8_t  buffer_rx[2*1024];
    uint16_t bnum, items;
    int num=0;
    do { ret = gig_eth_mac_peek_descriptor_rx ( &items, &bnum);
         if (ret>0) {
             PKT_RCV(bnum,(timeout<=0) ? 0 : timeout);
             if (ret>0) break;
         }
         num++;
    } while ((timeout<=0)||(num<timeout));
    return ((timeout>0)&&(num>=timeout)) ? -1 : bnum;
}

//------------------------------------------------------------------------------
// mode=0 for continue;
// mode>0 for interactive;
int eth_receive_packets( int verbose, int inter_mode )
{
    int ret;
    uint8_t  buffer_rx[2*1024];
    do { uint16_t items;
         uint16_t bnum;
         if (inter_mode>0) { printf("[RCV] Enter to receive: ");
                       fflush(stdout);
                       getchar();
         }
         if (gig_eth_mac_peek_descriptor_rx ( &items, &bnum )<0) {
             printf("gig_eth_mac_peek_descriptor_rx() causes error\n");
             continue;
         }
         while (items>0) {
             PKT_RCV(bnum,0);
             items--;
         }
    } while (1);
    return 0;
}

//------------------------------------------------------------------------------
// RAS
int eth_receive_after_send( uint8_t mac_dst[6]
                          , uint8_t mac_src[6]
                          , uint8_t pkt_type
                          , int     verbose
                          , int     inter_mode
                          )
{
    int ret;
    do { uint8_t  buffer_tx[2*1024];
         uint8_t  payload[2*1024];
         uint8_t  buffer_rx[2*1024];
         for (uint16_t bnum_tx=1; bnum_tx<=1500; bnum_tx++) {
              if (inter_mode>0) { printf("[SND] Enter for %d(0x%X)-byte payload: ",
                                    bnum_tx, bnum_tx);
                            fflush(stdout);
                            getchar();
              }
              PKT_GEN_SEND(bnum_tx, 0);
              if (ret>0) {
                  uint16_t bnum_rx;
                  PKT_RCV(bnum_rx,100000);
#if 0
                  if (ret<0) continue;
#else
                  if (ret<0) {printf("%s() receive time-out:", __FUNCTION__); fflush(stdout); getchar(); }
#endif
                  int error=0;
                  if ((buffer_tx[12]!=buffer_rx[12])&&(buffer_tx[13]!=buffer_rx[13])) {
                      if (verbose>=1) {
                          printf("packet length mis-match 0x%02X%02X:%02X%02X\n"
                                  ,buffer_tx[12],buffer_tx[13]
                                  ,buffer_rx[12],buffer_rx[13]);
                      }
                  }
                  error=0;
                  for (int idz=0; idz<6; idz++) {
                       if (buffer_tx[idz]!=buffer_rx[idz+6]) error++;
                       if (buffer_rx[idz]!=buffer_tx[idz+6]) error++;
                  }
                  if ((error!=0)&&(verbose>=1)) printf("MAC address wrong\n");
                  error = 0;
                  for (int idz=12; idz<bnum_tx; idz++) {
                       if (buffer_tx[idz]!=buffer_rx[idz]) error++;
                  }
                  if (error==0) printf("OK %d\n", bnum_tx);
                  else          printf("Mis-match %d out of %d\n", error, bnum_tx);
              }
        }
    } while (1);
    return 0;
}

//------------------------------------------------------------------------------
// SAR: Loopback
int eth_send_after_receive( int verbose )
{
    int ret;
    uint8_t  buffer_rx[2*1024];
    uint8_t *buffer_tx=(uint8_t*)buffer_rx;
    uint16_t bnum_rx, items;
    uint16_t bnum_tx;
    do { ret = gig_eth_mac_peek_descriptor_rx ( &items, &bnum_rx );
         if (ret<0) {
             printf("gig_eth_mac_peek_descriptor_rx() causes error\n");
             continue;
         }
         while ((ret>0)&&(items>0)) {
             PKT_RCV(bnum_rx,0);
             if (ret>0) {
                 parser_eth_packet(buffer_rx, bnum_rx);
                 //---------------------------------------------------------
                 // swap dst-src
                 uint8_t tmp;
                 for (int idx=0; idx<6; idx=idx+1) {
                      tmp              = buffer_rx[idx];
                      buffer_rx[idx]   = buffer_rx[idx+6];
                      buffer_rx[idx+6] = tmp;
                 }
                 bnum_tx = bnum_rx;
                 //---------------------------------------------------------
                 if (verbose>=1) printf("[%d] ", bnum_tx);
                 if (verbose>=2) {
                     for (int idz=0; idz<bnum_rx; idz++) {
                          printf("%02X:", buffer_rx[idz]);
                     }
                 }
                 if (verbose>0) { printf("\n"); fflush(stdout); }
                 //---------------------------------------------------------
                 if (gig_eth_mac_send(buffer_tx, bnum_tx, 0)<0) {
                     printf("gig_eth_mac_send() causes error\n");
                 }
             }
             items--;
         }
    } while (1);
}

//------------------------------------------------------------------------------
//  mac_addr[6]
//  conf_tx_jumbo_en=0x0
//  conf_tx_no_gen_crc=0x0
//  conf_tx_bchunk=4*32
//  conf_rx_jumbo_en=0x0
//  conf_rx_no_chk_crc=0x0
//  conf_rx_promiscuous=0x1
//  conf_rx_bchunk=4*32
int mac_init( uint8_t  mac_addr[6]
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
            , int      verbose )
{
   #define CHK_VER(A) do { if (verbose) printf(A); } while (0)
   //---------------------------------------------------------------------------
   uint8_t mac_tmp[6];
   gig_eth_mac_set_mac_addr(mac_addr);
   gig_eth_mac_get_mac_addr(mac_tmp);
   int err=0;
   for (int idx=0; idx<6; idx++) {
        if (mac_addr[idx]!=mac_tmp[idx]) {
            if (verbose) { printf("mac_addr[%d]=0x%02X:%02X mis-match\n",
                                   idx, mac_addr[idx], mac_tmp[idx]); }
            err++;
        }
   }
   if (err==0) { CHK_VER("mac_addr OK-match\n");
   } else      { CHK_VER("mac_addr mis-match\n"); return -1; }
   //---------------------------------------------------------------------------
   // need reset up update frame pointers
   gig_eth_mac_set_frame_buffer_tx(buff_tx_start
                                  ,buff_tx_start+buff_tx_size);
   gig_eth_mac_set_frame_buffer_rx(buff_rx_start
                                  ,buff_rx_start+buff_rx_size);
   gig_eth_mac_set_config(conf_tx_jumbo_en     //0     //uint8_t  conf_tx_jumbo_en
                         ,conf_tx_no_gen_crc   //0     //uint8_t  conf_tx_no_gen_crc
                         ,conf_tx_bchunk       //4*32  //uint16_t conf_tx_bchunk
                         ,conf_rx_no_chk_crc   //0     //uint8_t  conf_rx_no_chk_crc
                         ,conf_rx_jumbo_en     //0     //uint8_t  conf_rx_jumbo_en
                         ,conf_rx_promiscuous  //1     //uint8_t  conf_rx_promiscuous
                         ,conf_rx_bchunk     );//4*32);//uint16_t conf_rx_bchunk     
   //---------------------------------------------------------------------------
   // reset to update frame pointers
   uint8_t  conf_tx_reset=0x1;
   uint8_t  conf_tx_en=0x0;
   uint8_t  conf_rx_reset=0x1;
   uint8_t  conf_rx_en=0x0;
   gig_eth_mac_tx_enable(conf_tx_reset   //1  // tx_reset
                        ,conf_tx_en   ); //0);// tx_enable
   gig_eth_mac_rx_enable(conf_tx_reset   //1  // tx_reset
                        ,conf_tx_en   ); //0);// tx_enable
   //---------------------------------------------------------------------------
   uint32_t start, end, head, tail;
   gig_eth_mac_get_frame_buffer_tx(&start, &end, &head, &tail);
   if (start!=buff_tx_start)             {CHK_VER("TX start mis-match\n"); return -1; } else CHK_VER("TX start OK-match\n");
   if (end  !=buff_tx_start+buff_tx_size){CHK_VER("TX end mis-match\n");   return -1; } else CHK_VER("TX end OK-match\n");
   if (head !=buff_tx_start)             {CHK_VER("TX head mis-match\n");  return -1; } else CHK_VER("TX head OK-match\n");
   if (tail !=buff_tx_start)             {CHK_VER("TX tail mis-match\n");  return -1; } else CHK_VER("TX tail OK-match\n");
   gig_eth_mac_get_frame_buffer_rx(&start, &end, &head, &tail);
   if (start!=buff_rx_start)             {CHK_VER("RX start mis-match\n"); return -1; } else CHK_VER("RX start OK-match\n");
   if (end  !=buff_rx_start+buff_rx_size){CHK_VER("RX end mis-match\n");   return -1; } else CHK_VER("RX end OK-match\n");
   if (head !=buff_rx_start)             {CHK_VER("RX head mis-match\n");  return -1; } else CHK_VER("RX head OK-match\n");
   if (tail !=buff_rx_start)             {CHK_VER("RX tail mis-match\n");  return -1; } else CHK_VER("RX tail OK-match\n");
   gig_eth_mac_get_config( &conf_tx_reset          
                         , &conf_tx_en
                         , &conf_tx_jumbo_en
                         , &conf_tx_no_gen_crc
                         , &conf_tx_bchunk
                         , &conf_rx_reset
                         , &conf_rx_en
                         , &conf_rx_jumbo_en
                         , &conf_rx_no_chk_crc
                         , &conf_rx_promiscuous
                         , &conf_rx_bchunk );
   if (conf_tx_reset!=0)       CHK_VER("conf_tx_reset       mis-match\n"); else CHK_VER("conf_tx_reset       OK-match\n"); 
   if (conf_tx_en!=0)          CHK_VER("conf_tx_en          mis-match\n"); else CHK_VER("conf_tx_en          OK-match\n");
   if (conf_tx_jumbo_en!=0)    CHK_VER("conf_tx_jumbo_en    mis-match\n"); else CHK_VER("conf_tx_jumbo_en    OK-match\n");
   if (conf_tx_no_gen_crc!=0)  CHK_VER("conf_tx_no_gen_crc  mis-match\n"); else CHK_VER("conf_tx_no_gen_crc  OK-match\n");
   if (conf_tx_bchunk!=4*32)   CHK_VER("conf_tx_bchunk      mis-match\n"); else CHK_VER("conf_tx_bchunk      OK-match\n");
   if (conf_rx_reset!=0)       CHK_VER("conf_rx_reset       mis-match\n"); else CHK_VER("conf_rx_reset       OK-match\n");
   if (conf_rx_en!=0)          CHK_VER("conf_rx_en          mis-match\n"); else CHK_VER("conf_rx_en          OK-match\n");
   if (conf_rx_jumbo_en!=0)    CHK_VER("conf_rx_jumbo_en    mis-match\n"); else CHK_VER("conf_rx_jumbo_en    OK-match\n");
   if (conf_rx_no_chk_crc!=0)  CHK_VER("conf_rx_no_chk_crc  mis-match\n"); else CHK_VER("conf_rx_no_chk_crc  OK-match\n");
   if (conf_rx_promiscuous!=0) CHK_VER("conf_rx_promiscuous mis-match\n"); else CHK_VER("conf_rx_promiscuous OK-match\n");
   if (conf_rx_bchunk!=4*32)   CHK_VER("conf_rx_bchunk      mis-match\n"); else CHK_VER("conf_rx_bchunk      OK-match\n");
   fflush(stdout);
   //---------------------------------------------------------------------------
#if defined(VERVOSE)
printf("Before enable: "); fflush(stdout); getchar();
#endif
   conf_tx_reset=0x0;
   conf_tx_en=0x1;
   conf_rx_reset=0x0;
   conf_rx_en=0x1;
   gig_eth_mac_tx_enable(conf_tx_reset  //0  // tx_reset
                        ,conf_tx_en   );//1);// tx_enable
   gig_eth_mac_rx_enable(conf_rx_reset  //0  // rx_reset
                        ,conf_rx_en   );//1);// rx_enable
#if defined(VERVOSE)
printf("After enable: "); fflush(stdout); getchar();
#endif
#undef CHK_VER
   return 0;
}

//------------------------------------------------------------------------------
int hsr_init( uint8_t mac_addr[6]
            , uint8_t promiscuous  // 0: mac_dst matches always when 1
            , uint8_t drop_non_hsr // 1: drop all non-HSR packet when 1
            , uint8_t enable_qr    // 1: enable QR when 1
            , uint8_t snoop        // 0: pass all packet to upstream without removing HSR header when 1
            , int     verbose)
{
   #define CHK_VER(A) do { if (verbose) printf(A); } while (0)
   //---------------------------------------------------------------------------
   uint8_t mac_tmp[6];
   gig_eth_hsr_set_mac_addr(mac_addr);
   gig_eth_hsr_get_mac_addr(mac_tmp);
   int err=0;
   for (int idx=0; idx<6; idx++) {
        if (mac_addr[idx]!=mac_tmp[idx]) {
            if (verbose) { printf("mac_addr[%d]=0x%02X:%02X mis-match\n",
                                   idx, mac_addr[idx], mac_tmp[idx]); }
            err++;
        }
   }
   if (err==0) { CHK_VER("mac_addr OK-match\n");
   } else      { CHK_VER("mac_addr mis-match\n"); return -1; }
   //---------------------------------------------------------------------------
   uint8_t hsr_type  ;// 31
   uint8_t hsr_perf  ;//30
   uint8_t hsr_snoop ;// 3
   uint8_t hsr_enable_qr   ;// 2
   uint8_t hsr_drop_non_hsr;// 1
   uint8_t hsr_promiscuous ;// 0
   gig_eth_hsr_set_control( snoop // 3
                          , enable_qr    // 2
                          , drop_non_hsr // 1
                          , promiscuous // 0
                          );
   gig_eth_hsr_get_control( &hsr_type  // 31
                          , &hsr_perf  // 30
                          , &hsr_snoop // 3
                          , &hsr_enable_qr // 2
                          , &hsr_drop_non_hsr // 1
                          , &hsr_promiscuous // 0
                          );
   if (verbose) {
       printf("TYPE        : %s\n", (hsr_type        ==0) ? "RedBox"  : "DANH");
       printf("PERFORM     : %s\n", (hsr_perf        ==0) ? "OFF"     : "ON");
       printf("SNOOP       : %s\n", (hsr_snoop       ==0) ? "OFF"     : "ON");
       printf("QR          : %s\n", (hsr_enable_qr   ==0) ? "DISABLED": "ENABLED");
       printf("DROP-NON-HSR: %s\n", (hsr_drop_non_hsr==0) ? "OFF"     : "ON");
       printf("PROMISCUOUS : %s\n", (hsr_promiscuous ==0) ? "OFF"     : "ON");
       fflush(stdout);
   }
#undef CHK_VER
   return 0;
}

//------------------------------------------------------------------------------
int (*phy_init)( uint32_t phyaddr );

#if 0
//------------------------------------------------------------------------------
#include "mdio_api.h"
#include "gbe_phy_rtl8211eg.h"
#include "gbe_phy_88e1111.h"
//------------------------------------------------------------------------------
// phyaddr=0x7
int phy_init_rtl8211( uint32_t phyaddr )
{
   uint32_t value;

   //---------------------------------------------------------------------------
   mdio_reset();
   mdio_csr_check();
   mdio_clk_div((80/2)/2-1); // div=[freq/(2*mdc_freq)]-1
   mdio_enable (1);
   //----------------------------------------------------------
   mdio_read(phyaddr, 2, &value); // PHY ID1 REG
   if ((value&0xFFFF)!=0x001C) {
      printf("MDIO error PA=%d RA=%d error: 0x%X\n", phyaddr, 2, value);
   }
   mdio_read(phyaddr, 3, &value); // PHY ID1 REG
   if ((value&0xFFFF)!=0xC915) { // RTL8211
      printf("MDIO error PA=%d RA=%d error: 0x%X\n", phyaddr, 3, value);
   }
   //----------------------------------------------------------
   gbe_phy_rtl8211_check(phyaddr, 1);
   //----------------------------------------------------------
   return 0;
}
//------------------------------------------------------------------------------
// phyaddr=0x7  // b00111
int phy_init_88e1111( uint32_t phyaddr
                    , int gmii ) // 0=gmii 1=rgmii
{
   uint32_t value;

   //---------------------------------------------------------------------------
   mdio_reset();
   mdio_csr_check();
   mdio_clk_div((80/2)/2-1); // div=[freq/(2*mdc_freq)]-1
   mdio_enable (1);

   //---------------------------------------------------------------------------
   gbe_phy_88e1111_check_init();
   gbe_phy_88e1111_check(phyaddr);
   mdio_read(phyaddr, 2, &value); // PHY ID1 REG
   if ((value&0xFFFF)!=0x0141) {
      printf("MDIO error PHY PA=%d RA=%d error: 0x%04X\n", phyaddr, 2, value);
   } else {
      printf("MDIO OK PHY PA=%d RA=%d 0x%04X\n", phyaddr, 2, value);
   }
   mdio_read(phyaddr, 3, &value); // PHY ID1 REG
   if ((value&0xFFF0)!=0x0CC0) {
      printf("MDIO error PHY PA=%d RA=%d error: 0x%04X\n", phyaddr, 3, value);
   } else {
      printf("MDIO OK PHY PA=%d RA=%d 0x%04X\n", phyaddr, 3, value);
   }

   //---------------------------------------------------------------------------
   // Be careful since some do not have PHY RESET pin.
#if defined(PHY_RESET_TEST)
   if (!gig_eth_phy_reset(1, 1)) {
       printf("PHY ERROR: phy-reset does not return to 1\n");
       return -1;
   }
   gbe_phy_88e1111_check_init();
   gbe_phy_88e1111_check(phyaddr);
   mdio_read(phyaddr, 2, &value); // PHY ID1 REG
   if ((value&0xFFFF)!=0x0141) {
      printf("MDIO error PHY PA=%d RA=%d error: 0x%04X\n", phyaddr, 2, value);
   } else {
      printf("MDIO OK PHY PA=%d RA=%d 0x%04X\n", phyaddr, 2, value);
   }
   mdio_read(phyaddr, 3, &value); // PHY ID1 REG
   if ((value&0xFFF0)!=0x0CC0) {
      printf("MDIO error PHY PA=%d RA=%d error: 0x%04X\n", phyaddr, 3, value);
   } else {
      printf("MDIO OK PHY PA=%d RA=%d 0x%04X\n", phyaddr, 3, value);
   }
#endif

   //---------------------------------------------------------------------------
   int phy_rgmii=gbe_phy_88e1111_phy_get_rgmii(phyaddr);
   int mac_rgmii=gig_eth_mac_rgmii();
   if (gmii=1) { // make use of RGMII
       if (mac_rgmii==0) {
           printf("MAC ERROR: MAC operates in GMII mode\n");
           return -1;
       }
       if (phy_rgmii==0) {
           gbe_phy_88e1111_phy_set_rgmii(phyaddr);
           printf("MAC ERROR: PHY operates in GMII mode\n");
           return -1;
       }
       printf("INFO: RGMII mode\n");
   } else { // make use of GMII
       if (mac_rgmii==1) {
           printf("MAC ERROR: MAC operates in RGMII mode\n");
           return -1;
       }
       if (phy_rgmii==1) {
           gbe_phy_88e1111_phy_set_gmii(phyaddr);
           printf("MAC ERROR: PHY operates in RGMII mode\n");
           return -1;
       }
       printf("INFO: GMII mode\n");
   }
   return 0;
}
#endif

//------------------------------------------------------------------------------
// Revision History
//
// 2018.09.30: Revised by Ando Ki
//             - VLAN/HSR feature added
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
