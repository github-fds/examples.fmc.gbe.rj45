#ifndef _MEM_API_H_
#	define _MEM_API_H_
//********************************************************
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//********************************************************
// mem_api.h
//********************************************************
// VERSION = 2018.10.02.
//********************************************************

#ifdef __cplusplus
extern "C" {
#endif

void mem_test(unsigned saddr, unsigned depth, int level);
int MemTestRAW(unsigned saddr, unsigned depth, unsigned size);
int MemTestBurstRAW(unsigned saddr, unsigned depth, unsigned leng);

#ifdef __cplusplus
}
#endif

//********************************************************
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//********************************************************
#endif
