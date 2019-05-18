//--------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2018.10.02.
//--------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "monitor_command.h"
#include "monitor_cmd_etc.h"

//--------------------------------------------------------
int cmd_position = 0; // command array id to be filled
command_struct_t command[MAX_NUM_CMD] = {
    {"", "", NULL, "", ""}
  , {"", "", NULL, "", ""}
  , {"", "", NULL, "", ""}
  , {"", "", NULL, "", ""}
};

//--------------------------------------------------------
void command_init()
{
     cmd_position = 0; // command array id to be filled
     command[0].name[0] = '\0';
     command[0].hint[0] = '\0';
     command[0].help[0] = '\0';
     command[0].func = 0;
}

//--------------------------------------------------------
// starting pointer of monitor program,
// called from reset handler in crt.asm.
void command_parser(int argc, char *argv[])
{
   int i;
   for (i=0; i<cmd_position; i++) {
       if (strcmp(argv[0], command[i].name)==0) {
          command[i].func(argc, argv);
          return;
       }
   }
   if (i>=cmd_position) {
       printf("Unknown command: %s\n", argv[0]);
   }
}

//--------------------------------------------------------
// print help message for a specific command.
void command_help(char *cmd)
{
   int i;
   for (i=0; i<cmd_position; i++) {
       if (strcmp(cmd, command[i].name)==0) {
          printf("%s\n", command[i].help);
          return;
       }
   }
   if (i>=cmd_position) {
       printf("Unknown command: %s\n", cmd);
   }
}

//--------------------------------------------------------
int command_register( char *name
                    , char *params
                    , int (*func)(int argc, char *argv[])
                    , char* hint
                    , char* help)
{
    if (cmd_position>=MAX_NUM_CMD) {
#ifdef RIGOR
        if (verbose>0) {
            printf("Error: command entry exceed\n");
        }
#endif
        return -1;
    }
    strcpy(command[cmd_position].name, name);
    strcpy(command[cmd_position].params, params);
    strcpy(command[cmd_position].hint, hint);
    strcpy(command[cmd_position].help, help);
    command[cmd_position].func = func;
    cmd_position++;

    return cmd_position-1;
}

#if defined(MONITOR_CMD_HISTORY)
//--------------------------------------------------------
//   ...                            // new one
//   cmd_hist[(pos  )%CMD_HIST_MAX] // current
//   cmd_hist[(pos-1)%CMD_HIST_MAX] // old
//   cmd_hist[(pos-2)%CMD_HIST_MAX] // old old
//   cmd_hist[(pos-3)%CMD_HIST_MAX] // old old old
//   ...
// add 1 for new command line
// sub 1 for get command line for history
#define CMD_HIST_MAX      10
#define MAX_LENG_CMD_LINE 256
int  cmd_hist_num=0; // num of history in the buffer
int  cmd_hist_position=0;
char cmd_hist      [CMD_HIST_MAX][MAX_LENG_CMD_PARAM];
char cmd_hist_valid[CMD_HIST_MAX];

int cmd_history_init(void)
{
    int idx;
    for (idx=0; idx<CMD_HIST_MAX; idx++) {
        cmd_hist      [idx][0] = '\0';
        cmd_hist_valid[idx]    = 0;
    }
    cmd_hist_num=0;
    return 0;
}

// rturn   <0 on error
// return ==0 not pushed
// return >0  num of characters has been pushed excluding null
int cmd_history_push(char *cmd_line)
{
    if (cmd_line==NULL) return -1;
    if ((cmd_line[0]=='\0')||(cmd_line[0]=='\r')||(cmd_line[0]=='\n')) {
        return 0;
    }
    int idx;
    for (idx=1; idx<MAX_LENG_CMD_LINE; idx++) {
         if ((cmd_line[idx]=='\0')||(cmd_line[idx]=='\r')||(cmd_line[idx]=='\n')) {
             break;
         }
    }
    if (idx==MAX_LENG_CMD_LINE) return -1; // no null-terminated
    int len = idx;
    cmd_hist_position = (cmd_hist_position + 1)%CMD_HIST_MAX;
    strcpy((void*)cmd_hist[cmd_hist_position], (void*)cmd_line); // including null
    cmd_hist_valid[cmd_hist_position] = 1;
    cmd_hist_num = (cmd_hist_num+1)%(CMD_HIST_MAX+1);
    return len;
}

// return ==0 when no history
// return !=0 character pointer
char *cmd_history_get(int up_down) // up: old; down: recent
{
    if (cmd_hist_num==0) return 0;
    char *line;
    line = cmd_hist[cmd_hist_position];
    if (up_down==0) { // up-arrow
        cmd_hist_position = (cmd_hist_position - 1)%CMD_HIST_MAX;
    } else { // down-arrow
        cmd_hist_position = (cmd_hist_position + 1)%CMD_HIST_MAX;
    }
    return line;
}
#endif

//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
