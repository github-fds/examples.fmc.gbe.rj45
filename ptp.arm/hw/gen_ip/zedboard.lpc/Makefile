#------------------------------------------------------------------
# VIVADO Batch Mode 
#------------------------------------------------------------------
# Copyright (c) 2016 by Dynalith.
# All right reserved.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
export VIVADO     = $(XILINX_VIVADO)/bin/vivado
export SOURCE     = vivado_gen_ip.tcl
export BOARD_PART = em.avnet.com:zed:part0
export PART       = xc7z020clg484-1
export MODULE     = mac_ptp_axi
export DIR_WORK       = work
export DIR_DESIGN     = ../../design/verilog
export DIR_EDIF       = ../../syn/vivado.zedboard.lpc
export DIR_XDC        = ../../syn/vivado.zedboard.lpc/xdc
export RIGOR      = 1
export GUI       ?= 0

#------------------------------------------------------------------
all: check vivado

check:
	@if [ ! -f $(DIR_EDIF)/$(MODULE).edn ]; then\
		echo "$(DIR_EDIF)/$(MODULE).edn not found";\
		exit;\
	fi
	@if [ ! -f $(DIR_DESIGN)/$(MODULE)_blackbox.v ]; then\
		echo "$(DIR_DESIGN)/$(MODULE)_blackbox.v not found";\
		exit;\
	fi

vivado:
	@if [ $(GUI) -eq 0 ]; then\
		$(VIVADO) -mode batch -source $(SOURCE);\
	else\
		$(VIVADO) -mode gui -source $(SOURCE);\
	fi

#------------------------------------------------------------------
DIRS    = $(subst /,, $(dir $(wildcard */Makefile)))

clean:
	-@/bin/rm -rf .Xil
	-@/bin/rm -f  *.html
	-@/bin/rm -f  *.jou
	-@/bin/rm -f  *.backup*
	-@/bin/rm -f  *.log
	-@/bin/rm -f  planAhead.*
	-@/bin/rm -f  vivado.log
	-@/bin/rm -f  vivado_pid*.str  vivado_pid*.debug
	-@/bin/rm -f  fsm_encoding.os
	-@/bin/rm -fr $(MODULE).sim  $(MODULE).srcs

cleanup clobber: clean
	-@/bin/rm -f  $(MODULE).ucf
	-@/bin/rm -f  $(MODULE).ut
	-@/bin/rm -f  $(MODULE).tcf
	-@/bin/rm -rf work
	-@/bin/rm -rf sim
	-@/bin/rm -rf xgui
	-@/bin/rm -rf $(MODULE).cache
	-@/bin/rm -rf $(MODULE).hw
	-@/bin/rm -rf $(MODULE).ip_user_files
	-@/bin/rm -rf $(MODULE).sim

cleanupall: cleanup
	-@/bin/rm -f  $(MODULE).xpr
	-@/bin/rm -f  component.xml
	-@/bin/rm -rf src
