#-------------------------------------------------------------------------------
SHELL	=/bin/bash

#-------------------------------------------------------------------------------
export VIVADO    = $(XILINX_SDK)/bin/xsdk
export SOURCE    = run_xsct.tcl
export WORKSPACE = fsbl_workspace
export HDF       = ../../hw/impl/zedboard.lpc/zed_bd_wrapper_sysdef.hdf
export ELF       = fsbl_0.elf

#-------------------------------------------------------------------------------
all:
	@if [ ! -f $(HDF) ]; then\
		echo "ERROR \"$(HDF)\" not found";\
		exit -1;\
	fi
	$(VIVADO) -batch -source $(SOURCE)

#-------------------------------------------------------------------------------
.PHONY: clean cleanup clobber cleanupall

clean:
	@\rm -f  vivado.jou
	@\rm -f  vivado.log
	@\rm -f  vivado_*.backup.jou
	@\rm -f  vivado_*.backup.log
	@\rm -f  vivado_pid*.str
	@\rm -f  vivado_pid*.zip
	@if [ -d .Xil ]; then \rm -fr .Xil; fi
	@if [ -d project_1 ]; then \rm -fr project_1; fi
	@if [ -d hd_visual ]; then \rm -fr hd_visual; fi

cleanup clobber: clean
	@if [ -d fsbl_workspace ]; then \rm -fr fsbl_workspace; fi

cleanupall: cleanup
	/bin/rm -f $(ELF)

#-------------------------------------------------------------------------------
