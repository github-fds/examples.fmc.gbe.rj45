#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include "linenoise.h"
#include "monitor_command.h"
#include "monitor_cmd_etc.h"
#include "monitor_cmd_memory.h"
#include "monitor_cmd_mac.h"

#define MAX_NUM_ARGC   20
#define MAX_LENG_ARGC  128
static int   argc;
static char *argv[MAX_NUM_ARGC];
static char  args[MAX_NUM_ARGC][MAX_LENG_ARGC];

int main(void)
{
    init_platform(); // see platform.c

#if 0
    extern void monitor(void);
    monitor(); // see monitor.c
#else
    for (int i=0; i<MAX_NUM_ARGC; i++) {
        argv[i] = args[i]; args[i][0] = '\0';
    }
    command_init();
    etc_register();
    mem_register();
    mac_register();

    printf("\n");
    func_head(1, 1);

    char *line;

    setvbuf(stdin, NULL, _IONBF, 0);

    while ((line = linenoise("monitor> ")) != NULL) {
        /* Do something with the string. */
        if ((line[0] != '\0') && (line[0] != '/')) {
            extern int get_argc_argv(char *);
            if (get_argc_argv(line)>0) {
                command_parser(argc, argv);
                linenoiseHistoryAdd(line); /* Add to the history. */
            }
          //linenoiseHistorySave("history.txt"); /* Save the history on disk. */
        } else if (!strncmp(line,"/historylen",11)) {
            /* The "/historylen" command will change the history len. */
            int len = atoi(line+11);
            linenoiseHistorySetMaxLen(len);
        } else if (line[0] == '/') {
            printf("Unreconized command: %s\n", line);
        }
        free(line);
    }
#endif

    cleanup_platform(); // see platform.c
    return 0;
}

/* It removes leading whitespaces and tokenizes the contents of 'line[]'.
 * It returns the number of tokens.
 * It updates 'argc' and 'argv[]'.
 */
int get_argc_argv(char *line)
{
    argc = 0; 
    argv[argc][0]='\0';
    int idx = 0;
    do { while ((line[idx]==' ')||(line[idx]=='\t')) idx++; // remove whitespaces
         if ((line[idx]=='\0')||(line[idx]=='\n')||(line[idx]=='\r')) return argc;
         int idy = 0;
         do { argv[argc][idy]=line[idx];
              idx++; idy++;
         } while ((line[idx]!=' ')&&(line[idx]!='\t')&&
                  (line[idx]!='\0')&&(line[idx]!='\n')&&(line[idx]!='\r'));
         argv[argc][idy] = '\0';
         argc++;
    } while (1);
}
