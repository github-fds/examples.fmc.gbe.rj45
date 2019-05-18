#ifndef MAP_MEM_H
#define MAP_MAM_H
#include <stdint.h>

extern volatile uint32_t *pBRAM;
extern volatile uint32_t *pTXBUFF;
extern volatile uint32_t *pRXBUFF;

extern volatile uint32_t *pMAC;
extern volatile uint32_t *pHSR;
extern volatile uint32_t *pGPIO;

extern int map_mem(void);

#endif
