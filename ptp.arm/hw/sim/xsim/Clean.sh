#!/bin/sh

if [ -f top.wdb               ]; then /bin/rm -f  top.wdb             ; fi
if [ -f wave.vcd              ]; then /bin/rm -f  wave.vcd            ; fi
if [ -f webtalk_*.backup.jou  ]; then /bin/rm -f  webtalk_*.backup.jou; fi
if [ -f webtalk_*.backup.log  ]; then /bin/rm -f  webtalk_*.backup.log; fi
if [ -f webtalk.jou           ]; then /bin/rm -f  webtalk.jou         ; fi
if [ -f webtalk.log           ]; then /bin/rm -f  webtalk.log         ; fi
if [ -f xelab.log             ]; then /bin/rm -f  xelab.log           ; fi
if [ -f xelab.pb              ]; then /bin/rm -f  xelab.pb            ; fi
if [ -f xsim_*.backup.jou     ]; then /bin/rm -f  xsim_*.backup.jou   ; fi
if [ -f xsim_*.backup.log     ]; then /bin/rm -f  xsim_*.backup.log   ; fi
if [ -f xsim.jou              ]; then /bin/rm -f  xsim.jou            ; fi
if [ -f xsim.log              ]; then /bin/rm -f  xsim.log            ; fi
if [ -f xvlog.log             ]; then /bin/rm -f  xvlog.log           ; fi
if [ -f xvlog.pb              ]; then /bin/rm -f  xvlog.pb            ; fi
if [ -d .Xil                  ]; then /bin/rm -fr .Xil                ; fi
if [ -d xsim.dir              ]; then /bin/rm -fr xsim.dir            ; fi
