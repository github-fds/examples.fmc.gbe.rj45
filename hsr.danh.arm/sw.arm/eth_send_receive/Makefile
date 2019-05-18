#-------------------------------------------------------------------------------
SHELL	=/bin/bash
#-------------------------------------------------------------------------------
# Do not forget to set 'ILA=1' for ILA design.
# $ make ILA=1 compile
# $ make ILA=1 debug
#-------------------------------------------------------------------------------
ifndef XILINX_SDK
   $(warning XILINX SDK is not define)
endif
ifndef FIP_HOME
   export FIP_HOME=../../../FIP
endif

export XSDK       = $(XILINX_SDK)/bin/xsdk
export XSDB       = $(XILINX_SDK)/bin/xsdb
export zWORKSPACE = workspace
export zINIT      = $(zWORKSPACE)/hw0/ps7_init.tcl
export ILA       ?= 0
ifeq ($(ILA),1)
export zHDF       = ../../hw/impl/zedboard.lpc/ila/zed_bd_wrapper_sysdef.hdf
export zBIT       = ../../hw/impl/zedboard.lpc/ila/zed_bd_wrapper.bit
else
export zHDF       = ../../hw/impl/zedboard.lpc/zed_bd_wrapper_sysdef.hdf
export zBIT       = ../../hw/impl/zedboard.lpc/zed_bd_wrapper.bit
endif
#-------------------------------------------------------------------------------
export zDIR_SRC   = ./src
export zDIR_MAC   = $(FIP_HOME)/gig_eth_mac/api/c
export zDIR_HSR   = $(FIP_HOME)/gig_eth_hsr/api/c
export zPRJ       ?= eth_send_receive
export zELF       ?= $(zPRJ).elf

#-------------------------------------------------------------------------------
all: compile

compile:
	@if [ ! -f ${zHDF} ]; then echo "ERROR ${zHDF} not found"; exit -1; fi
	@if [ ! -f ${zBIT} ]; then echo "ERROR ${zBIT} not found"; exit -1; fi
	$(XSDK) -batch -source run_xsct.tcl 2>&1 | tee log.txt
#	$(XSDK) -workspace $(zWORKSPACE)\
#	        -hwspec ${zHDF}\
#	        -bit ${zBIT}
#	        -source run_xsct.tcl

download:
	$(XSDB) run_xsdb.tcl

debug:
	$(XSDB) -interactive run_xsdb.tcl

#-------------------------------------------------------------------------------
.PHONY: clean cleanup

clean:
	@/bin/rm -f  log.txt
	@/bin/rm -f  vivado.jou
	@/bin/rm -f  vivado.log
	@/bin/rm -f  vivado_*.backup.jou
	@/bin/rm -f  vivado_*.backup.log
	@/bin/rm -f  vivado_pid*.str
	@/bin/rm -f  vivado_pid*.zip
	@/bin/rm -f  hs_err_pid4251.log
	@if [ -d .Xil ]; then /bin/rm -fr .Xil; fi

cleanup clobber: clean
	@if [ -d $(zWORKSPACE) ]; then /bin/rm -fr $(zWORKSPACE); fi
	@if [ -f $(zPRJ).elf ]; then /bin/rm -fr $(zPRJ).elf; fi
	@if [ -f $(zDIR_SRC)/.cproject ]; then /bin/rm -fr $(zDIR_SRC)/.cproject; fi
	@if [ -f $(zDIR_SRC)/.project ]; then /bin/rm -fr $(zDIR_SRC)/.project; fi

cleanupall: cleanup

#-------------------------------------------------------------------------------
