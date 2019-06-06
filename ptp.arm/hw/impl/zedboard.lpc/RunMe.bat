@ECHO OFF

@WHERE vivado >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "vivado" not found
    GOTO :EOF
)

@SET SOURCE= vivado_impl.tcl
@SET PROJECT= zedboard_platform
@SET DESIGN= zed_bd
@SET BOARD_PART= em.avnet.com:zed:part0
@SET PART= xc7z020clg484-1
@SET MODULE= mac_ptp_axi
@SET DIR_USR_IP=../../gen_ip/zedboard.lpc
@SET DIR_USR_XDC=../../syn/vivado.zedboard.lpc/xdc
@SET HDF=%DESIGN%_wrapper.hdf
@SET BIT=%DESIGN%_wrapper.bit
@SET ILA=0
@SET GUI=0

vivado -mode batch -source %SOURCE%
