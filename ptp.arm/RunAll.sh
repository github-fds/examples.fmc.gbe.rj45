#!/bin/bash -f
#-------------------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
#-------------------------------------------------------------------------------
# RunAll.sh
#-------------------------------------------------------------------------------
# VERSION: 2018.10.23.
#-------------------------------------------------------------------------------
# func_help()  :
# func_catch() : interrupt handling
#
#-------------------------------------------------------------------------------
SHELL=/bin/bash

#-------------------------------------------------------------------------------
trap func_catch 1 2 15 # prepare to catch interrupts (EXIT, INT, TERM)

#-------------------------------------------------------------------------------
function func_catch() {
   echo "Interrupted."
   exit 1
}

#-------------------------------------------------------------------------------
# info_msg "..."
function info_msg {
  echo -e "INFO: $1"
}

#-------------------------------------------------------------------------------
function func_help() {
   echo "Usage : $0 [options]"
   echo "        -app     program :set program"
   echo "        -step    step    :specify step[s]"
   echo "                          all     - all from env to boot"
   echo "                          hw      - from edf to hdf"
   echo "                          sw      - from fsbl to elf"
   echo "                          env     - check environment"
   echo "                          edf     - prepare EDIF"
   echo "                          xpr     - prepare IP project"
   echo "                          hdf/bit - implemenatation"
   echo "                          fsbl    - prepare FSBL"
   echo "                          elf     - compile application"
   echo "                          boot    - prepare BOOT"
   echo "        -verbose         :set verbose mode"
   echo "        -h/-?            :print help"
   echo ""
   echo "Example: $ ./RunAll.sh -app sw.arm/eth_send_receive -step all 2>&1 | tee log.txt"
   echo ""
   return 0
}

#-------------------------------------------------------------------------------
export current_dir=`pwd`
export flag_verbose=0
export flag_prog=0
export program=sw.arm/eth_send_receive
export program_elf=${program}/`basename ${program}`.elf
export flag_all=0
export flag_hw=0
export flag_sw=0
export flag_env=0
export flag_edf=0
export flag_xpr=0
export flag_hdf=0
export flag_fsbl=0
export flag_elf=0
export flag_boot=0

#-------------------------------------------------------------------------------
while [ "`echo $1|cut -c1`" = "-" ]; do
   case $1 in
      -step)    shift
                if [ ! "$1" ]; then
                   echo "-ver needs option"
                   func_help
                   exit -1
                fi
                case $1 in
                all)   flag_all=1;;
                hw)    flag_hw=1;;
                sw)    flag_sw=1;;
                env)   flag_env=1;;
                edf)   flag_edf=1;;
                xpr)   flag_xpr=1;;
                hdf)   flag_hdf=1;;
                bit)   flag_hdf=1;;
                fsbl)  flag_fsbl=1;;
                elf)   flag_elf=1;;
                boot)  flag_boot=1;;
                *)     echo "ERROR unknown option: $1"
                       func_help
                       exit -1
                       ;;
                esac
                ;;
      -app)     shift
                if [ ! "$1" ]; then
                   echo "-ver needs option"
                   func_help
                   exit -1
                fi
                program=`dirname $1`/`basename $1`
                flag_prog=1;
                ;;
      -verbose) flag_verbose=1;
                ;;
      -h|-\?)   func_help
                exit -1
                ;;
      *)        echo "Unknown option: $1"
                func_help
                exit -1
                ;;
   esac
   shift
done
if [ ! -z "$1" ]; then
   echo un-known options: $1
   exit 1
fi
if [[ "${program:0:1}" == / ||
      "${program:0:2}" == ~[/a-z] ||
      "${program:0:2}" == ~[/A-Z] ]]; then
      # absolute path
      program_elf=${program}/`basename ${program}`.elf
else
      # relative path
      program_elf=${current_dir}/${program}/`basename ${program}`.elf
fi

#-------------------------------------------------------------------------------
# Environment checking
#
# Return 1 for OK
# Return 0 for failure
function func_check_env() {
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)================="; fi
   error=0
   if [[ -z "${XILINX_VIVADO}" ]]; then
       echo "ERROR \"XILINX_VIVADO\" not defined; run \"set_vivado\" first"
       echo "      or \"source /opt/Xilinx/Vivado/2018.3/settings64.sh\""
       error=1
   fi
   if [[ -z "${XILINX_SDK}" ]]; then
       echo "ERROR \"XILINX_SDK\" not defined; run \"set_sdk\" first"
       echo "      or \"source /opt/Xilinx/SDK/2018.3/settings64.sh\""
       error=1
   fi
   if [[ error -eq 0 ]]; then return 1; else return 0; fi
}

#-------------------------------------------------------------------------------
# Preparing HW EDIF: hsr_danh_axi
#
# Return 1 for OK
# Return 0 for failure
function func_edf() {
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)"; fi
   pushd hw/syn/vivado.zedboard.lpc
   make GUI=0
   retVal=$?
echo "${FUNCTIONNAME} return value $? retVal=${retVal}"
   popd
   if [[ ${retVal} -eq 0 ]]; then
echo "${FUNCTIONNAME} return 1"
      return 1
   else
echo "${FUNCTIONNAME} return 0"
      return 0
   fi
}

#-------------------------------------------------------------------------------
# Preparing HW IP: hsr_danh_axi.xpr
#
# Return 1 for OK
# Return 0 for failure
function func_ip() {
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)"; fi
   pushd hw/gen_ip/zedboard.lpc
   make GUI=0
   retVal=$?
   popd
   if [[ ${retVal} -eq 0 ]]; then
      return 1
   else
      return 0
   fi
}

#-------------------------------------------------------------------------------
# Preparing HW IMPLE: hdf and bit
#
# Return 1 for OK
# Return 0 for failure
function func_hdf() {
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)"; fi
   pushd hw/impl/zedboard.lpc
   make GUI=0
   retVal=$?
   popd
   if [[ ${retVal} -eq 0 ]]; then
      return 1
   else
      return 0
   fi
}

#-------------------------------------------------------------------------------
# Preparing FSBL: fsbl_0.elf
#
# Return 1 for OK
# Return 0 for failure
function func_fsbl() {
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)"; fi
   pushd sw.arm/fsbl
   make
   retVal=$?
   popd
   if [[ ${retVal} -eq 0 ]]; then
      return 1
   else
      return 0
   fi
}

#-------------------------------------------------------------------------------
# Preparing elf: application ELF
#
# Return 1 for OK
# Return 0 for failure
function func_elf() {
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)"; fi
   if [[ ! -d $1 ]]; then echo "ERROR \"$1\" not found"; return 0; fi
   pushd $1
   make
   retVal=$?
   popd
   if [[ ${retVal} -eq 0 ]]; then
      return 1
   else
      return 0
   fi
}

#-------------------------------------------------------------------------------
# Preparing boot: BOOT.bin
#
# Return 1 for OK
# Return 0 for failure
function func_boot() { # required ELF path-file name
   if [ ${flag_verbose} != 0 ]; then echo "${FUNCNAME} \( $@ \)"; fi
   if [[ ! -d bootgen ]]; then echo "ERROR \"bootgen\" not found"; return 0; fi
   if [[ ! -f $1 ]]; then echo "ERROR \"$1\" not found"; return 0; fi
   pushd bootgen
echo "ELF_FILE=$1"
   make ELF_FILE=$1
   retVal=$?
   popd
   if [[ ${retVal} -eq 0 ]]; then
      return 1
   else
      return 0
   fi
}

#-------------------------------------------------------------------------------
if [ ${flag_all} != 0 ]; then
   func_check_env;      if [[ $? -ne 1 ]]; then exit -1; fi
   func_edf;            if [[ $? -ne 1 ]]; then exit -1; fi
   func_ip;             if [[ $? -ne 1 ]]; then exit -1; fi
   func_hdf;            if [[ $? -ne 1 ]]; then exit -1; fi
   func_fsbl;           if [[ $? -ne 1 ]]; then exit -1; fi
   func_elf ${program}; if [[ $? -ne 1 ]]; then exit -1; fi
   func_boot ${program_elf}; if [[ $? -ne 1 ]]; then exit -1; fi
elif [ ${flag_hw} != 0 ]; then
   func_edf;            if [[ $? -ne 1 ]]; then exit -1; fi
   func_ip;             if [[ $? -ne 1 ]]; then exit -1; fi
   func_hdf;            if [[ $? -ne 1 ]]; then exit -1; fi
elif [ ${flag_sw} != 0 ]; then
   func_fsbl;           if [[ $? -ne 1 ]]; then exit -1; fi
   func_elf ${program}; if [[ $? -ne 1 ]]; then exit -1; fi
else
   if [ ${flag_env}  != 0 ]; then func_check_env;      if [[ $? -ne 1 ]]; then exit -1; fi fi
   if [ ${flag_edf}  != 0 ]; then func_edf;            if [[ $? -ne 1 ]]; then exit -1; fi fi
   if [ ${flag_xpr}  != 0 ]; then func_ip;             if [[ $? -ne 1 ]]; then exit -1; fi fi
   if [ ${flag_hdf}  != 0 ]; then func_hdf;            if [[ $? -ne 1 ]]; then exit -1; fi fi
   if [ ${flag_fsbl} != 0 ]; then func_fsbl;           if [[ $? -ne 1 ]]; then exit -1; fi fi
   if [ ${flag_elf}  != 0 ]; then func_elf ${program}; if [[ $? -ne 1 ]]; then exit -1; fi fi
   if [ ${flag_boot} != 0 ]; then func_boot ${program_elf}; if [[ $? -ne 1 ]]; then exit -1; fi fi
fi
#-------------------------------------------------------------------------------
# Revision history:
#
# 2018.08.02: 'info_msg' and 'err_msg' added.
# 2018.05.10: Started by Ando Ki (adki@future-ds.com)
#-------------------------------------------------------------------------------
