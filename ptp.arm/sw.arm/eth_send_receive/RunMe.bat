@ECHO OFF
@REM RunMe.bat [-compile|download|debug] [-help]

@SET FIP_HOME=../../../FIP

@SET XSDK= %XILINX_SDK%/bin/xsdk
@SET XSDB= %XILINX_SDK%/bin/xsdb
@SET zWORKSPACE=workspace
@SET zINIT=%zWORKSPACE%/hw0/ps7_init.tcl
@SET ILA=0
@SET zHDF=../../hw/impl/zedboard.lpc/zed_bd_wrapper_sysdef.hdf
@SET zBIT=../../hw/impl/zedboard.lpc/zed_bd_wrapper.bit

@SET zDIR_SRC=./src
@SET zDIR_MAC=%FIP_HOME%/gig_eth_mac/api/c
@SET zDIR_HSR=%FIP_HOME%/gig_eth_hsr/api/c
@SET zPRJ=eth_send_receive
@SET zELF=%zPRJ%.elf

:LOOP
IF NOT "%1"=="" (
   IF "%1"=="-compile" (
      GOTO :COMPILE
   ) ELSE IF "%1"=="-download" (
      GOTO :DOWNLOAD
   ) ELSE IF "%1"=="-debug" (
      GOTO :DEBUG
   ) ELSE IF "%1"=="-help" (
      ECHO "%0 [-compile|download|debug] [-help]"
      GOTO :EOF
   ) ELSE (
      ECHO "%0 [-compile|download|debug] [-help]"
      GOTO :EOF
   )
   SHIFT
   GOTO :LOOP
)

:COMPILE
%XSDK% -batch -source run_xsct.tcl
GOTO :EOF

:DOWNLOAD
%XSDB% run_xsdb.tcl
GOTO :EOF

:DEBUG
%XSDB% -interactive run_xsdb.tcl
GOTO :EOF
