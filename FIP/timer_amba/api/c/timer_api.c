//--------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2019.05.01.
//--------------------------------------------------------
//             __    __    __    __    __    __    __
// clk      __|  |__|  |__|  |__|  |__|  |__|  |__|
//          __ _______________________________________
// mode     00X_______________________________________
//          ________ _____ _____ _____ _____ _____ ___
// count    ______1_X___2_X___3_X___4_X_____X___P_X___
//                                                 _________
// intr     ______________________________________|       
//
// Note: Internal counter starts from 1 and interrupt
//       occurs when counter equals to period.
//       Interrupt stay 1 until 'IP' is written 0.
// Note: For re-start mode, every num of period clock
//       occurs interrupt, but interrupt should be
//       cleared before new period expires.
//--------------------------------------------------------
#include <stdio.h>
#include "timer_api.h"

//--------------------------------------------------------
// Register access macros
#define GetAddr(id,csr) (((id&0xF)<<4)|(csr))
#define REGRD(A,V)      (V) = *((volatile uint32_t *)(GetAddr(id,A)))
#define REGWR(A,V)     *((volatile uint32_t *)(GetAddr(id,A))) = (V)

//--------------------------------------------------------
#if !defined(ADDR_TICK_START)
#define ADDR_TICK_START   0x4C030000
#endif

//------------------------------------------------------
#define CSRA_TICK_CONTROL   (ADDR_TICK_START+0x00)
#define CSRA_TICK_PERIOD    (ADDR_TICK_START+0x04)
#define CSRA_TICK_COUNTER   (ADDR_TICK_START+0x08)
#define CSRA_TICK_FREQUENCY (ADDR_TICK_START+0x0C)

// tick timer CSR bit fields
#define TICK_MODE_BIT  0x00000003 // bit 31-30 Mode bits
#define TICK_IE_BIT    0x00000004 // bit 29    Interrupt enable bit
#define TICK_IP_BIT    0x00000008 // bit 28    Interrupt pending bit

// tick timer mode
#define TICK_MODE_DISABLE  0x00000000 // tick timer is disabled
#define TICK_MODE_RESTART  0x00000001 // timer is restarted when ttmr[27:0]==ttcr
#define TICK_MODE_ONETIME  0x00000002 // timer is stop when ttmr[27:0]==ttcr
#define TICK_MODE_CONTI    0x00000003 // timer does not stop

// tick timer interrupt
#define TICK_INT_DISABLE   0x00000000
#define TICK_INT_ENABLE    0x00000004

//------------------------------------------------------
void timer_init(int id)
{
    volatile uint32_t val = 0;
    REGWR(CSRA_TICK_CONTROL, val); // disable tick timer
    REGWR(CSRA_TICK_PERIOD , val); // reset counter
    REGWR(CSRA_TICK_COUNTER, val); // reset counter
}

//------------------------------------------------------
#ifndef COMPACT_CODE
static void
compare(char* str, uint32_t val, uint32_t expect)
{
     if (val==expect) {
         printf ("%s 0x%08lX\n", str, val);
     } else {
         printf ("%s 0x%08lX, but 0x%08lX expected\n", str, val, expect);
     }
}
void
timer_csr(int id)
{
     volatile uint32_t value;
     //uart_put_string("TICK initial_value check\n");
     REGRD(CSRA_TICK_CONTROL,value); compare("CSRA_TICK_CONTROL:", value, 0x00);
     REGRD(CSRA_TICK_PERIOD ,value); compare("CSRA_TICK_PERIOD:",  value, 0x00);
     REGRD(CSRA_TICK_COUNTER,value); compare("CSRA_TICK_COUNTER:", value, 0x00);
     REGRD(CSRA_TICK_FREQUENCY,value); compare("CSRA_TICK_FREQUENCY", value, 0x00);
}
#endif
//------------------------------------------------------
// return value of counter
uint32_t timer_get_count(int id)
{
     volatile uint32_t value;
     REGRD(CSRA_TICK_COUNTER, value);
     return value;
}

//------------------------------------------------------
// return frequency in Hz
uint32_t timer_get_frequency(int id)
{
     volatile uint32_t value;
     REGRD(CSRA_TICK_FREQUENCY, value);
     return value;
}

//------------------------------------------------------
// Timer enable
void timer_enable(int id)
{
    volatile uint32_t val;
    REGRD(CSRA_TICK_CONTROL, val);
    val |= TICK_INT_ENABLE;
    REGWR(CSRA_TICK_CONTROL, val);
}
//------------------------------------------------------
// Timer disable
void timer_disable(int id)
{
    volatile uint32_t val;
    REGRD(CSRA_TICK_CONTROL, val);
    val &= ~TICK_IE_BIT;
    REGWR(CSRA_TICK_CONTROL, val);
}
//------------------------------------------------------
// Timer restart when when mode is one time 
void timer_restart(int id)
{
    volatile uint32_t val;
    REGRD(CSRA_TICK_CONTROL, val);
    if ((val&TICK_MODE_BIT)==TICK_MODE_ONETIME) {
       volatile uint32_t zer=0;
       REGWR(CSRA_TICK_COUNTER, zer);
       val &= ~TICK_IP_BIT;
    }
    val |= TICK_INT_ENABLE;
    REGWR(CSRA_TICK_CONTROL, val);
}
//------------------------------------------------------
// Clear interrupt pending bit
void timer_clear_irq(int id)
{
    volatile uint32_t val;
    REGRD(CSRA_TICK_CONTROL, val);
    if ((val&TICK_MODE_BIT)==TICK_MODE_ONETIME) {
       volatile uint32_t zer=0;
       REGWR(CSRA_TICK_COUNTER, zer);
       val &= ~TICK_IE_BIT;
       REGWR(CSRA_TICK_CONTROL, val);
    }
    val &= ~TICK_IP_BIT;
    REGWR(CSRA_TICK_CONTROL, val);
}
//------------------------------------------------------
// initialize Tick timer set mode 
// period: in milli-second
// mode:   0 (disable), 1 (restart), 2 (one-time), 3 (conti)
void timer_set_mili(int id, uint32_t period, uint32_t mode)
{
    volatile uint32_t val;
    volatile uint32_t zer=0;

    if (period==0) return;

    REGRD(CSRA_TICK_FREQUENCY, val);
    unsigned num_mili_sec=val/1000;

    REGWR(CSRA_TICK_CONTROL, zer); // disable tick timer
    val = (period*num_mili_sec); //val = (period*TICK_NUM_MILLI_SECOND);
    REGWR(CSRA_TICK_PERIOD, val);
    REGWR(CSRA_TICK_COUNTER, zer); // reset counter

    val = TICK_INT_ENABLE|mode;
    REGWR(CSRA_TICK_CONTROL, val);
}
//------------------------------------------------------
// initialize Tick timer set mode 
// period: in micro-second
// mode:   0 (disable), 1 (restart), 2 (one-time), 3 (conti)
void timer_set_micro(int id, uint32_t period, uint32_t mode)
{
    volatile uint32_t val;
    volatile uint32_t zer=0;

    if (period==0) return;

    REGRD(CSRA_TICK_FREQUENCY, val);
    unsigned num_micro_sec=val/1000000;

    REGWR(CSRA_TICK_CONTROL, zer); // disable tick timer
    val = (period*num_micro_sec); //val = (period*TICK_NUM_MICRO_SECOND);
    REGWR(CSRA_TICK_PERIOD, val);
    REGWR(CSRA_TICK_COUNTER, zer); // reset counter

    val = TICK_INT_ENABLE|mode;
    REGWR(CSRA_TICK_CONTROL, val);
}

//------------------------------------------------------
// initialize Tick timer set mode 
// period: in second
// mode:   0 (disable), 1 (restart), 2 (one-time), 3 (conti)
void timer_set_second(int id, uint32_t period, uint32_t mode)
{
    volatile uint32_t val;
    volatile uint32_t zer=0;

    if (period==0) return;

    REGRD(CSRA_TICK_FREQUENCY, val);
    unsigned num_sec=val;

    REGWR(CSRA_TICK_CONTROL, zer); // disable tick timer
    val = (period*num_sec); //val = (period*TICK_NUM_MICRO_SECOND);
    REGWR(CSRA_TICK_PERIOD, val);
    REGWR(CSRA_TICK_COUNTER, zer); // reset counter

    val = TICK_INT_ENABLE|mode;
    REGWR(CSRA_TICK_CONTROL, val);
}

//--------------------------------------------------------
#undef REGWR
#undef REGRD

//--------------------------------------------------------
// Revision History
//
// 2019.05.01: Rewritten by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
