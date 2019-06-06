#!/bin/sh

PROG="mem_test"

if [ -f ${PROG}.exe  ]; then \rm -f  ${PROG}.exe ; fi
if [ -f ${PROG}.elf  ]; then \rm -f  ${PROG}.elf ; fi
if [ -f ${PROG}.bin  ]; then \rm -f  ${PROG}.bin ; fi
if [ -f ${PROG}.hex  ]; then \rm -f  ${PROG}.hex ; fi
if [ -f ${PROG}.hexa ]; then \rm -f  ${PROG}.hexa; fi
if [ -f ${PROG}.o    ]; then \rm -f  ${PROG}.o   ; fi
if [ -f ${PROG}.map  ]; then \rm -f  ${PROG}.map ; fi
if [ -f ${PROG}.sym  ]; then \rm -f  ${PROG}.sym ; fi
if [ -d obj          ]; then \rm -fr obj         ; fi

\rm -f *.o
