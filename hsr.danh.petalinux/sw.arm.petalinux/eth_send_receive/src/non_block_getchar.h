#ifndef NON_BLOCK_GETCHAR_H
#define NON_BLOCK_GETCHAR_H
#include <termios.h>
#include <stdlib.h>

struct termios term_settings;
#define NON_BLOCK_INIT\
    SetKeyboardNonBlock(&term_settings);
#define NON_BLOCK_EXIT\
    RestoreKeyboardBlocking(&term_settings);

extern void RestoreKeyboardBlocking(struct termios *initial_settings);
extern void SetKeyboardNonBlock(struct termios *initial_settings);
#endif 
