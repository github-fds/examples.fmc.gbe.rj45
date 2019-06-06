#ifndef PTPV2_MESSAGE_H
#define PTPV2_MESSAGE_H
//----------------------------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//----------------------------------------------------------------------------
// VERSION = 2014.12.25.
//----------------------------------------------------------------------------
// ptpv2_message.h
//----------------------------------------------------------------------------
#include "eth_ip_udp_pkt.h"
#include "ptpv2_type.h"
#include "ptpv2_etc.h"
#include "ptpv2_context.h"
#include "ptpv2_message.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int (*func_ptpv2_msg[16])( ptpv2_ctx_t *ctx
                                , uint8_t     *msg
                                , uint16_t     seq_id);

extern int populate_ptpv2_msg_hdr( ptpv2_ctx_t     *ctx
                                 , ptpv2_msg_hdr_t *hdr
                                 , uint8_t          type
                                 , uint16_t         seq_id
                                 );

extern int gen_ptpv2_msg( ptpv2_ctx_t *ctx
                        , uint8_t      type
                        , uint8_t     *msg
                        , uint16_t     seq_id
                        );
extern int gen_ptpv2_msg_sync( ptpv2_ctx_t *ctx
                             , uint8_t     *msg
                             , uint16_t     seq_id
                             );

extern int gen_ptpv2_msg_follow_up( ptpv2_ctx_t *ctx
                                  , uint8_t     *msg
                                  , uint16_t     seq_id
                                  );

extern int gen_ptpv2_msg_delay_req( ptpv2_ctx_t *ctx
                                  , uint8_t     *msg
                                  , uint16_t     seq_id
                                  );

extern int gen_ptpv2_msg_pdelay_req( ptpv2_ctx_t *ctx
                                   , uint8_t     *msg
                                   , uint16_t     seq_id
                                   );
extern int gen_ptpv2_msg_pdelay_resp( ptpv2_ctx_t *ctx
                                    , uint8_t     *msg
                                    , uint16_t     seq_id
                                    );

extern int gen_ptpv2_msg_delay_resp( ptpv2_ctx_t *ctx
                                   , uint8_t     *msg
                                   , uint16_t     seq_id
                                   );
extern int gen_ptpv2_msg_pdelay_resp_follow_up( ptpv2_ctx_t *ctx
                                              , uint8_t     *msg
                                              , uint16_t     seq_id
                                              );
extern int gen_ptpv2_msg_announce( ptpv2_ctx_t *ctx
                                  , uint8_t     *msg
                                  , uint16_t     seq_id
                                  );
extern int gen_ptpv2_msg_signaling( ptpv2_ctx_t *ctx
                                  , uint8_t     *msg
                                  , uint16_t     seq_id
                                  );
extern int gen_ptpv2_msg_management( ptpv2_ctx_t *ctx
                                   , uint8_t     *msg
                                   , uint16_t     seq_id
                                   );

extern int gen_ptpv2_ethernet( ptpv2_ctx_t *ctx
                             , uint8_t     *packet
                             , uint8_t      type // PTPv2 message type
                             , uint16_t     seq_id // PTPv2 sequenceID
                             , uint8_t      mac_src[6] // MAC source (network order)
                             );

extern int gen_ptpv2_udp_ip_ethernet( ptpv2_ctx_t *ctx
                                    , uint8_t     *packet
                                    , uint8_t      type // PTPv2 message type
                                    , uint16_t     seq_id // PTPv2 sequenceID
                                    , uint8_t      mac_src[6] // MAC source (network order)
                                    , uint32_t     ip_src // IP source (host order):q
                                    );

extern ptpv2_ctx_t *gen_ptpv2_context( uint32_t ptp_version   
                                     , uint32_t ptp_domain    
                                     , uint32_t one_step_clock
                                     , uint32_t unicast_port  
                                     , uint32_t profile_spec1 
                                     , uint32_t profile_spec2 
                                     , uint8_t  clock_id[8]
                                     , uint16_t port_num
                                     );

extern ptpv2_ctx_t *get_ptpv2_context( );

#ifdef __cplusplus
}
#endif
//-----------------------------------------------------------------------------
// Revision history:
//
// 2014.12.25: 'populate_ptpv2_msg_hdr()' is updated.
//             'gen_ptpv2_context()' is updated by adding 'clock_id' and 'port_num'.
// 2014.06.26: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------------------
#endif // PTPV2_MESSAGE_H
