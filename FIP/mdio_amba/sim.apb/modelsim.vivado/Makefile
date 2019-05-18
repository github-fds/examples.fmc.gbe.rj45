SHELL		= /bin/sh
MAKEFILE	= Makefile

ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif

#--------------------------------------------------------
VLIB	= $(shell which vlib)
VLOG	= $(shell which vlog)
VSIM	= $(shell which vsim)
#--------------------------------------------------------
STR     = $(shell $(VSIM) -version)
VVER    = $(shell for S in $(STR); do\
                if [ "$${NN}" = "vsim" ]; then\
                        echo $$S;\
                fi;\
                NN=$$S;\
        done)
MAJOR   = $(firstword $(subst ., , $(VVER)))
ifeq ($(findstring Sim-64,$(STR)),Sim-64)
     WIDTH= 64
else
     WIDTH= 32
endif
#--------------------------------------------------------
ifeq ($(shell test $(MAJOR) -ge 10; echo $$?),0)
        VOPT=-novopt -l transcript
else
        VOPT=-l transcript
endif
#--------------------------------------------------------
WORK	= work
TOP	= top

#--------------------------------------------------------
all: compile simulate

compile:
	$(VLIB)	$(WORK)
	$(VLOG) -lint -work $(WORK) -f modelsim.args 2>&1 | tee compile.log

simulate: compile
	$(VSIM) $(VOPT) -c -do "run -all; quit" $(WORK).$(TOP)

#--------------------------------------------------------
clean:
	-@/bin/rm -rf $(WORK) unisims_ver
	-@/bin/rm -f  transcript compile.log
	-@/bin/rm -f  wave.vcd dump.vcd
	-@/bin/rm -f  vsim.wlf
	-@/bin/rm -f  vish_stacktrace.vstf

cleanup clobber: clean

cleanupall: cleanup
