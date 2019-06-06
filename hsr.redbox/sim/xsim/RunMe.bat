@ECHO OFF
@REM RunMe.bat [-elab|sim|wave] [-help]

@WHERE vivado >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "vivado" not found
    GOTO :EOF
)
@WHERE xelab >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "xelab" not found
    GOTO :EOF
)
@WHERE xsim >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "xsim" not found
    GOTO :EOF
)

@SETLOCAL EnableDelayedExpansion
@SET VIVADO_VERSION=2018.3
@SET VIVADO=vivado.%VIVADO_VERSION%
@SET FPGA_TYPE=z7
@IF "%FIP_HOME%"=="" (
     SET FIP_HOME=../../../FIP
)

:LOOP
IF NOT "%1"=="" (
   IF "%1"=="-elab" (
      SET MACH=x86
      GOTO :ELAB
   ) ELSE IF "%1"=="-sim" (
      GOTO :SIM
   ) ELSE IF "%1"=="-wave" (
      GOTO :WAVE
   ) ELSE IF "%1"=="-help" (
      ECHO "%0 [-elab|sim|wave] [-help]"
      GOTO :EOF
   ) ELSE (
      ECHO "%0 [-elab|sim|wave] [-help]"
      GOTO :EOF
   )
   SHIFT
   GOTO :LOOP
)

:ELAB
xelab -prj xsim.prj -debug typical -L secureip -L unisims_ver -L unimacro_ver top glbl -s top
GOTO :EOF

:SIM
xsim top -t xsim_run.tcl
GOTO :EOF

:WAVE
%GTKWAVE% wave.vcd
GOTO :EOF

@ENDLOCAL
