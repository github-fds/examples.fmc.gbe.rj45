#-------------------------------------------------------------------------------
SHELL	=/bin/bash
#-------------------------------------------------------------------------------
export XSDK = $(XILINX_SDK)/bin/xsdk
export XSDB = $(XILINX_SDK)/bin/xsdb.bat
#export XSDB = $(XILINX_SDK)/bin/xsdb
export WORKSPACE = workspace
export HDF       = ../../hw/impl/zedboard.lpc/zed_bd_wrapper_sysdef.hdf
export PRJ       = mem_test

#-------------------------------------------------------------------------------
all:
	$(XSDK) -batch -source run_xsct.tcl
#	$(XSDK) -workspace $(WORKSPACE) -source run_xsct.tcl

debug:
	$(XSDB) -interactive run_xsdb.tcl

#-------------------------------------------------------------------------------
.PHONY: clean cleanup

clean:
	@\rm -f  vivado.jou
	@\rm -f  vivado.log
	@\rm -f  vivado_*.backup.jou
	@\rm -f  vivado_*.backup.log
	@\rm -f  vivado_pid*.str
	@\rm -f  vivado_pid*.zip
	@if [ -d .Xil ]; then \rm -fr .Xil; fi
	@if [ -d $(WORKSPACE) ]; then \rm -fr $(WORKSPACE); fi

cleanup clobber: clean
	@if [ -f $(PRJ).elf ]; then \rm -fr $(PRJ).elf; fi

cleanupall: cleanup

#-------------------------------------------------------------------------------
