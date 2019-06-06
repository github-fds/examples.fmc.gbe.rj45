@ECHO OFF

SETLOCAL EnableDelayedExpansion
SET SOURCE=vivado_ip_project_fifo_native.tcl
SET LENGTH=16 512

@FOR %%D in ( %LENGTH% ) DO @ (
     SET MODULE=gig_eth_hsr_fifo_sync_36x%%D
     SET WIDTH=36
     SET DEPTH=%%D
     vivado -mode batch -source %SOURCE%
)
ENDLOCAL
