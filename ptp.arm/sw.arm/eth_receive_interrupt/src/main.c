//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2019.05.20.
//------------------------------------------------------------------------------
// Ethernet PTPv2 slave
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h" // for inbyte()
#include "xuartps_hw.h" // for inbyte()
#include "xil_types.h"
#include "xscugic.h"
#include "xil_exception.h"

#include "defines_system.h"
#include "gig_eth_mac_api.h"
#include "mac_api.h"
#include "gpio_api.h"
#include "timer_api.h"

//------------------------------------------------------------------------------
#define INTC_INTERRUPT_ID_0 61 // IRQ_F2P[0:0] - IRQ_GMAC
#define INTC_INTERRUPT_ID_1 62 // IRQ_F2P[1:1] - IRQ_PTP
#define INTC_INTERRUPT_ID_2 63 // IRQ_F2P[2:2] - IRQ_RTC
#define INTC_INTERRUPT_ID_5 64 // IRQ_F2P[3:3] - IRQ_SWU (push-button sw up)
#define INTC_INTERRUPT_ID_4 65 // IRQ_F2P[4:4] - IRQ_SWD (push-button sw down)
#define INTC_INTERRUPT_ID_3 66 // IRQ_F2P[5:5] - IRQ_GPIO
#define INTC_INTERRUPT_ID_6 67 // IRQ_F2P[6:6] - IRQ_TIMER0
#define INTC_INTERRUPT_ID_7 68 // IRQ_F2P[7:7] - IRQ_TIMER1
#define INTC_INTERRUPT_ID_8 69 // IRQ_F2P[8:8] - IRQ_TIMER2
#define INTC_INTERRUPT_ID_9 70 // IRQ_F2P[9:9] - IRQ_TIMER3
// instance of interrupt controller
static XScuGic intc;

int setup_interrupt_system();

//------------------------------------------------------------------------------
unsigned char board_id=0x0;
static uint8_t  mac_addr[6]={0x02,0x12,0x34,0x56,0x78,0x00};
static uint8_t  conf_tx_jumbo_en=0;
static uint8_t  conf_tx_no_gen_crc=0;
static uint16_t conf_tx_bchunk=4*32;
static uint8_t  conf_rx_jumbo_en=0;
static uint8_t  conf_rx_no_chk_crc=0;
static uint8_t  conf_rx_promiscuous=0;
static uint16_t conf_rx_bchunk=4*32;
static uint32_t buff_tx_start=ADDR_GBE_BRAM_TX_START;
static uint32_t buff_tx_size =GBE_TX_BUFF_SIZE;
static uint32_t buff_rx_start=ADDR_GBE_BRAM_RX_START;
static uint32_t buff_rx_size =GBE_RX_BUFF_SIZE;
int mac_init_done = 0;

//------------------------------------------------------------------------------
#define PRT_MAC(A,B)\
        printf("%s 0x%02X%02X%02X%02X%02X%02X\n", (A)\
                   ,(B)[0],(B)[1],(B)[2],(B)[3],(B)[4],(B)[5])

//------------------------------------------------------------------------------
int main(void)
{
    //--------------------------------------------------------------------------
    init_platform(); // see platform.c

    //--------------------------------------------------------------------------
    board_id = gpio_read();
    mac_addr[5] = board_id; // last octet (byte)
    if (mac_init_done==0) {
        mac_init( mac_addr
                , conf_tx_jumbo_en
                , conf_tx_no_gen_crc
                , conf_tx_bchunk
                , conf_rx_jumbo_en
                , conf_rx_no_chk_crc
                , conf_rx_promiscuous
                , conf_rx_bchunk
                , buff_tx_start
                , buff_tx_size
                , buff_rx_start
                , buff_rx_size
                , 0
                );
        #if defined(GIG_ETH_HSR)
        gig_eth_hsr_set_mac_addr(mac_addr);
        #endif
        mac_init_done = 1;
    }
    uint8_t mac_tmpA[6];
    gig_eth_mac_get_mac_addr(mac_tmpA);
    PRT_MAC("MAC", mac_tmpA);
    #if defined(GIG_ETH_HSR)
    uint8_t mac_tmpB[6];
    gig_eth_hsr_get_mac_addr(mac_tmpB);
    PRT_MAC("HSR", mac_tmpB);
    #endif

#if 0
    //--------------------------------------------------------------------------
    int          flag_repeat = 1;
    unsigned int verbose=3;
    int          timeout=0;
    do { int ret = eth_receive_packet(timeout,verbose);
         if ((flag_repeat==0)&&(ret<0)) return -1;
         if (flag_repeat==1) {
            if (XUartPs_IsReceiveData(STDIN_BASEADDRESS)) {
                char c=inbyte(); // XUartPs_RecvByte(STDIN_BASEADDRESS);
                if ((c==0x03)||(c==0x1B)) { flag_repeat=0; break; }
            }
         }
    } while (flag_repeat==1);
#else
    // setup and enable interrupts for IRQ_F2P[3:0]
    int status = setup_interrupt_system();
    if (status != XST_SUCCESS) { return XST_FAILURE; }

    gig_eth_mac_interrupt(1); // enable interrupt

    while (1) {
       void nops(unsigned int num);
       nops(100);
    }

    gig_eth_mac_interrupt(0); // disable interrupt

#endif

    //--------------------------------------------------------------------------
    cleanup_platform(); // see platform.c
    return 0;
}

//------------------------------------------------------------------------------
// interrupt service routine for IRQ_F2P[0:0]
static unsigned int int_cnt=0;
void isr0 (void *intc_inst_ptr)
{
     int_cnt++;
     xil_printf("isr0 called %d\n\r", int_cnt);
     unsigned char ip;
     if (!gig_eth_mac_check_ip(&ip)) {
          if (ip) {
              unsigned int verbose=3;
              int          timeout=0;
              gig_eth_mac_clear_ip();
              eth_receive_packet(timeout,verbose);
          }
     }
}

// interrupt service routine for IRQ_F2P[1:1]
void isr1 (void *intc_inst_ptr) {
    xil_printf("isr1 called\n\r");
}

// interrupt service routine for IRQ_F2P[2:2]
void isr2 (void *intc_inst_ptr) {
    xil_printf("isr2 called\n\r");
}

// interrupt service routine for IRQ_F2P[3:3]
void isr3 (void *intc_inst_ptr) {
    xil_printf("isr3 called\n\r");
}

// interrupt service routine for IRQ_F2P[4:4]
void isr4 (void *intc_inst_ptr) {
    xil_printf("isr4 called\n\r");
}

// interrupt service routine for IRQ_F2P[5:5]
void isr5 (void *intc_inst_ptr) {
    xil_printf("isr5 called\n\r");
}

//------------------------------------------------------------------------------
// sets up the interrupt system and enables interrupts for IRQ_F2P[3:0]
int setup_interrupt_system() {

    int result;
    XScuGic *intc_instance_ptr = &intc;
    XScuGic_Config *intc_config;

    // get config for interrupt controller
    intc_config = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
    if (NULL == intc_config) { return XST_FAILURE; }

    // initialize the interrupt controller driver
    result = XScuGic_CfgInitialize(intc_instance_ptr, intc_config, intc_config->CpuBaseAddress);
    if (result != XST_SUCCESS) { return result; }

    // set the priority of IRQ_F2P[0:0] to 0xA0 (highest 0xF8, lowest 0x00) and a trigger for a rising edge 0x3.
    // connect the interrupt service routine isr0 to the interrupt controller
    // enable interrupts for IRQ_F2P[0:0]
#define SET_INT(INT_ID,HANDLER)\
    XScuGic_SetPriorityTriggerType(intc_instance_ptr, (INT_ID), 0xA0, 0x3);\
    result = XScuGic_Connect(intc_instance_ptr, (INT_ID), (Xil_ExceptionHandler)(HANDLER), (void *)&intc);\
    if (result != XST_SUCCESS) { return result; }\
    XScuGic_Enable(intc_instance_ptr, (INT_ID))

    SET_INT(INTC_INTERRUPT_ID_0,isr0);
    SET_INT(INTC_INTERRUPT_ID_1,isr1);
    SET_INT(INTC_INTERRUPT_ID_2,isr2);
    SET_INT(INTC_INTERRUPT_ID_3,isr3);
    SET_INT(INTC_INTERRUPT_ID_4,isr4);
    SET_INT(INTC_INTERRUPT_ID_5,isr5);

    // initialize the exception table and register the interrupt controller handler with the exception table
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, intc_instance_ptr);

    // enable non-critical exceptions
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

//------------------------------------------------------------------------------
void nops(unsigned int num) {
    int i;
    for(i = 0; i < num; i++) {
        asm("nop");
    }
}

//------------------------------------------------------------------------------
// Revision History
//
// 2019.05.20: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
