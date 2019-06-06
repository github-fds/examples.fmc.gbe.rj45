#ifndef _TIMER_API_H_
#define _TIMER_API_H_
//--------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2019.05.01.
//--------------------------------------------------------
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void     timer_init      (int id);
extern void     timer_enable    (int id);
extern void     timer_disable   (int id);
extern void     timer_restart   (int id);
extern void     timer_clear_irq (int id);
extern void     timer_set_second(int id, uint32_t period, uint32_t mode);
extern void     timer_set_mili  (int id, uint32_t period, uint32_t mode);
extern void     timer_set_micro (int id, uint32_t period, uint32_t mode);
extern uint32_t timer_get_count (int id);
extern uint32_t timer_get_frequency(int id);
#define timer_set                      timer_set_mili
#define timer_set_restart(id,period)   timer_set(id, (period), 1)
#define timer_set_onetime(id,period)   timer_set(id, (period), 2)
#define timer_set_continue(id,period)  timer_set(id, (period), 3)

extern void timer_csr(int id);

#ifdef __cplusplus
}
#endif

//--------------------------------------------------------
// Revision History
//
// 2019.05.01: Rewritten by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif //_TICK_API_H_
