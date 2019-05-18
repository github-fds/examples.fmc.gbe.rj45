#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include "defines_system.h"
#include "map_mem.h"

volatile uint32_t *pBRAM;
volatile uint32_t *pTXBUFF;
volatile uint32_t *pRXBUFF;

int map_mem(void)
{
    int fd;
    fd = open("/dev/mem", O_RDWR|O_SYNC);
    if (fd < 0) {
        perror("/dev/mem");
        return -1;
     }

     pBRAM = mmap( 0, GBE_BRAM_SIZE, PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, (uint32_t)ADDR_BRAM_START);
     if (pBRAM==MAP_FAILED) {
         perror("bram");
         return(-1);
     }

     pTXBUFF = mmap( 0, GBE_TX_BUFF_SIZE, PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, (uint32_t)ADDR_GBE_BRAM_TX_START);
     if (pTXBUFF==MAP_FAILED) {
         perror("tx-buff");
         return(-1);
     }

     pRXBUFF = mmap( 0, GBE_RX_BUFF_SIZE, PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, (uint32_t)ADDR_GBE_BRAM_RX_START);
     if (pRXBUFF==MAP_FAILED) {
         perror("rx-buff");
         return(-1);
     }

     pMAC = mmap( 0, getpagesize(), PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, (uint32_t)ADDR_GBE_MAC_START);
     if (pMAC==MAP_FAILED) {
         perror("mac");
         return(-1);
     }

     pHSR = mmap( 0, getpagesize(), PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, (uint32_t)ADDR_HSR_START);
     if (pHSR==MAP_FAILED) {
         perror("hsr");
         return(-1);
     }

     pGPIO = mmap( 0, getpagesize(), PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, (uint32_t)ADDR_GPIO_START);
     if (pGPIO==MAP_FAILED) {
         perror("gpio");
         return(-1);
     }
     return 0;
}
