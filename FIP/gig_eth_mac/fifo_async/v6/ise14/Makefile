#-------------------------------------------------------------------------------
# Copyright (c) 2018 by Ando Ki.
# All rights reserved.
#-------------------------------------------------------------------------------
SHELL	= /bin/sh
MAKEFILE= Makefile
#-------------------------------------------------------------------------------
TOPS36?= gig_eth_fifo_async_36x512\
         gig_eth_fifo_async_36x256\
         gig_eth_fifo_async_36x128
TOPS17?=gig_eth_fifo_async_17x16\
        gig_eth_fifo_async_17x32\
        gig_eth_fifo_async_17x64

all: all36 all17

all36:
	for P in $(TOPS36); do\
		if [ -f $$P.xco ]; then\
			coregen -r -p coregen.cgp -b $$P.xco;\
		fi;\
	done
all17:
	for P in $(TOPS17); do\
		if [ -f $$P.xco ]; then\
			coregen -r -p coregen.cgp -b $$P.xco;\
		fi;\
	done

clean:
	@if [ -f coregen.cgc           ]; then /bin/rm -f  coregen.cgc ; fi
	@if [ -f coregen.log           ]; then /bin/rm -f  coregen.log ; fi
	@if [ -f ngc2edif.log          ]; then /bin/rm -f  ngc2edif.log ; fi
	@if [ -d tmp                   ]; then /bin/rm -fr tmp ; fi
	@if [ -d _xmsgs                ]; then /bin/rm -fr _xmsgs ; fi
	@if [ -d xlnx_auto_0_xdb       ]; then /bin/rm -fr xlnx_auto_0_xdb; fi
	@if [ -f .lso                  ]; then /bin/rm -rf .lso; fi
	@if [ -f xil_*.in              ]; then /bin/rm -f  xil_*.in; fi
	@if [ -f xil_*.out             ]; then /bin/rm -f  xil_*.out; fi
	@if [ -f get_initp_pfile.tmp   ]; then /bin/rm -f  get_initp_pfile.tmp; fi
	@if [ -f summary.log           ]; then /bin/rm -f  summary.log; fi
	for P in $(TOPS36) $(TOPS17); do\
		if [ -d $$P                ]; then /bin/rm -fr $$P; fi;\
		if [ -f $$P.edn            ]; then /bin/rm -f  $$P.edn ; fi;\
		if [ -f $$P.gise           ]; then /bin/rm -f  $$P.gise ; fi;\
		if [ -f $$P.ise            ]; then /bin/rm -f  $$P.ise ; fi;\
		if [ -f $$P.veo            ]; then /bin/rm -f  $$P.veo ; fi;\
		if [ -f $$P.xise           ]; then /bin/rm -f  $$P.xise ; fi;\
		if [ -f $$P.xncf           ]; then /bin/rm -f  $$P.xncf ; fi;\
		if [ -f $$P.asy            ]; then /bin/rm -f  $$P.asy ; fi;\
		if [ -f $${P}_flist.txt      ]; then /bin/rm -f  $${P}_flist.txt ; fi;\
		if [ -f $${P}_readme.txt     ]; then /bin/rm -f  $${P}_readme.txt ; fi;\
		if [ -f $${P}_xmdf.tcl       ]; then /bin/rm -f  $${P}_xmdf.tcl ; fi  ;\
		if [ -d $${P}_xdb            ]; then /bin/rm -fr $${P}_xdb ; fi;\
	done

cleanup clobber: clean
	for P in $(TOPS36) $(TOPS17); do\
		/bin/rm -f  $$P.coe;\
		/bin/rm -f  $$P.mif;\
	done
	/bin/rm -fr demo_tb

cleanupall: cleanup
	for P in $(TOPS36) $(TOPS17); do\
		/bin/rm -f  $$P.ngc;\
		/bin/rm -f  $$P.v;\
	done
#-------------------------------------------------------------------------------
