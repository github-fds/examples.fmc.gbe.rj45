#include "non_block_getchar.h"

void RestoreKeyboardBlocking(struct termios *initial_settings)
{
	tcsetattr(0, TCSANOW, initial_settings);
}

void SetKeyboardNonBlock(struct termios *initial_settings)
{

    struct termios new_settings;
    tcgetattr(0,initial_settings);

    new_settings = *initial_settings;
    new_settings.c_lflag &= ~ICANON;
    new_settings.c_lflag &= ~ECHO;
    new_settings.c_lflag &= ~ISIG;
    new_settings.c_cc[VMIN] = 0;
    new_settings.c_cc[VTIME] = 0;

    tcsetattr(0, TCSANOW, &new_settings);
}

#if 0
int main()
{
    struct termios term_settings;
    char c = 0;

    SetKeyboardNonBlock(&term_settings);

    while(c != 'Q')
    {
        c = getchar();
        if(c > 0)
            printf("Read: %c\n", c);
    }

    //Not restoring the keyboard settings causes the input from the terminal to not work right
    RestoreKeyboardBlocking(&term_settings);

    return 0;
}
#endif 
