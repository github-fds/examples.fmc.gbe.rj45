#ifndef MONITOR_COMMAND_H
#define MONITOR_COMMAND_H
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

#define MAX_NUM_CMD          50 // num. of commands
#define MAX_LENG_CMD         20 // length of command string
#define MAX_LENG_CMD_PARAM  100 // length of command parameter string
#define MAX_LENG_CMD_HINT   128 // length of command hint string
#define MAX_LENG_CMD_HELP  1024 // length of command help string

typedef struct {
  char name[MAX_LENG_CMD];
  char params[MAX_LENG_CMD_PARAM];
  int  (*func)(int argc, char *argv[]);
  char hint[MAX_LENG_CMD_HINT];
  char help[MAX_LENG_CMD_HELP];
} command_struct_t;

//--------------------------------------------------------
extern int cmd_position; // command array id to be filled for registration
extern command_struct_t command[MAX_NUM_CMD];

//--------------------------------------------------------
extern void command_init    ( );
extern void command_parser  ( int argc
                            , char *argv[]);
extern void command_help    ( char  cmd[]);
extern int  command_register( char *name
                            , char *params
                            , int (*func)(int argc, char *argv[])
                            , char* hint
                            , char* help);
//--------------------------------------------------------
#if defined(MONITOR_CMD_HISTORY)
extern int   cmd_history_init();
extern int   cmd_history_push(char *cmd_line);
extern char *cmd_history_get(int up_down); // 0: up (old), 1: down
#endif

//--------------------------------------------------------

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif
