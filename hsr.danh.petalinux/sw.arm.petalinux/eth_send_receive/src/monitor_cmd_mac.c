//--------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2018.10.02.
//--------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "strtoi.h"
#include "defines_system.h"
#include "eth_ip_udp_data_type.h"
#include "monitor_command.h"
#include "monitor_version.h"
#include "mac_api.h"
#include "gig_eth_mac_api.h"
#include "gig_eth_hsr_api.h"
#include "gpio_api.h"
#include "non_block_getchar.h"

//--------------------------------------------------------
static int mac_init_done=0; // it should be 1 to use MAC
unsigned int phy_addr=0x0;
unsigned char board_id=0x0;
//--------------------------------------------------------
// phy_init [-a phy_addr]
int func_phy_init(int argc, char* argv[])
{
    int pos;
    pos = 1;
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'a': pos++;
                    if (argc<=pos) return -1;
                    phy_addr = (unsigned int)strtoi(argv[pos]);
                    break;
       }
       pos++;
    }

#if 0
    phy_init(phy_addr);
#else
    printf("PHY init is not implemented yet\n");
#endif
    
    return 0;
}

//--------------------------------------------------------
// hsr_csr
int func_hsr_csr(int argc, char* argv[])
{
    gig_eth_hsr_csr_check();
    return 0;
}

//--------------------------------------------------------
// mac_csr
int func_mac_csr(int argc, char* argv[])
{
    gig_eth_mac_csr_check();
    return 0;
}

//--------------------------------------------------------
#define VAL(X) (((X)>='0')&&((X)<='9')) ? ((X)-'0')   :\
               (((X)>='a')&&((X)<='f')) ? ((X)-'a'+10):\
               (((X)>='A')&&((X)<='F')) ? ((X)-'A'+10): 0
static int get_mac_addr ( uint8_t mac[6]
                        , char*   str )
{
     char buff[24];
     int idx, idy;
     int len=strlen(str);
     idy = 0;
     for (idx=0; idx<len; idx++) { // remove '_' if any
          if (str[idx]=='_') {
          } else {
              buff[idy] = str[idx];
              idy++;
          }
     }
     buff[idy] = '\0';
     len = strlen(buff);
     idx = 0;
     if ((buff[0]=='0')&&(buff[1]=='x')) {
          idx=2;
          if (len<14) return -1;
     } else {
          if (len<12) return -1;
     }
     int idz=0;
     for (idz=0; idz<6; idz++) {
          char A=buff[idx++];
          char B=buff[idx++];
          mac[idz] = ((VAL(A))<<4) | (VAL(B));
     }
     return 0;
}

//--------------------------------------------------------
static int cpy_mac_addr( uint8_t dst[6], uint8_t src[6])
{
   for (int idx=0; idx<6; idx++) dst[idx] = src[idx];
   return 0;
}

//--------------------------------------------------------
static uint8_t  hsr_mac_addr[6]={0x02,0x12,0x34,0x56,0x78,0x00};
static uint8_t  mac_addr[6]={0x02,0x12,0x34,0x56,0x78,0x00};
static uint8_t  conf_tx_jumbo_en=0;
static uint8_t  conf_tx_no_gen_crc=0;
static uint16_t conf_tx_bchunk=4*32;
static uint8_t  conf_rx_jumbo_en=0;
static uint8_t  conf_rx_no_chk_crc=0;
static uint8_t  conf_rx_promiscuous=0;
static uint16_t conf_rx_bchunk=4*32;
static uint32_t buff_tx_start=ADDR_GBE_BRAM_TX_START;
static uint32_t buff_tx_size =GBE_TX_BUFF_SIZE;
static uint32_t buff_rx_start=ADDR_GBE_BRAM_RX_START;
static uint32_t buff_rx_size =GBE_RX_BUFF_SIZE;
//--------------------------------------------------------
#define PRT_MAC(A,B)\
        printf("%s 0x%02X%02X%02X%02X%02X%02X\n", (A)\
                   ,(B)[0],(B)[1],(B)[2],(B)[3],(B)[4],(B)[5])
//--------------------------------------------------------
// mac_addr -a mac_addr      : to set
// mac_addr -r               : to read
int func_mac_addr(int argc, char* argv[])
{
    int set=0, get=0;
    int pos=1;
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'a': pos++;
                    if (argc<=pos) return -1;
                    if (get_mac_addr(mac_addr,argv[pos])<0) return -1;
                    set=1;
                    break;
          case 'r': get=1;
       }
       pos++;
    }
    if (set==1) {
        gig_eth_mac_set_mac_addr(mac_addr);
        gig_eth_hsr_set_mac_addr(mac_addr);
        cpy_mac_addr(hsr_mac_addr, mac_addr);
    }
    if (get==1) {
        uint8_t mac_tmpA[6];
        uint8_t mac_tmpB[6];
        gig_eth_mac_get_mac_addr(mac_tmpA);
        gig_eth_hsr_get_mac_addr(mac_tmpB);
        PRT_MAC("MAC", mac_tmpA);
        PRT_MAC("HSR", mac_tmpB);
    }
    return 0;
}

//--------------------------------------------------------
// mac_init [-a mac_addr]
//          [-b val] //conf_tx_jumbo_en=0;
//          [-c val] //conf_tx_no_gen_crc=0;
//          [-d val] //conf_tx_bchunk=4*32;
//          [-e val] //conf_rx_jumbo_en=0;
//          [-f val] //conf_rx_no_chk_crc=0;
//          [-g val] //conf_rx_promiscuous=0;
//          [-h val] //conf_rx_bchunk=4*32;
//          [-i start:size] // TX frame-buffer
//          [-j start:size] // RX frame-buffer
//          [-s]     //status
//          [-?]     //help
int func_mac_init(int argc, char* argv[])
{
    char *token;
    int flag_status=0;
    int flag_help=0;
    int pos=1;
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'a': pos++;
                    if (argc<=pos) return -1;
                    if (get_mac_addr(mac_addr,argv[pos])<0) return -1;
                    break;
          case 'b': pos++;
                    if (argc<=pos) return -1;
                    conf_tx_jumbo_en = strtoi(argv[pos]);
                    break;
          case 'c': pos++;
                    if (argc<=pos) return -1;
                    conf_tx_no_gen_crc = strtoi(argv[pos]);
                    break;
          case 'd': pos++;
                    if (argc<=pos) return -1;
                    conf_tx_bchunk = strtoi(argv[pos]);
                    break;
          case 'e': pos++;
                    if (argc<=pos) return -1;
                    conf_rx_jumbo_en = strtoi(argv[pos]);
                    break;
          case 'f': pos++;
                    if (argc<=pos) return -1;
                    conf_rx_no_chk_crc = strtoi(argv[pos]);
                    break;
          case 'g': pos++;
                    if (argc<=pos) return -1;
                    conf_rx_promiscuous = strtoi(argv[pos]);
                    break;
          case 'h': pos++;
                    if (argc<=pos) return -1;
                    conf_rx_bchunk = strtoi(argv[pos]);
                    break;
          case 'i': pos++;
                    if (argc<=pos) return -1;
                    token = strtok(argv[pos], ":");
                    if (token==NULL) return -1;
                    buff_tx_start = (unsigned int)strtoi(token);
                    token = strtok(NULL, ":");
                    if (token==NULL) return -1;
                    buff_tx_size = (unsigned int)strtoi(token);
                    break;
          case 'j': pos++;
                    if (argc<=pos) return -1;
                    token = strtok(argv[pos], ":");
                    if (token==NULL) return -1;
                    buff_rx_start = (unsigned int)strtoi(token);
                    token = strtok(NULL, ":");
                    if (token==NULL) return -1;
                    buff_rx_size = (unsigned int)strtoi(token);
                    break;
          case 's': flag_status = 1;
                    break;
          case '?': flag_help = 1;
                    break;
       }
       pos++;
    }

    if (flag_help) {
        command_help("mac_init");
        return 0;
    }
    if (mac_init( mac_addr
               , conf_tx_jumbo_en
               , conf_tx_no_gen_crc
               , conf_tx_bchunk
               , conf_rx_jumbo_en
               , conf_rx_no_chk_crc
               , conf_rx_promiscuous
               , conf_rx_bchunk
               , buff_tx_start
               , buff_tx_size
               , buff_rx_start
               , buff_rx_size
               , 0
               )<0) {
        if (flag_status==1) {
            printf("\"mac_init()\" failed\n");
        }
        return -1;
    }
    gig_eth_hsr_set_mac_addr(mac_addr);
    cpy_mac_addr(hsr_mac_addr, mac_addr);
    mac_init_done = 1;
    if (flag_status==1) {
        uint8_t  Tmac_addr[6]        ;
        uint8_t  Tconf_tx_reset      ;
        uint8_t  Tconf_tx_en         ;
        uint8_t  Tconf_tx_jumbo_en   ;
        uint8_t  Tconf_tx_no_gen_crc ;
        uint16_t Tconf_tx_bchunk     ;
        uint8_t  Tconf_rx_reset      ;
        uint8_t  Tconf_rx_en         ;
        uint8_t  Tconf_rx_jumbo_en   ;
        uint8_t  Tconf_rx_no_chk_crc ;
        uint8_t  Tconf_rx_promiscuous;
        uint16_t Tconf_rx_bchunk     ;
        uint32_t Tbuff_tx_start      ;
        uint32_t Tbuff_tx_end        ; // exclusive
        uint32_t Tbuff_rx_start      ;
        uint32_t Tbuff_rx_end        ; // exclusive
        gig_eth_mac_get_mac_addr( Tmac_addr );
        gig_eth_mac_get_config( &Tconf_tx_reset
                              , &Tconf_tx_en
                              , &Tconf_tx_jumbo_en
                              , &Tconf_tx_no_gen_crc
                              , &Tconf_tx_bchunk
                              , &Tconf_rx_reset
                              , &Tconf_rx_en
                              , &Tconf_rx_jumbo_en
                              , &Tconf_rx_no_chk_crc
                              , &Tconf_rx_promiscuous
                              , &Tconf_rx_bchunk );
        gig_eth_mac_get_frame_buffer_tx(&Tbuff_tx_start
                                       ,&Tbuff_tx_end
                                       ,0, 0);
        gig_eth_mac_get_frame_buffer_rx(&Tbuff_rx_start
                                       ,&Tbuff_rx_end
                                       ,0, 0);
        PRT_MAC("mac_addr", Tmac_addr);
        printf("conf_tx_jumbo_en   : %d\n", Tconf_tx_jumbo_en   );
        printf("conf_tx_no_gen_crc : %d\n", Tconf_tx_no_gen_crc );
        printf("conf_tx_bchunk     : %d\n", Tconf_tx_bchunk     );
        printf("conf_rx_jumbo_en   : %d\n", Tconf_rx_jumbo_en   );
        printf("conf_rx_no_chk_crc : %d\n", Tconf_rx_no_chk_crc );
        printf("conf_rx_promiscuous: %d\n", Tconf_rx_promiscuous);
        printf("conf_rx_bchunk     : %d\n", Tconf_rx_bchunk     );
        printf("TX buffer          : 0x%08X:%08X\n",(unsigned int)Tbuff_tx_start
                                                   ,(unsigned int)Tbuff_tx_end);
        printf("RX buffer          : 0x%08X:%08X\n",(unsigned int)Tbuff_rx_start
                                                   ,(unsigned int)Tbuff_rx_end);
        uint8_t  Hmac_addr[6]        ;
        gig_eth_hsr_get_mac_addr( Hmac_addr );
        PRT_MAC("HSR mac_addr", Hmac_addr);
        if (strncmp((char*)Tmac_addr, (char*)Hmac_addr, 6)) {
            printf("MAC and HSR does not match MAC-ADDR\n");
        }
    }
    
    return 0;
}

//--------------------------------------------------------
static uint8_t  hsr_promiscuous=0;
static uint8_t  hsr_drop_non_hsr=1;
static uint8_t  hsr_enable_qr=1;
static uint8_t  hsr_snoop=0;
//--------------------------------------------------------
// hsr_init [-a hsr_mac_addr]
//          [-b val]        //control_promiscuous=0;
//          [-c val]        //control_drop_non_hsr=1;
//          [-d val]        //control_enable_qr=1;
//          [-e val]        //control_snoop=0;
//          [-s]            //status
int func_hsr_init(int argc, char* argv[])
{
    int flag_status=0;
    int flag_help=0;
    int pos=1;
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'a': pos++;
                    if (argc<=pos) return -1;
                    if (get_mac_addr(hsr_mac_addr,argv[pos])<0) return -1;
                    break;
          case 'b': pos++;
                    if (argc<=pos) return -1;
                    hsr_promiscuous = strtoi(argv[pos]);
                    break;
          case 'c': pos++;
                    if (argc<=pos) return -1;
                    hsr_drop_non_hsr = strtoi(argv[pos]);
                    break;
          case 'd': pos++;
                    if (argc<=pos) return -1;
                    hsr_enable_qr = strtoi(argv[pos]);
                    break;
          case 'e': pos++;
                    if (argc<=pos) return -1;
                    hsr_snoop = strtoi(argv[pos]);
                    break;
          case 's': flag_status = 1;
                    break;
          case '?': flag_help = 1;
                    break;
       }
       pos++;
    }
    if (flag_help) {
        command_help("hsr_init");
        return 0;
    }

    if (hsr_init( hsr_mac_addr
                , hsr_promiscuous
                , hsr_drop_non_hsr
                , hsr_enable_qr
                , hsr_snoop
                , 0
                )<0) {
        if (flag_status==1) {
            printf("\"hsr_init()\" failed\n");
        }
        return -1;
    }
    if (flag_status==1) {
        uint8_t Tmac_addr[6];
        uint8_t Thsr_type  ;// 31
        uint8_t Thsr_perf  ;//30
        uint8_t Thsr_snoop ;// 3
        uint8_t Thsr_enable_qr   ;// 2
        uint8_t Thsr_drop_non_hsr;// 1
        uint8_t Thsr_promiscuous ;// 0
        gig_eth_hsr_get_mac_addr( Tmac_addr );
        gig_eth_hsr_get_control( &Thsr_type  // 31
                               , &Thsr_perf  // 30
                               , &Thsr_snoop // 3
                               , &Thsr_enable_qr    // 2
                               , &Thsr_drop_non_hsr // 1
                               , &Thsr_promiscuous  // 0
                               );
        PRT_MAC("hsr mac_addr", Tmac_addr);
        printf("TYPE        : %s\n", (Thsr_type        ==0) ? "RedBox"  : "DANH");
        printf("PERFORM     : %s\n", (Thsr_perf        ==0) ? "OFF"     : "ON");
        printf("SNOOP       : %s\n", (Thsr_snoop       ==0) ? "OFF"     : "ON");
        printf("QR          : %s\n", (Thsr_enable_qr   ==0) ? "DISABLED": "ENABLED");
        printf("DROP-NON-HSR: %s\n", (Thsr_drop_non_hsr==0) ? "OFF"     : "ON");
        printf("PROMISCUOUS : %s\n", (Thsr_promiscuous ==0) ? "OFF"     : "ON");
        fflush(stdout);
    }
    
    return 0;
}

//--------------------------------------------------------
// pkt_snd  [-a mac_src]
//          [-b mac_dst]
//          [-n bstart[:bend]]
//          [-t broad  ]
//          [-t hsr    ]
//          [-t vlan   ]
//          [-i]         // interactive mode
//          [-r]         // repeat
//          [-x timeout] // 0 or <0 for blocking
//          [-v verbose]
int func_pkt_snd(int argc, char* argv[])
{
    if (mac_init_done==0) {
        printf("Do \"mac_init\" first\n");
        return -1;
    }
    char        *token;
    uint8_t      mac_src[6], mac_dst[6];
    uint16_t     bstart=1, bend=1;
    uint8_t      pkt_type=0;
    int          timeout=100;
    int          verbose=0;
    int          flag_repeat=0;
    int          flag_interactive=0;
    int flag_help=0;
    int pos=1;
    memcpy(mac_src, mac_addr, 6);
    memset(mac_dst, 0xFF, 6); // make broadcasting
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'a': pos++;
                    if (argc<=pos) return -1;
                    if (get_mac_addr(mac_src,argv[pos])<0) return -1;
                    break;
          case 'b': pos++;
                    if (argc<=pos) return -1;
                    if (get_mac_addr(mac_dst,argv[pos])<0) return -1;
                    break;
          case 'n': pos++;
                    if (argc<=pos) return -1;
                    token = strtok(argv[pos], ":");
                    if (token==NULL) return -1;
                    bstart = (uint16_t)strtoi(token);
                    token = strtok(NULL, ":");
                    if (token!=NULL) {
                        bend = (uint16_t)strtoi(token);
                    } else {
                        bend = bstart;
                    }
                    break;
          case 't': pos++;
                    if (argc<=pos) return -1;
                    if (!strcmp("broad", argv[pos])) pkt_type |= PKT_TYPE_BROADCAST;
                    else if (!strcmp("vlan", argv[pos])) pkt_type |= PKT_TYPE_VLAN;
                    else if (!strcmp("hsr", argv[pos])) pkt_type |= PKT_TYPE_HSR;
                    else printf("Unknown option value %s\n", argv[pos]);
                    break;
          case 'r': flag_repeat = 1;
                    break;
          case 'i': flag_interactive=1;
                    break;
          case 'x': pos++;
                    if (argc<=pos) return -1;
                    timeout = strtoi(argv[pos]);
                    break;
                    break;
          case 'v': pos++;
                    if (argc<=pos) return -1;
                    verbose = strtoi(argv[pos]);
                    break;
          case '?': flag_help = 1;
                    break;
       }
       pos++;
    }
    if (flag_help) {
        command_help("pkt_snd");
        return 0;
    }
   
    if (flag_interactive==0) {
        NON_BLOCK_INIT
    }
    do { for (uint16_t idx=bstart; (bend>0)&&(idx<=bend); idx++) {
             if (eth_send_packet( mac_dst //uint8_t  mac_dst[6]
                                , mac_src //uint8_t  mac_src[6]
                                , pkt_type//uint8_t  pkt_type
                                , idx     //uint16_t bnum
                                , timeout //int      timeout
                                , verbose //int      verbose);
                                )<0) return -1;
              if (flag_repeat==1) {
                 #if 0
                 if (XUartPs_IsReceiveData(STDIN_BASEADDRESS)) {
                     char c=inbyte(); // XUartPs_RecvByte(STDIN_BASEADDRESS);
                     if ((c==0x03)||(c==0x1B)) // CTL-C, ESC
                         { flag_repeat=0; break; }
                 }
                 #else
                 char c=getchar();
                 if ((c==0x03)||(c==0x1B)) { flag_repeat=0; break; }
                 #endif
              }
         }
    } while (flag_repeat==1);
    if (flag_interactive==0) {
        NON_BLOCK_EXIT
    }
    
    return 0;
}

//--------------------------------------------------------
// pkt_rcv  [-r]         //repeat
//          [-x timeout] // 0 or <0 for blocking
//          [-v verbose] // 0 for no-verbose
int func_pkt_rcv(int argc, char* argv[])
{
    int flag_repeat=0;
    int flag_help=0;
    int timeout=100;
    if (mac_init_done==0) {
        printf("Do \"mac_init\" first\n");
        return -1;
    }
    int      verbose=0;
    int pos;
    pos = 1;
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'r': flag_repeat = 1;
                    break;
          case 'x': pos++;
                    if (argc<=pos) return -1;
                    timeout = strtoi(argv[pos]);
                    break;
          case 'v': pos++;
                    if (argc<=pos) return -1;
                    verbose = strtoi(argv[pos]);
                    break;
          case '?': flag_help = 1;
                    break;
       }
       pos++;
    }
    if (flag_help==1) {
        command_help("pkt_rcv");
        return 0;
    }

    NON_BLOCK_INIT
    do { int ret = eth_receive_packet(timeout,verbose);
         if ((flag_repeat==0)&&(ret<0)) return -1;
         if (flag_repeat==1) {
            #if 0
            if (XUartPs_IsReceiveData(STDIN_BASEADDRESS)) {
                char c=inbyte(); // XUartPs_RecvByte(STDIN_BASEADDRESS);
                if ((c==0x03)||(c==0x1B)) // CTL-C, ESC
                    { flag_repeat=0; break; }
            }
            #else
            char c=getchar();
            if ((c==0x03)||(c==0x1B)) { flag_repeat=0; break; }
            #endif
         }
    } while (flag_repeat==1);
    NON_BLOCK_EXIT
    
    return 0;
}

//--------------------------------------------------------
int mac_register(void)
{
  command_register("phy_init", "", func_phy_init,
                   "phy_init : initialize PHY (not yet)",
                   "phy_init [-a phy_addr]                      : initialize PHY (not yet)");
  command_register("hsr_csr" , "", func_hsr_csr,
                   "hsr_csr  : check HSR CSR",
                   "hsr_csr                                     : check HSR CSR");
  command_register("mac_csr" , "", func_mac_csr,
                   "mac_csr  : check MAC CSR",
                   "mac_csr                                     : check MAC CSR");
  command_register("mac_addr", "", func_mac_addr,
                   "mac_addr : set/get MAC address",
                   "mac_addr [-a mac_addr]                      : set MAC address\n" 
                   "mac_addr [-r]                               : get MAC address");
  command_register("mac_init", "", func_mac_init,
                   "mac_init : initialize MAC",
                   "mac_init [-a mac_addr]                      : initialize MAC\n"
                   "         [-b val]        //conf_tx_jumbo_en=0;\n"
                   "         [-c val]        //conf_tx_no_gen_crc=0;\n"
                   "         [-d val]        //conf_tx_bchunk=4*32;\n"
                   "         [-e val]        //conf_rx_jumbo_en=0;\n"
                   "         [-f val]        //conf_rx_no_chk_crc=0;\n"
                   "         [-g val]        //conf_rx_promiscuous=0;\n"
                   "         [-h val]        //conf_rx_bchunk=4*32;\n"
                   "         [-i start:size] // TX frame-buffer\n"
                   "         [-j start:size] // RX frame-buffer\n"
                   "         [-s]            //status");
  command_register("hsr_init", "", func_hsr_init,
                   "hsr_init : initialize MAC",
                   "hsr_init [-a hsr_mac_addr]                  : initialize MAC\n"
                   "         [-b val]        //control_promiscuous=0;\n"
                   "         [-c val]        //control_drop_non_hsr=1;\n"
                   "         [-d val]        //control_enable_qr=1;\n"
                   "         [-e val]        //control_snoop=0;\n"
                   "         [-s]            //status");
  command_register("pkt_snd", "", func_pkt_snd,
                   "pkt_snd  : send packet",
                   "pkt_snd  [-a mac_src] [-b mac_dst]          : send packet\n"
                   "         [-n bstart[:bend]]    //byte number start and end\n"
                   "         [-r]                  //repeat\n"
                   "         [-i]                  //interactive mode\n"
                   "         [-t broad ] [-t vlan] //packet type\n"
                   "         [-x timeout]          //timeout (0 for blocking)\n"
                   "         [-v verbose]          //verbose level");
  command_register("pkt_rcv", "", func_pkt_rcv,
                   "pkt_rcv  : receive packet",
                   "pkt_rcv                                     : receive packet\n"
                   "         [-r]               //repeat\n"
                   "         [-x timeout]       //timeout (0 for blocking)\n"
                   "         [-v verbose]       //verbose level");
  //----------------------------------------------------------------------------
  board_id = gpio_read();
  mac_addr[5] = board_id; // last octet (byte)
  if (mac_init_done==0) {
      mac_init( mac_addr
              , conf_tx_jumbo_en
              , conf_tx_no_gen_crc
              , conf_tx_bchunk
              , conf_rx_jumbo_en
              , conf_rx_no_chk_crc
              , conf_rx_promiscuous
              , conf_rx_bchunk
              , buff_tx_start
              , buff_tx_size
              , buff_rx_start
              , buff_rx_size
              , 0
              );
      gig_eth_hsr_set_mac_addr(mac_addr);
      mac_init_done = 1;
  }
  return 0;
}

//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
