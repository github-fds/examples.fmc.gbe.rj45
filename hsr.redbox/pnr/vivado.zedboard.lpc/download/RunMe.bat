@ECHO OFF
@REM RunMe.bat [-elab|sim|wave] [-help]

@WHERE vivado >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "vivado" not found
    GOTO :EOF
)

@SETLOCAL EnableDelayedExpansion
@SET SOURCE=vivado_down.tcl	
@SET BITFILE=../fpga.bit
@SET JTAG_ID=0

vivado -mode batch -source %SOURCE%

@ENDLOCAL
