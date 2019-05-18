#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "linenoise.h"
#include "monitor_command.h"
#include "monitor_cmd_etc.h"
#include "monitor_cmd_memory.h"
#include "monitor_cmd_mac.h"
#include "map_mem.h"

#define MAX_NUM_ARGC   20
#define MAX_LENG_ARGC  128
static int   argc;
static char *argv[MAX_NUM_ARGC];
static char  args[MAX_NUM_ARGC][MAX_LENG_ARGC];

int main(void)
{
    if (map_mem()!=0) {
        printf("ERROR memmap.\n");
        return 0;
    }
#undef  DEBUG
#if defined(DEBUG)
    #include "gpio_api.h"
    #include "gig_eth_mac_api.h"
    #include "gig_eth_hsr_api.h"
    printf("GPIO gpio_read 0x%X\n", gpio_read()); fflush(stdout);
    printf("MAC\n");
    gig_eth_mac_csr_check(); fflush(stdout);
    printf("HSR\n");
    gig_eth_hsr_csr_check(); fflush(stdout);
#endif
    for (int i=0; i<MAX_NUM_ARGC; i++) {
        argv[i] = args[i]; args[i][0] = '\0';
    }
    command_init();
    etc_register();
  //mem_register();
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
            linenoiseHistorySave("history.txt"); /* Save the history on disk. */
        } else if (!strncmp(line,"/historylen",11)) {
            /* The "/historylen" command will change the history len. */
            int len = atoi(line+11);
            linenoiseHistorySetMaxLen(len);
        } else if (line[0] == '/') {
            printf("Unreconized command: %s\n", line);
        }
        free(line);
    }

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
