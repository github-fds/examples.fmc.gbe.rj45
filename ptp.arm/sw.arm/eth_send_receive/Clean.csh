#!/bin/csh -f

set PROG="mem_test"

foreach F ( $PROG.{exe,elf,bin,hex,hexa,o,map,sym} )
    if ( -e $F ) then
       \rm -f $F
    endif
end
if ( -d obj ) then
       \rm -rf obj
endif
