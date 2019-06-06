//----------------------------------------------------------------------------
// Copyright (c) 2019 by Ando Ki.
// All right reserved.
//----------------------------------------------------------------------------
// VERSION = 2019.05.20.
//----------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include "ptpv2_message.h"

//-----------------------------------------------------------------------------
int gen_ptpv2_msg_unknown( ptpv2_ctx_t *ctx
                         , uint8_t     *msg
                         , uint16_t     seq_id
                         )
{
     PTPV2_ERROR("Un-known PTPv2 message type\n");
     return 0;
}
//-----------------------------------------------------------------------------
int (*func_ptpv2_msg[16])( ptpv2_ctx_t *ctx
                         , uint8_t     *msg
                         , uint16_t     seq_id) =
{
/* 0x0 */   gen_ptpv2_msg_sync                        
/* 0x1 */ , gen_ptpv2_msg_delay_req
/* 0x2 */ , gen_ptpv2_msg_pdelay_req
/* 0x3 */ , gen_ptpv2_msg_pdelay_resp
/* 0x4 */ , gen_ptpv2_msg_unknown
/* 0x5 */ , gen_ptpv2_msg_unknown
/* 0x6 */ , gen_ptpv2_msg_unknown
/* 0x7 */ , gen_ptpv2_msg_unknown
/* 0x8 */ , gen_ptpv2_msg_follow_up
/* 0x9 */ , gen_ptpv2_msg_delay_resp
/* 0xA */ , gen_ptpv2_msg_pdelay_resp_follow_up
/* 0xB */ , gen_ptpv2_msg_announce
/* 0xC */ , gen_ptpv2_msg_signaling
/* 0xD */ , gen_ptpv2_msg_management
/* 0xE */ , gen_ptpv2_msg_unknown
/* 0xF */ , gen_ptpv2_msg_unknown
};

//-----------------------------------------------------------------------------
// Return message length,
// Return 0 when error.
inline static uint16_t get_msg_length(uint8_t type)
{
      switch (type) {
      case PTPV2_MSG_Sync                 : return PTPV2_MSG_LEN_SYNC                 ; break;
      case PTPV2_MSG_Delay_Req            : return PTPV2_MSG_LEN_DELAY_REQ            ; break;
      case PTPV2_MSG_Pdelay_Req           : return PTPV2_MSG_LEN_PDELAY_REQ           ; break;
      case PTPV2_MSG_Pdelay_Resp          : return PTPV2_MSG_LEN_PDELAY_RESP          ; break;
      case PTPV2_MSG_Follow_Up            : return PTPV2_MSG_LEN_FOLLOW_UP            ; break;
      case PTPV2_MSG_Delay_Resp           : return PTPV2_MSG_LEN_DELAY_RESP           ; break;
      case PTPV2_MSG_Pdelay_Resp_Follow_Up: return PTPV2_MSG_LEN_PDELAY_RESP_FOLLOW_UP; break;
      case PTPV2_MSG_Announce             : return sizeof(ptpv2_msg_announce_t); break;
      case PTPV2_MSG_Signaling            : return sizeof(ptpv2_msg_signaling_t); break;
      case PTPV2_MSG_Management           : return sizeof(ptpv2_msg_management_t); break;
      default: PTPV2_ERROR("Un-known PTPv2 message type: %u\n", type);
      }
      return 0;
}
//-----------------------------------------------------------------------------
// see IEEE.Std 1588-2008 pp.126
// Return message flags
inline static uint16_t get_msg_flags(ptpv2_ctx_t *ctx, uint8_t type)
{
      uint16_t flags=0x0000;
      switch (type) {
      case PTPV2_MSG_Sync: 
           if (!ctx->one_step_clock) flags |= PTPV2_MSG_FLAG_twoStepFlag;
           break;
      case PTPV2_MSG_Delay_Req: 
           break;
      case PTPV2_MSG_Pdelay_Req: 
           break;
      case PTPV2_MSG_Pdelay_Resp: 
           if (!ctx->one_step_clock) flags |= PTPV2_MSG_FLAG_twoStepFlag;
           break;
      case PTPV2_MSG_Follow_Up: 
           break;
      case PTPV2_MSG_Delay_Resp: 
           break;
      case PTPV2_MSG_Pdelay_Resp_Follow_Up: 
           break;
      case PTPV2_MSG_Announce:
           // need attention
           break;
      case PTPV2_MSG_Signaling: 
           break;
      case PTPV2_MSG_Management: 
           break;
      default: PTPV2_ERROR("Un-known PTPv2 message type: %u\n", type);
      }
      if (ctx->unicast_port ) flags |= PTPV2_MSG_FLAG_unicastFlag;
      if (ctx->profile_spec1) flags |= PTPV2_MSG_FLAG_profile1;
      if (ctx->profile_spec2) flags |= PTPV2_MSG_FLAG_profile2;

      return flags;
}
//-----------------------------------------------------------------------------
// Return controlField of message
inline static uint8_t get_msg_control(uint8_t type)
{
      switch (type) {
      case PTPV2_MSG_Sync      : return PTPV2_MSG_CTRL_Sync      ; break;
      case PTPV2_MSG_Delay_Req : return PTPV2_MSG_CTRL_Delay_Req ; break;
      case PTPV2_MSG_Follow_Up : return PTPV2_MSG_CTRL_Follow_Up ; break;
      case PTPV2_MSG_Delay_Resp: return PTPV2_MSG_CTRL_Delay_Resp; break;
      case PTPV2_MSG_Management: return PTPV2_MSG_CTRL_Management; break;
      default:                   return PTPV2_MSG_CTRL_All_others; break;
      }
}

//-----------------------------------------------------------------------------
int populate_ptpv2_msg_hdr( ptpv2_ctx_t     *ctx
                          , ptpv2_msg_hdr_t *hdr
                          , uint8_t          type
                          , uint16_t         seq_id
                          )
{
    extern void *memset(void *dst, int c, unsigned int bytes);
    extern void *memcpy(void *dst, void *src, unsigned int bytes);
    memset(hdr,0,PTPV2_HDR_LEN);
    hdr->messageType        = type&0xF; // lower 4-bit
    hdr->transportSpecific  = 0x0; // higher 4-bit
    hdr->versionPTP         = ctx->ptp_version&0xF; // it should be 2
    hdr->reserved0          = 0;
    // below cause problem when 'hdr' is mis-aligned with 2
    #if defined(RIGOR)
    if ((unsigned)&(hdr->messageLength)%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", (unsigned)&(hdr->messageLength)%2);
    }
    #endif
    hdr->messageLength      = htons(get_msg_length(type));
    hdr->domainNumber       = ctx->ptp_domain;
    hdr->reserved1          = 0;
    #if defined(RIGOR)
    if ((unsigned)&(hdr->Flags)%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", (unsigned)&(hdr->Flags)%2);
    }
    #endif
    hdr->Flags              = htons(get_msg_flags(ctx,type));
    hdr->correctionField    = 0x0;
    hdr->reserved2          = 0;
    memcpy(&(hdr->sourcePortIdentity.clockIdentity),ctx->clock_id,PTPV2_LEN_CLOCKIDENTITY);
    hdr->sourcePortIdentity.portNumber = htons(ctx->port_num);
    #if defined(RIGOR)
    if ((unsigned)&(hdr->sequenceID)%2) {
        printf("%s:%s() mis-aligned 0x%08X\n", (unsigned)&(hdr->sequenceID)%2);
    }
    #endif
    hdr->sequenceID         = htons(seq_id);
    hdr->controlField       = get_msg_control(type);
    hdr->logMessageInterval = PTPV2_MSG_DEFAULT_INTERVAL; // 0x7F

    return PTPV2_HDR_LEN; // 34
}

//-----------------------------------------------------------------------------
int gen_ptpv2_msg( ptpv2_ctx_t *ctx 
                 , uint8_t      type
                 , uint8_t     *msg 
                 , uint16_t     seq_id
                 )
{
     return func_ptpv2_msg[type]( ctx
                                , &msg[ETH_HDR_LEN]
                                , seq_id);
}

//-----------------------------------------------------------------------------
int gen_ptpv2_msg_sync( ptpv2_ctx_t *ctx
                      , uint8_t     *msg
                      , uint16_t     seq_id
                      )
{
    extern void *memset(void *dst, int c, unsigned int bytes);
    ptpv2_msg_sync_t *msg_sync = (ptpv2_msg_sync_t*)msg;
    populate_ptpv2_msg_hdr( ctx
                                , (ptpv2_msg_hdr_t*)msg
                                , PTPV2_MSG_Sync
                                , seq_id);
    if (ctx->one_step_clock) {
      memset(&msg_sync->originTimestamp, 0, PTPV2_LEN_TIMESTAMP); // sizeof(Timestamp_t)
    } else {
#if 0
      uint16_t msb;
      uint32_t lsb, nano; 
      ret = ptp_get_time_rtc(&msb ,&lsb ,&nano); // due to mis-alignment problem
      msg_sync>originTimestamp.secondsField.msb = htons(msb);
      msg_sync>originTimestamp.secondsField.lsb = htonl(lsb);
      msg_sync>originTimestamp.nanosecondsField = htonl(nano);
      if (ret) {
          PTPV2_ERROR("something wrong while getting ptp_get_time_rtc\n");
      }
#endif
    }
    return PTPV2_MSG_LEN_SYNC; //sizeof(ptpv2_msg_sync_t);
}

//-----------------------------------------------------------------------------
// 'time': pointer to Timestamp of previous Sync message.
int gen_ptpv2_msg_follow_up( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{
    populate_ptpv2_msg_hdr( ctx
                                , (ptpv2_msg_hdr_t*)msg
                                , PTPV2_MSG_Follow_Up
                                , seq_id);
    if (ctx->one_step_clock) {
          PTPV2_ERROR("no Follow_Up for one_stp_clock\n");
    } else {
#if 0
      ptpv2_msg_follow_up_t *msg_fol = (ptpv2_msg_follow_up_t*)msg;
      uint8_t type; // PTPv2 message type
      uint16_t message_id;
      uint16_t msb;
      uint32_t lsb, nano;
      int time_out = 0;
      int ret = ptp_get_time_tsu_tx(&type
                               ,&message_id
                               ,&msb ,&lsb ,&nano
                               ,time_out); // due to mis-alignment problem
      if (ret) {
          PTPV2_ERROR("something wrong while getting ptp_get_time_tsu\n");
      }
      msg_fol->preciseOriginTimestamp.secondsField.msb = htons(msb);
      msg_fol->preciseOriginTimestamp.secondsField.lsb = htonl(lsb);
      msg_fol->preciseOriginTimestamp.nanosecondsField = htonl(nano);
#endif
    }
    return PTPV2_MSG_LEN_FOLLOW_UP; //sizeof(ptpv2_msg_follow_up_t);
}

//-----------------------------------------------------------------------------
int gen_ptpv2_msg_delay_req( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{
printf("%s()\n", __FUNCTION__);
    extern void *memset(void *dst, int c, unsigned int bytes);
    ptpv2_msg_delay_req_t *msg_dly_req = (ptpv2_msg_delay_req_t*)msg;
    populate_ptpv2_msg_hdr( ctx
                          , (ptpv2_msg_hdr_t*)msg
                          , PTPV2_MSG_Delay_Req
                          , seq_id);
    if (ctx->one_step_clock) {
        memset(&msg_dly_req->originTimestamp, 0, PTPV2_LEN_TIMESTAMP); // sizeof(Timestamp_t)
    }
    return PTPV2_MSG_LEN_DELAY_REQ; //sizeof(ptpv2_msg_delay_req_t);
}
//-----------------------------------------------------------------------------
int gen_ptpv2_msg_pdelay_req( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{ return 0; }
int gen_ptpv2_msg_pdelay_resp( ptpv2_ctx_t *ctx
                      , uint8_t     *msg
                      , uint16_t     seq_id
                      )
{ return 0; }
//-----------------------------------------------------------------------------
int gen_ptpv2_msg_delay_resp( ptpv2_ctx_t *ctx
                            , uint8_t     *msg
                            , uint16_t     seq_id
                            )
{
    extern void *memset(void *dst, int c, unsigned int bytes);
    ptpv2_msg_delay_resp_t *msg_dly_resp = (ptpv2_msg_delay_resp_t*)msg;
    populate_ptpv2_msg_hdr( ctx
                                , (ptpv2_msg_hdr_t*)msg
                                , PTPV2_MSG_Delay_Resp
                                , seq_id);
    if (ctx->one_step_clock) {
      memset(&msg_dly_resp->receiveTimestamp, 0, PTPV2_LEN_TIMESTAMP); // sizeof(Timestamp_t)
    } else {
#if 0
      uint16_t msb;
      uint32_t lsb, nano; 
      int ret = ptp_get_time_rtc(&msb ,&lsb ,&nano); // due to mis-alignment problem
      msg_dly_resp->receiveTimestamp.secondsField.msb = htons(msb);
      msg_dly_resp->receiveTimestamp.secondsField.lsb = htonl(lsb);
      msg_dly_resp->receiveTimestamp.nanosecondsField = htonl(nano);
      if (ret) {
          PTPV2_ERROR("something wrong while getting ptp_get_time_rtc\n");
      }
#endif
    }
    return PTPV2_MSG_LEN_DELAY_RESP; //sizeof(ptpv2_msg_delay_resp_t);
}
//-----------------------------------------------------------------------------
int gen_ptpv2_msg_pdelay_resp_follow_up( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{ return 0; }
int gen_ptpv2_msg_announce( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{ return 0; }
int gen_ptpv2_msg_signaling( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{ return 0; }
int gen_ptpv2_msg_management( ptpv2_ctx_t *ctx
                           , uint8_t     *msg
                           , uint16_t     seq_id
                           )
{ return 0; }

//-----------------------------------------------------------------------------
// Generate PTPv2 over raw Etherent packet.
int gen_ptpv2_ethernet( ptpv2_ctx_t *ctx
                      , uint8_t     *packet
                      , uint8_t      type
                      , uint16_t     seq_id
                      , uint8_t      mac_src[6]
                      )
{
     uint16_t packet_leng;
     uint8_t  mac_dst[6];
     switch (type) {
     case 0x0: // Event:Sync
     case 0x1: // Event:Delay_Req
     case 0x8: // General:Follow_Up
     case 0x9: // General:Delay_Resp
     case 0xB: // General:Announce
     case 0xC: // General:Signaling
     case 0xD: // General:Management
               mac_dst[0] = 0x01;
               mac_dst[1] = 0x1B;
               mac_dst[2] = 0x19;
               mac_dst[3] = 0x00;
               mac_dst[4] = 0x00;
               mac_dst[5] = 0x00; break;
     case 0x2: // Event:Pdelay_Req
     case 0x3: // Event:Pdelay_Resp
     case 0xA: // General:Pdelay_Resp_Follow_Up
               mac_dst[0] = 0x01;
               mac_dst[1] = 0x80;
               mac_dst[2] = 0xC2;
               mac_dst[3] = 0x00;
               mac_dst[4] = 0x00;
               mac_dst[5] = 0x0E; break;
     default: PTPV2_ERROR("undefined PTPv2 message type: 0x%1X", type);
     }
     packet_leng = func_ptpv2_msg[type]( ctx
                                       , &packet[ETH_HDR_LEN]
                                       , seq_id);
     // It retusns Eth header length, since payload=0
     packet_leng += gen_eth_packet( packet
                                   , mac_dst
                                   , mac_src
                                   , 0x0 // PKT_TYPE_BROADCASTING/VLAN/HSR
                                   , PTPV2_ETHERNET_TYPE_LENGTH // 0x88F7
                                   , packet_leng // payload length, i.e., PTPv2 message length
                                   , 0); // since already copied
     return packet_leng;
}

#define PRT_MAC(A,B)\
        printf("%s 0x%02X%02X%02X%02X%02X%02X\n", (A)\
               ,(B)[0],(B)[1],(B)[2],(B)[3],(B)[4],(B)[5])
//-----------------------------------------------------------------------------
// Generate PTPv2 over UDP/IP/Etherent packet.
int gen_ptpv2_udp_ip_ethernet( ptpv2_ctx_t *ctx
                             , uint8_t     *packet
                             , uint8_t      type
                             , uint16_t     seq_id
                             , uint8_t      mac_src[6]
                             , uint32_t     ip_src
                             )
{
printf("%s() 0x%02X\r\v", __FUNCTION__, type);
     uint16_t packet_leng;
     uint8_t  loc;
     uint8_t  mac_dst[6];
     uint16_t port_dst, port_src;
     uint32_t ip_dst;
     switch (type) {
     case 0x0: // Event:Sync
     case 0x1: // Event:Delay_Req
     case 0x2: // Event:Pdelay_Req
     case 0x3: // Event:Pdelay_Resp
               port_src   = 319; // 0x013F
               port_dst   = 319; // 0x013F
               ip_dst     = 0xE0000181;
               mac_dst[0] = 0x01;
               mac_dst[1] = 0x00;
               mac_dst[2] = 0x5E;
               mac_dst[3] = 0x00;
               mac_dst[4] = 0x01;
               mac_dst[5] = 0x81; break;
     case 0x8: // General:Follow_Up
     case 0x9: // General:Delay_Resp
     case 0xA: // General:Pdelay_Resp_Follow_Up
     case 0xB: // General:Announce
     case 0xC: // General:Signaling
     case 0xD: // General:Management
               port_src   = 320; // 0x0140
               port_dst   = 320; // 0x0140
               ip_dst     = 0xE000006B;
               mac_dst[0] = 0x01;
               mac_dst[1] = 0x00;
               mac_dst[2] = 0x5E;
               mac_dst[3] = 0x00;
               mac_dst[4] = 0x00;
               mac_dst[5] = 0x6B; break;
     default: PTPV2_ERROR("undefined PTPv2 message type: 0x%1X", type);
              port_src   = 320;
              port_dst   = 320;
              ip_dst     = 0xE000006B;
     }
     loc = ETH_HDR_LEN+IP_HDR_LEN+UDP_HDR_LEN;
     packet_leng = (func_ptpv2_msg[type])(ctx, &packet[loc], seq_id);
printf("%s() packet_leng=%d loc=%d\n", __FUNCTION__, packet_leng, loc);
     loc -= UDP_HDR_LEN;
     // It retusns UDP header length, since payload=0
     packet_leng += gen_udp_packet(&packet[loc]
                                  , port_src // host order
                                  , port_dst // host order
                                  , packet_leng // UDP payload length
                                  , 0); // since already copied
     loc -= IP_HDR_LEN;
     // It retusns IP header length, since payload=0
     packet_leng += gen_ip_packet(&packet[loc]
                                 , ip_src // host order
                                 , ip_dst // host order
                                 , IP_PROTO_UDP // 0x11
                                 , packet_leng
                                 , 0); // since already copied
     loc -= ETH_HDR_LEN;
     // It retusns Eth header length, since payload=0
     packet_leng += gen_eth_packet(&packet[loc]
                                  , mac_dst
                                  , mac_src
                                   , 0x0 // PKT_TYPE_BROADCASTING/VLAN/HSR
                                  , ETH_TYPE_IP // 0x0800
                                  , packet_leng
                                  , 0);// since already copied
#if 1
     PRT_MAC("mac_src",mac_src);
     PRT_MAC("mac_dst",mac_dst);
     parser_eth_packet(packet, packet_leng);
#endif
     return packet_leng;
}

//-----------------------------------------------------------------------------
static ptpv2_ctx_t ptpv2_ctx = {
       2, // ptpv2_ctx.ptp_version   
       0, // ptpv2_ctx.ptp_domain    
       0, // ptpv2_ctx.one_step_clock
       0, // ptpv2_ctx.unicast_port  
       0, // ptpv2_ctx.profile_spec1 
       0, // ptpv2_ctx.profile_spec2 
       {0,0,0,0,0,0,0,0},  // ptpv2_ctx.clock_id
       0  // ptpv2_ctx.port_num
       };

//-----------------------------------------------------------------------------
ptpv2_ctx_t *gen_ptpv2_context( uint32_t ptp_version   
                              , uint32_t ptp_domain    
                              , uint32_t one_step_clock
                              , uint32_t unicast_port  
                              , uint32_t profile_spec1 
                              , uint32_t profile_spec2 
                              , uint8_t  clock_id[8]
                              , uint16_t port_num
                              )
{
    extern void *memcpy(void *dst, void *src, unsigned int bytes);
    ptpv2_ctx.ptp_version    = ptp_version   ;
    ptpv2_ctx.ptp_domain     = ptp_domain    ;
    ptpv2_ctx.one_step_clock = one_step_clock;
    ptpv2_ctx.unicast_port   = unicast_port  ;
    ptpv2_ctx.profile_spec1  = profile_spec1 ;
    ptpv2_ctx.profile_spec2  = profile_spec2 ;
    memcpy(ptpv2_ctx.clock_id,clock_id,8);
    ptpv2_ctx.port_num       = port_num  ;
    return &ptpv2_ctx;
}

//-----------------------------------------------------------------------------
ptpv2_ctx_t *get_ptpv2_context( )
{
    return &ptpv2_ctx;
}

//-----------------------------------------------------------------------------
// Revision history:
//
// 2019.05.20: 'gen_eth/ip/udp_packet()' argument order changed.
// 2014.12.25: 'populate_ptpv2_msg_hdr()' is updated.
//             'gen_ptpv2_context()' is updated by adding 'clock_id' and 'port_num'.
// 2014.06.27: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------------------
