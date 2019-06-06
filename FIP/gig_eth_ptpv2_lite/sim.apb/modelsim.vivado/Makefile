#------------------------------------------------------------------
# Copyright (c) 2019 by Ando Ki.
# All right reserved.
#
# This code is distributed in the hope that it will
# be useful to understand Ando Ki's book,
# but WITHOUT ANY WARRANTY.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
export FPGA_TYPE= z7
VIVADO_VERSION = $(shell vivado -version | sed -n 1p | cut -d" " -f 2 | cut -c 2-)
export VIVADO   = vivado.$(VIVADO_VERSION)
#------------------------------------------------------------------
ARCH=$(shell uname -s)
MACH=$(shell uname -m)
ifeq ($(findstring MINGW,$(ARCH)),MINGW)
      PLATFORM=mingw
else ifeq ($(findstring CYGWIN,$(ARCH)),CYGWIN)
      PLATFORM=cygwin
else ifeq ($(findstring Linux,$(ARCH)),Linux)
      PLATFORM=linux
endif
#--------------------------------------------------------
VSIM    = $(shell which vsim)
STR     = $(shell $(VSIM) -version)
VVER    = $(shell for S in $(STR); do\
                if [ "$${NN}" = "vsim" ]; then\
                        echo $$S;\
                fi;\
                NN=$$S;\
        done)
#--------------------------------------------------------
VLIB	= $(shell which vlib)
VLOG	= $(shell which vlog)
VSIM	= $(shell which vsim)
ifeq ($(PLATFORM),linux)
PLIOBJS = $(HOME)/work/projects/HsrPtp/network_vpi_lib/v0.7/vpi_lib/modelsim/$(VVER)/$(PLATFORM)_$(MACH)/libnetwork_vpi_lib.so
else ifeq ($(PLATFORM),cygwin)
PLIOBJS = $(HOME)/work/projects/HsrPtp/network_vpi_lib/v0.7/vpi_lib/modelsim/$(VVER)/$(PLATFORM)_$(MACH)/network_vpi_lib.dll
else ifeq ($(PLATFORM),mingw)
PLIOBJS = $(HOME)/work/projects/HsrPtp/network_vpi_lib/v0.7/vpi_lib/modelsim/$(VVER)/$(PLATFORM)_$(MACH)/network_vpi_lib.dll
else
PLIOBJS = $(HOME)/work/projects/HsrPtp/network_vpi_lib/v0.7/vpi_lib/modelsim/$(VVER)/$(PLATFORM)_$(MACH)/libnetwork_vpi_lib.so
endif
#--------------------------------------------------------
TOP	= top
WORK	= work
#--------------------------------------------------------
all: vlib compile simulate

vlib:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	$(VLIB)	$(WORK)

compile:
	if [ -f compile.log ]; then /bin/rm -f compiel.log; fi
	($(VLOG) -lint -work $(WORK) -f modelsim.args || exit 1) 2>&1 | tee compile.log

simulate: compile
	$(VSIM) -novopt -c -do "run -all; quit"\
		-pli $(PLIOBJS)\
		$(WORK).$(TOP) $(WORK).glbl 2>&1 | tee -a compile.log
#--------------------------------------------------------
clean:
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  transcript
	-@/bin/rm -f  wave.vcd dump.vcd
	-@/bin/rm -f  vsim.wlf
	-@/bin/rm -f  vish_stacktrace.vstf
	-@/bin/rm -f  wlft*
	-@/bin/rm -f  compile.log

cleanup clobber: clean

cleanupall: cleanup
#--------------------------------------------------------
