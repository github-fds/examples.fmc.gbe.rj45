#ifndef PTPV2_CONTEXT_H
#define PTPV2_CONTEXT_H
//----------------------------------------------------------------------------
// Copyright (c) 2014 by Ando Ki.
// All right reserved.
//----------------------------------------------------------------------------
// VERSION = 2014.12.25.
//----------------------------------------------------------------------------
// ptpv2_context.h
//----------------------------------------------------------------------------
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//----------------------------------------------------------------------------
typedef struct ptpv2_cfg {
   uint32_t  debug  ; // debuggin mode on / off
   uint32_t  verbose; // verbose level
} ptpv2_cfg_t;

//----------------------------------------------------------------------------
typedef struct ptpv2_ctx {
   uint32_t ptp_version   ;
   uint32_t ptp_domain    ;
   uint32_t one_step_clock;
   uint32_t unicast_port  ;
   uint32_t profile_spec1 ;
   uint32_t profile_spec2 ;
   uint8_t  clock_id[8]   ;
   uint16_t port_num      ;
} ptpv2_ctx_t;

//----------------------------------------------------------------------------
#ifdef __cplusplus
}
#endif
//-----------------------------------------------------------------------------
// Revision history:
//
// 2014.12.25: 'ptpv2_ctx' structure updated by by adding 'clock_id' and 'port_num'.
// 2014.06.26: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------------------
#endif // PTPV2_CONTEXT_H
