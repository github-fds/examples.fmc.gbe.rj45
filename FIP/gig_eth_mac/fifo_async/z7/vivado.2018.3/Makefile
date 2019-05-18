#------------------------------------------------------------------
# VIVADO Batch Mode 
#------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
# All right reserved.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
#------------------------------------------------------------------
export VIVADO  = $(XILINX_VIVADO)/bin/vivado
export SOURCE_FIFO = vivado_ip_project_fifo.tcl	
export WORK    = work
export MACRO   = MACRO
export DEVICE  = xc7z020clg484-1
export MODULE  = 
export WIDTH   = 

#------------------------------------------------------------------
DEPTH36_ALL?=128 256 512
DEPTH17_ALL?=16 32 64

#------------------------------------------------------------------
all: all36 all17

all36:
	for D in $(DEPTH36_ALL); do\
		(export MODULE=gig_eth_fifo_async_36x$${D};\
		export WIDTH=36;\
		export DEPTH=$$D;\
		$(VIVADO) -mode batch -source $(SOURCE_FIFO));\
	done

all17:
	for D in $(DEPTH17_ALL); do\
		(export MODULE=gig_eth_fifo_async_17x$${D};\
		export WIDTH=17;\
		export DEPTH=$$D;\
		$(VIVADO) -mode batch -source $(SOURCE_FIFO));\
	done


#------------------------------------------------------------------
clean:
	-@/bin/rm -rf ./.Xil
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  ./*.html
	-@/bin/rm -f  ./*.xml
	-@/bin/rm -f  ./vivado*.jou
	-@/bin/rm -f  ./vivado*.log
	-@/bin/rm -f  ./*.backup.*
	-@/bin/rm -f  ./planAhead.*
	-@/bin/rm -f  fsm_encoding.os
	-@/bin/rm -rf ip_user_files
	-@/bin/rm -rf managed_ip_project

cleanup clobber: clean
	#for D in $(DEPTH36_ALL); do\
	#	/bin/rm -fr gig_eth_fifo_async_36x$${D}/doc;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*_clocks.xdc;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*_ooc.xdc;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*_sim_netlist.vhdl;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*_stub.vhdl;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*.veo;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*.vho;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*.xdc;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*.xml;\
	#	/bin/rm -f  gig_eth_fifo_async_36x$${D}/*.log;\
	#	/bin/rm -fr gig_eth_fifo_async_36x$${D}/misc;\
	#	/bin/rm -fr gig_eth_fifo_async_36x$${D}/hdl;\
	#	/bin/rm -fr gig_eth_fifo_async_36x$${D}/sim;\
	#	/bin/rm -fr gig_eth_fifo_async_36x$${D}/simulation;\
	#	/bin/rm -fr gig_eth_fifo_async_36x$${D}/synth;\
	#done
	#for D in $(DEPTH17_ALL); do\
	#	/bin/rm -fr gig_eth_fifo_async_17x$${D}/doc;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*_clocks.xdc;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*_ooc.xdc;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*_sim_netlist.vhdl;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*_stub.vhdl;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*.veo;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*.vho;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*.xdc;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*.xml;\
	#	/bin/rm -f  gig_eth_fifo_async_17x$${D}/*.log;\
	#	/bin/rm -fr gig_eth_fifo_async_17x$${D}/misc;\
	#	/bin/rm -fr gig_eth_fifo_async_17x$${D}/hdl;\
	#	/bin/rm -fr gig_eth_fifo_async_17x$${D}/sim;\
	#	/bin/rm -fr gig_eth_fifo_async_17x$${D}/simulation;\
	#	/bin/rm -fr gig_eth_fifo_async_17x$${D}/synth;\
	#done

cleanupall: cleanup
	for D in $(DEPTH36_ALL); do\
		/bin/rm -rf gig_eth_fifo_async_36x$${D};\
	done
	for D in $(DEPTH17_ALL); do\
		/bin/rm -rf gig_eth_fifo_async_17x$${D};\
	done
