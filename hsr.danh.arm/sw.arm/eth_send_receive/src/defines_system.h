#ifndef DEFINES_SYSTEM_H
#define DEFINES_SYSTEM_H

#define PRINTF xil_printf

#define ADDR_BRAM0_START       0x60000000
#define ADDR_BRAM1_START       0x40000000
#define ADDR_GBE_BRAM_TX_START 0x41000000
#define ADDR_GBE_BRAM_RX_START 0x42000000
#define ADDR_GBE_MAC_START     0x43000000
#define ADDR_GBE_MDIO_START    0x4C000000
#define ADDR_HSR_START         0x4C010000
#define ADDR_GPIO_START        0x4C020000

#define GBE_TX_BUFF_SIZE (16*1024)
#define GBE_RX_BUFF_SIZE (16*1024)

#endif