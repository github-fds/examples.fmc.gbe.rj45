#ifndef MONITOR_CMD_ETC_H
#define MONITOR_CMD_ETC_H
//--------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2018.10.02.
//--------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

extern int etc_register();
extern int func_verbose(int argc, char *argv[]);
extern int func_help   (int argc, char* argv[]);
extern int func_head   (int lic, int dev);

extern int  verbose;    // 0: no message
extern int  get_verbose();
extern int  set_verbose(int ver);

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif
