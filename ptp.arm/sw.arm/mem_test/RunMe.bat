@ECHO OFF

@SET VIVADO=%XILINX_SDK%/bin/xsdk
@SET SOURCE=run_xsct.tcl
@SET WORKSPACE=fsbl_workspace
@SET HDF=../../hw/impl/zedboard.lpc/zed_bd_wrapper_sysdef.hdf
@SET ELF=fsbl_0.elf

%VIVADO% -batch -source %SOURCE%
