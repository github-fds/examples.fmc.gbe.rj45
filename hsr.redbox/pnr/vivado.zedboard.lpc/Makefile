#------------------------------------------------------------------
# VIVADO Batch Mode 
#------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
# All right reserved.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#-------------------------------------------------------------------------------
ifndef FIP_HOME
export FIP_HOME  = ../../../FIP
endif
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
VIVADO_VERSION = $(shell vivado -version | sed -n 1p | cut -d" " -f 2 | cut -c 2-)
export FPGA_TYPE=z7
export FPGA_FAMILY="ZYNQ7000"
export VIVADO=vivado.$(VIVADO_VERSION)
#------------------------------------------------------------------
export VIVADO = $(XILINX_VIVADO)/bin/vivado
export PROJECT_DIR = project_1
export PROJECT_NAME = project_1
export SOURCE = vivado_run.tcl
export WORK   = work
export DEVICE = xc7z020-clg484-1
export MODULE = fpga
export BOARD  = ZED
export RIGOR  = 1
export ILA    ?= 0
export GUI    ?= 0

FLOG	= $(MODULE)
#------------------------------------------------------------------
all: vivado 

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
	-@/bin/rm -rf work .cache
	-@/bin/rm -f  *.html
	-@/bin/rm -f  *.xml
	-@/bin/rm -f  *.jou
	-@/bin/rm -f  *.backup*
	-@/bin/rm -f  planAhead.*
	-@/bin/rm -f  vivado.log
	-@/bin/rm -f  vivado_pid*.str  vivado_pid*.debug
	-@/bin/rm -f  fsm_encoding.os
	-@/bin/rm -f  impact_impact.xwbt  impact.xsl webtalk.log
	-@/bin/rm -rf work
	-@/bin/rm -fr project_1.cache
	-@/bin/rm -fr project_1.hw
	-@/bin/rm -fr project_1.ip_user_files
	-@/bin/rm -f  project_1.xpr
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

cleanup: clean
	-@/bin/rm -f  ./*.log
	-@/bin/rm -f  $(MODULE).ucf
	-@/bin/rm -f  $(MODULE).ut
	-@/bin/rm -f  $(MODULE).tcf
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

clobber: cleanup
	-@/bin/rm -f all.xdc

cleanupall: cleanup
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -rf $(MODULE).edn
	-@/bin/rm -rf $(MODULE).edif
	-@/bin/rm -rf $(MODULE).bit
	-@/bin/rm -rf $(MODULE).ltx
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done
