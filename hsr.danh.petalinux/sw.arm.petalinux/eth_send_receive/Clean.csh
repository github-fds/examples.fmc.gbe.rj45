#!/bin/csh -f

set PROG="eth_send_receive"

foreach F ( $PROG.{exe,elf,bin,hex,hexa,o,map,sym} )
    if ( -e $F ) then
       \rm -f $F
    endif
end
if ( -d obj ) then
       \rm -rf obj
endif
