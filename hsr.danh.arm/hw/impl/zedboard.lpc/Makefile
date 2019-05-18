#-------------------------------------------------------------------------------
SHELL	=/bin/bash

#-------------------------------------------------------------------------------
export VIVADO     = $(XILINX_VIVADO)/bin/vivado
export SOURCE     = vivado_impl.tcl
export PROJECT    = zedboard_platform
export DESIGN     = zed_bd
export BOARD_PART = em.avnet.com:zed:part0
export PART       = xc7z020clg484-1
export MODULE     = hsr_danh_axi
export DIR_USR_IP = ../../gen_ip/zedboard.lpc
export DIR_USR_XDC= ../../syn/vivado.zedboard.lpc/xdc
export HDF        = $(DESIGN)_wrapper.hdf
export BIT        = $(DESIGN)_wrapper.bit
export ILA       ?= 0
ifeq ($(ILA),1)
export GUI        = 1
else
export GUI       ?= 0
endif

#-------------------------------------------------------------------------------
all:
	@if [ ! -f $(DIR_USR_IP)/$(MODULE).xpr ]; then\
		echo "ERROR \"$(DIR_USR_IP)/$(MODULE).xpr\" not found";\
		exit -1;\
	fi
	@if [ $(GUI) -eq 0 ]; then\
		$(VIVADO) -mode batch -source $(SOURCE);\
	else\
		$(VIVADO) -mode gui -source $(SOURCE);\
	fi

#-------------------------------------------------------------------------------
.PHONY: clean cleanup

clean:
	@\rm -f  vivado.jou
	@\rm -f  vivado.log
	@\rm -f  vivado_*.backup.jou
	@\rm -f  vivado_*.backup.log
	@\rm -f  vivado_pid*.str
	@\rm -f  vivado_pid*.zip
	@\rm -f  zed_bd_wrapper.mmi
	@\rm -f  post_imple_util.rpt
	@if [ -d .Xil ]; then \rm -fr .Xil; fi
	@if [ -d project_1 ]; then \rm -fr project_1; fi
	@if [ -d hd_visual ]; then \rm -fr hd_visual; fi
	/bin/rm -f ps7_init.c ps7_init_gpl.c
	/bin/rm -f ps7_init_gpl.h ps7_init.h ps7_init.html ps7_init.tcl

cleanup clobber: clean
	@\rm -f  all.xdc
	@if [ -d $(PROJECT) ]; then \rm -fr $(PROJECT); fi
	@if [ -d $(PROJECT).ila ]; then \rm -fr $(PROJECT).ila; fi

cleanupall: cleanup
	/bin/rm -f  zed_bd_wrapper.bit
	/bin/rm -f  zed_bd_wrapper.hdf
	/bin/rm -f  zed_bd_wrapper_sysdef.hdf
	/bin/rm -rf $(PROJECT).sdk
	/bin/rm -rf $(PROJECT).ila.sdk
	/bin/rm -rf ila

#-------------------------------------------------------------------------------
