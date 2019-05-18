#-------------------------------------------------------------------------------
SHELL	=/bin/bash

#-------------------------------------------------------------------------------
ILA ?= 0
#-------------------------------------------------------------------------------
export BOOTGEN      = $(XILINX_SDK)/bin/bootgen
export PROG_FLASH   = $(XILINX_SDK)/bin/program_flash
export BOOT_FILE    = BOOT.bin
export BIF_FILE     = zed_bd.bif
export FSBL_FILE    = ../sw.arm/fsbl/fsbl_0.elf
ifeq ($(ILA),1)
export WRAPPER_FILE = ../hw/impl/zedboard.lpc/ila/zed_bd_wrapper.bit
else
export WRAPPER_FILE = ../hw/impl/zedboard.lpc/zed_bd_wrapper.bit
endif
export ELF_FILE    ?= ../sw.arm/eth_send_receive/eth_send_receive.elf

#-------------------------------------------------------------------------------
all: boot

boot: bif
	@if [ ! -f ${BIF_FILE} ]; then echo "${BIF_FILE} not found"; exit; fi
	$(BOOTGEN) -image $(BIF_FILE) -arch zynq -o $(BOOT_FILE) -w on

bif:
	@if [ ! -f ${WRAPPER_FILE} ]; then echo "${WRAPPER_FILE} not found"; exit; fi
	@if [ -f ${BIF_FILE} ]; then /bin/rm -f ${BIF_FILE}; fi
	echo "//arch = zynq; split = false; format = BIN" >  ${BIF_FILE}
	echo "the_ROM_image:"                             >> ${BIF_FILE}
	echo "{"                                          >> ${BIF_FILE}
	echo "	[bootloader]./${FSBL_FILE}"               >> ${BIF_FILE}
	echo "	${WRAPPER_FILE}"                          >> ${BIF_FILE}
	echo "	${ELF_FILE}"                              >> ${BIF_FILE}
	echo "}"                                          >> ${BIF_FILE}

prog: $(BOOT_FILE)
	@if [ ! -f ${BOOT_FILE} ]; then echo "${BOOT_FILE} not found"; exit; fi
	@if [ ! -f ${FSBL_FILE} ]; then echo "${FSBL_FILE} not found"; exit; fi
	@$(PROG_FLASH) -f $(BOOT_FILE) -fsbl $(FSBL_FILE)\
		-flash_type qspi_single -verify\
		-cable type xilinx_tcf url TCP:127.0.0.1:3121


#-------------------------------------------------------------------------------
.PHONY: clean cleanup clobber cleanupall

clean:
	/bin/rm -f  $(BOOT_FILE)
	/bin/rm -f  vivado.log

cleanup clobber: clean
	/bin/rm -f $(BIF_FILE)

cleanupall: cleanup

#-------------------------------------------------------------------------------
