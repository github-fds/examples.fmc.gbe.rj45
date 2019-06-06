@echo off

@ECHO OFF
@REM RunMe.bat [-elab|sim|wave] [-help]

@WHERE vivado >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "vivado" not found
    GOTO :EOF
)

@SETLOCAL EnableDelayedExpansion
@SET VIVADO=%XILINX_VIVADO%/bin/vivado
@SET PROJECT_DIR=project_1
@SET PROJECT_NAME=project_1
@SET SOURCE=vivado_run.tcl
@SET WORK=work
@SET DEVICE=xc7z020-clg484-1
@SET MODULE=fpga
@SET BOARD=ZED
@SET RIGOR=1
@SET ILA=1
@SET FPGA_TYPE=z7
@IF "%FIP_HOME%"=="" (
     SET FIP_HOME=../../../FIP
)

vivado -mode batch -source %SOURCE%

@ENDLOCAL
