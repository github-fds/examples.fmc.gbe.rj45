#!/bin/csh

if ( -d work                 ) \rm -rf work
if ( -f transcript           ) \rm -f transcript
if ( -f wave.vcd             ) \rm -f wave.vcd
if ( -f compile.log          ) \rm -f compile.log
if ( -f vsim.wlf             ) \rm -f vsim.wlf
if ( -f vish_stacktrace.vstf ) \rm -f vish_stacktrace.vstf
if ( -f ethernet_log.txt     ) \rm -f ethernet_log.txt
if ( -f fds.v                ) \rm -f fds.v
if ( -f mm.v                 ) \rm -f mm.v
if ( -f m.v                  ) \rm -f m.v
if ( -f xx.v                 ) \rm -f xx.v
if ( -f x.v                  ) \rm -f x.v

/bin/rm -f wlft*
