@ECHO OFF

@WHERE vivado >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "vivado" not found
    GOTO :EOF
)

@IF "%FIP_HOME%"=="" (
     SET FIP_HOME=../../../../FIP
)

@SET VIVADO_VERSION=2018.3
@SET FPGA_TYPE=z7
@SET FPGA_FAMILY="ZYNQ7000"
@SET VIVADO_VER=vivado.%VIVADO_VERSION%

@SET VIVADO=%XILINX_VIVADO%/bin/vivado
@SET PROJECT_DIR=project_1
@SET PROJECT_NAME=project_1
@SET BOARD_PART=em.avnet.com:zed:part0
@SET PART=xc7z020-clg484-1
@SET SOURCE=vivado_syn.tcl
@SET MODULE=mac_ptp_axi
@SET DIR_WORK=work
@SET DIR_FIP=%FIP_HOME%
@SET DIR_XDC=xdc
@SET BOARD=ZED
@SET RIGOR=0
@SET GUI=0

vivado -mode batch -source %SOURCE%
