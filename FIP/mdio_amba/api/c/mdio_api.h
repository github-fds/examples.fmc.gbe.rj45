#ifndef MDIO_API_H
#define MDIO_API_H
//--------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// mdio_api.h
//--------------------------------------------------------------------
// VERSION = 2018.10.14.
//--------------------------------------------------------------------
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void mdio_reset( );
extern void mdio_enable ( int en );
extern uint32_t mdio_clk_div ( uint32_t div );
extern int mdio_write( uint32_t phy_addr // [ 4:0] 
                     , uint32_t reg_addr // [ 4:0] 
                     , uint32_t data     // [15:0] 
                     );
extern int mdio_read( uint32_t  phy_addr // [ 4:0] 
                    , uint32_t  reg_addr // [ 4:0] 
                    , uint32_t *data     // [15:0] 
                    );

#ifndef COMPACT_CODE
extern void mdio_csr_check ( );
#endif

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2018.07.19: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif
