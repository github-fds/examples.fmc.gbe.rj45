//--------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// mdio_api.c
//--------------------------------------------------------------------
// VERSION = 2018.10.14.
//--------------------------------------------------------------------
//#ifndef COMPACT_CODE
//#endif
//--------------------------------------------------------------------
#ifdef TRX_BFM
#	include <stdio.h>
#	include "bfm_api.h"
#	define   uart_put_string(x)  printf("%s", (x));
#	define   uart_put_hexn(n,m)  printf("%x", (n));
#else
#	include "uart_api.h"
#endif
#include "memory_map.h"
#include "mdio_api.h"

//--------------------------------------------------------------------
// Register access macros
#ifdef TRX_BFM
#   define REGRD(A,B)  BfmRead((unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define REGWR(A,B)  BfmWrite((unsigned int)(A), (unsigned int*)&(B), 4, 1);
#else
#   define REGRD(A,V)  (V) = *((volatile uint32_t *)(A))
#   define REGWR(A,V)  *((volatile uint32_t *)(A)) = (V)
#endif
//--------------------------------------------------------------------
#define MDIO_VERSION   0x20181011
#define MDIO_CLK_DIV   11
#ifndef ADDR_GBE_MDIO_START
#error  ADDR_GBE_MDIO_START should be defined
#endif
#define CSRA_MDIO_NAME0     (ADDR_GBE_MDIO_START+0x000)
#define CSRA_MDIO_NAME1     (ADDR_GBE_MDIO_START+0x004)
#define CSRA_MDIO_NAME2     (ADDR_GBE_MDIO_START+0x008)
#define CSRA_MDIO_NAME3     (ADDR_GBE_MDIO_START+0x00C)
#define CSRA_MDIO_COMP0     (ADDR_GBE_MDIO_START+0x010)
#define CSRA_MDIO_COMP1     (ADDR_GBE_MDIO_START+0x014)
#define CSRA_MDIO_COMP2     (ADDR_GBE_MDIO_START+0x018)
#define CSRA_MDIO_COMP3     (ADDR_GBE_MDIO_START+0x01C)
#define CSRA_MDIO_VERSION   (ADDR_GBE_MDIO_START+0x020)
#define CSRA_MDIO_CONTROL   (ADDR_GBE_MDIO_START+0x030)
#define CSRA_MDIO_STATUS    (ADDR_GBE_MDIO_START+0x034)
#define CSRA_MDIO_WR_CMD    (ADDR_GBE_MDIO_START+0x038)
#define CSRA_MDIO_RD_CMD    (ADDR_GBE_MDIO_START+0x03C)
//--------------------------------------------------------------------
// MDIO
#define MDIO_ctl_en           31
#define MDIO_ctl_rst          30
#define MDIO_ctl_ie_rd        17
#define MDIO_ctl_ie_wr        16
#define MDIO_ctl_clk_div      10
#define MDIO_sts_ip_rd        17
#define MDIO_sts_ip_wr        16
#define MDIO_sts_ack          2
#define MDIO_sts_done         1
#define MDIO_sts_busy         0
#define MDIO_wr_phy           21
#define MDIO_wr_addr          16
#define MDIO_wr_data          0
#define MDIO_rd_phy           21
#define MDIO_rd_addr          16
#define MDIO_rd_data          0
#define MDIO_ctl_en_MSK       (1<<MDIO_ctl_en     )
#define MDIO_ctl_rst_MSK      (1<<MDIO_ctl_rst    )
#define MDIO_ctl_ie_rd_MSK    (1<<MDIO_ctl_ie_rd  )
#define MDIO_ctl_ie_wr_MSK    (1<<MDIO_ctl_ie_wr  )
#define MDIO_ctl_clk_div_MSK  (0xFFFF<<MDIO_ctl_clk_div)
#define MDIO_sts_ip_rd_MSK    (1<<MDIO_sts_ip_rd  )
#define MDIO_sts_ip_wr_MSK    (1<<MDIO_sts_ip_wr  )
#define MDIO_sts_ack_MSK      (1<<MDIO_sts_ack    )
#define MDIO_sts_done_MSK     (1<<MDIO_sts_done   )
#define MDIO_sts_busy_MSK     (1<<MDIO_sts_busy   )
#define MDIO_wr_phy_MSK       (0x1F<<MDIO_wr_phy     )
#define MDIO_wr_addr_MSK      (0x1F<<MDIO_wr_addr    )
#define MDIO_wr_data_MSK      (0xFFFF<<MDIO_wr_data    )
#define MDIO_rd_phy_MSK       (0x1F<<MDIO_rd_phy     )
#define MDIO_rd_addr_MSK      (0x1F<<MDIO_rd_addr    )
#define MDIO_rd_data_MSK      (0xFFFF<<MDIO_rd_data    )

//--------------------------------------------------------------------
void mdio_reset() {
     uint32_t value;
     REGRD(CSRA_MDIO_CONTROL,value);
     value |= MDIO_ctl_rst_MSK;
     REGWR(CSRA_MDIO_CONTROL,value);
     value &= ~MDIO_ctl_rst_MSK;
     REGWR(CSRA_MDIO_CONTROL,value);
}
//--------------------------------------------------------------------
void mdio_enable ( int en ) {
     volatile uint32_t cdata;
     REGRD(CSRA_MDIO_CONTROL, cdata); // read control reg.
     if (en) cdata |=   1<<MDIO_ctl_en;
     else    cdata &= ~(1<<MDIO_ctl_en);
     REGWR(CSRA_MDIO_CONTROL, cdata); // update control reg.
}
//--------------------------------------------------------------------
// MAX24287: min T>=80nsec  f<=12.5Mhz
// RTL8211:  min T>=400nsec f<=2.5Mhz
// (MDC frequency) = (HCLK frequency)/ [2*(1+value)]
// HCLK=50Mhz, MDC=2Mhz, div=11
uint32_t mdio_clk_div ( uint32_t div ) { // [15:0]
     volatile uint32_t cdata;
     REGRD(CSRA_MDIO_CONTROL, cdata); // read control reg.
     cdata = (cdata&~0xFFFF)|(div&0xFFFF);
     REGWR(CSRA_MDIO_CONTROL, cdata); // read control reg.
     REGRD(CSRA_MDIO_CONTROL, cdata); // read control reg.
     return cdata&0xFFFF;
}
//--------------------------------------------------------------------
#define MDIO_BUSY_WAIT(rdata,num)\
     (num) = 0xFFFFFF;\
     do { REGRD(CSRA_MDIO_STATUS, (rdata)); num--;\
     } while (((rdata)&(1<<MDIO_sts_busy))&&((num)>0));\
     if ((num)<=0) return 1
#define MDIO_DONE_WAIT(rdata,num)\
     (num) = 0xFFFFFF;\
     do { REGRD(CSRA_MDIO_STATUS, (rdata)); num--;\
     } while (!((rdata)&(1<<MDIO_sts_done))&&((num)>0));\
     if ((num)<=0) return 1
//--------------------------------------------------------------------
int mdio_write( uint32_t phy_addr // [ 4:0] 
              , uint32_t reg_addr // [ 4:0] 
              , uint32_t data)    // [15:0] 
{
     volatile uint32_t cdata, rdata, wdata, num;
     REGRD(CSRA_MDIO_CONTROL, cdata); // read control reg.
     if (!(cdata&(1<<MDIO_ctl_en))) {
         cdata |= 1<<MDIO_ctl_en;
         REGWR(CSRA_MDIO_CONTROL, cdata); // write control reg.
     }
     MDIO_BUSY_WAIT(rdata,num); // wait until normal
     wdata = ( phy_addr & 0x1F  ) << MDIO_wr_phy
           | ( reg_addr & 0x1F  ) << MDIO_wr_addr
           | ( data     & 0xFFFF);
     REGWR(CSRA_MDIO_WR_CMD, wdata);
     MDIO_DONE_WAIT(rdata,num); // wait done
     return 0;
}
//--------------------------------------------------------------------
int mdio_read( uint32_t  phy_addr // [ 4:0] 
             , uint32_t  reg_addr // [ 4:0] 
             , uint32_t *data)    // [15:0] 
{
     volatile uint32_t cdata, rdata, wdata, num;
     REGRD(CSRA_MDIO_CONTROL, cdata); // read control reg.
     if (!(cdata&(1<<MDIO_ctl_en))) {
         cdata |= 1<<MDIO_ctl_en;
         REGWR(CSRA_MDIO_CONTROL, cdata); // write control reg.
     }
     MDIO_BUSY_WAIT(rdata,num); // wait while busy
     wdata = ( phy_addr & 0x1F  ) << MDIO_wr_phy
           | ( reg_addr & 0x1F  ) << MDIO_wr_addr;
     REGWR(CSRA_MDIO_RD_CMD, wdata);
     MDIO_DONE_WAIT(rdata,num); // wait done
     REGRD(CSRA_MDIO_RD_CMD, rdata);
     *data = rdata&0xFFFF;
     return 0;
}
//--------------------------------------------------------------------
#ifndef COMPACT_CODE
#define check_default(addr,msg,eval)\
     REGRD((addr), rdata);\
     uart_put_string("MDIO CSR ");\
     uart_put_string((msg));\
     uart_put_string(" A:0x");\
     uart_put_hexn((addr),8);\
     uart_put_string(" D:0x");\
     uart_put_hexn(rdata,8);\
     uart_put_string(" ");\
     if (rdata!=(eval)) {\
         uart_put_string(", but 0x");\
         uart_put_hexn((eval),8);\
         uart_put_string(" expected\r\n");\
     } else uart_put_string("OK\r\n")

void mdio_csr_check ( ) {
     uint32_t rdata;
     check_default(CSRA_MDIO_NAME0   ,"MDIO_NAME0   ",*((uint32_t*)&"OIDM"));
     check_default(CSRA_MDIO_NAME1   ,"MDIO_NAME1   ",*((uint32_t*)&"ABMA"));
     check_default(CSRA_MDIO_NAME2   ,"MDIO_NAME2   ",*((uint32_t*)&"    "));
     check_default(CSRA_MDIO_NAME3   ,"MDIO_NAME3   ",*((uint32_t*)&"    "));
     check_default(CSRA_MDIO_COMP0   ,"MDIO_COMP0   ",*((uint32_t*)&"UTUF"));
     check_default(CSRA_MDIO_COMP1   ,"MDIO_COMP1   ",*((uint32_t*)&"D ER"));
     check_default(CSRA_MDIO_COMP2   ,"MDIO_COMP2   ",*((uint32_t*)&"GISE"));
     check_default(CSRA_MDIO_COMP3   ,"MDIO_COMP3   ",*((uint32_t*)&"   N"));
     check_default(CSRA_MDIO_VERSION ,"MDIO_VERSION ",MDIO_VERSION);
     check_default(CSRA_MDIO_CONTROL ,"MDIO_CONTROL ",MDIO_CLK_DIV);
     check_default(CSRA_MDIO_STATUS  ,"MDIO_STATUS  ",0x00000000);
     check_default(CSRA_MDIO_WR_CMD  ,"MDIO_WR_CMD  ",0xD4000000);
     check_default(CSRA_MDIO_RD_CMD  ,"MDIO_RD_CMD  ",0xD8000000);
}
#endif
//--------------------------------------------------------------------
// Revision History
//
// 2018.07.19: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------------------
