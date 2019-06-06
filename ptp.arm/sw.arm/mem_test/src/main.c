/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#define MEM_WRITE(A, B)   *(unsigned *)A = B
#define MEM_READ(A, B)    B = *(volatile unsigned *)A

#define BRAM0_ADDR 0x60000000 // outside of mac_ptp_axi
#define BRAM1_ADDR 0x40000000 // BRAM
#define BRAM2_ADDR 0x41000000 // Dual-port BRAM for TX
#define BRAM3_ADDR 0x42000000 // Dual-port BRAM for RX

int
MemTest(unsigned saddr, unsigned depth) {
   unsigned int i, d, err;
   unsigned int send = saddr+depth;
   xil_printf("Info: Address read-after-write test from 0x%x 0x%x \n\r", saddr, send);
   err = 0;
   for (i=saddr; (i+4)<send; i+=4) {
       MEM_WRITE(i, i);
       MEM_READ (i, d);
       if (i!=d) {
           err++;
           xil_printf("Mismatch 0x%x, but 0x%x expected\n\r", d, i);
           return (1);
       }
   }
   if (err==0) {xil_printf("Address read-after-write OK\n\r"); return(0);}
   else { xil_printf("Address read-after-write Fail\n\r"); return(1);}
}

int main()
{
    unsigned int addr;
    unsigned int rdata;
    unsigned int depth;

    init_platform();

    depth =0x100;

    xil_printf("Xilinx BRAM0 Test. \n\r");
    MemTest(BRAM0_ADDR, depth);
    xil_printf("User BRAM1 Test. \n\r");
    MemTest(BRAM1_ADDR, depth);
    xil_printf("User BRAM2 Test. \n\r");
    MemTest(BRAM2_ADDR, depth);
    xil_printf("User BRAM3 Test. \n\r");
    MemTest(BRAM3_ADDR, depth);

    cleanup_platform();
    return 0;
}
