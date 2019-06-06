@ECHO OFF

@WHERE vivado >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "vivado" not found
    GOTO :EOF
)

@SET SOURCE=vivado_gen_ip.tcl
@SET BOARD_PART=em.avnet.com:zed:part0
@SET PART=xc7z020clg484-1
@SET MODULE=mac_ptp_axi
@SET DIR_WORK=work
@SET DIR_DESIGN=../../design/verilog
@SET DIR_EDIF=../../syn/vivado.zedboard.lpc
@SET DIR_XDC=../../syn/vivado.zedboard.lpc/xdc
@SET RIGOR=0
@SET GUI=0

vivado -mode batch -source %SOURCE%
