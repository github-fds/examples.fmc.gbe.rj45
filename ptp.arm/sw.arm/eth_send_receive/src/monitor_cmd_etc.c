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
#include "strtoi.h"
#include "monitor_command.h"
#include "monitor_version.h"

//--------------------------------------------------------
int verbose=0;

//--------------------------------------------------------
int get_verbose()
{
    return verbose;
}

//--------------------------------------------------------
int set_verbose(int ver)
{
    verbose = ver;
    return ver;
}

//--------------------------------------------------------
// Verbos level
// Return verbose level without level option
// Set verbose level with level option
//
// verbose [level]
int func_verbose   (int argc, char *argv[])
{
    int level;

    if (argc>1) {
       level = strtoi(argv[1]);
       set_verbose(level);
    }
    level = get_verbose();
    printf("verbose level: %d\n", level);

    return level;
}

//--------------------------------------------------------
int func_head ( int lic, int dev )
{
    printf(MONITOR_VERSION);
    printf("Copyright (c) 2018-2019 by Future Design Systems\n");
    printf("www.future-ds.com\n");
    if (lic) {
    printf("This software is provided 'as-is', without any express or implied "
           "warranty.  In no event will the authors be held liable for any damages "
           "arising from the use of this software.\n");
    }
    if (dev) {
    printf("Developed by Ando Ki (adki@future-ds.com)\n");
    }
    return 0;
}

//--------------------------------------------------------
int func_help(int argc, char* argv[])
{
    int pos, dev, lic, i;
    dev = 0;
    lic = 0;
    pos = 1;
    while ((pos<argc)&&(argv[pos][0]=='-')) {
       switch (argv[pos][1]) {
          case 'd': dev = 1; break;
          case 'l': lic = 1; break;
       }
       pos++;
    }
    if (pos<argc) {
        command_help(argv[pos]);
    } else {
        func_head(lic, dev);
        if (!lic && !dev) {
            for (i=0; i<cmd_position; i++) {
                printf("%s\n", command[i].hint);
            }
        }
    }
    return 0;
}

//--------------------------------------------------------
int etc_register(void)
{
  command_register("help", "", func_help,
                   "help [-d] [-l] : print help message",
                   "help [-d] [-l]                              : print help message");
  command_register("verbose", "", func_verbose,
                   "verbose [level] : verbose level",
                   "verbose [level]                             : verbose level");
  return 0;
}

//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
