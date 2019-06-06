@ECHO OFF

SETLOCAL EnableDelayedExpansion
SET SOURCE=vivado_ip_project_fifo_native.tcl
SET LENGTH36=1024 512 16
SET LENGTH17=16

@FOR %%D in ( %LENGTH36% ) DO @ (
     SET MODULE=gig_eth_hsr_fifo_async_36x%%D
     SET WIDTH=36
     SET DEPTH=%%D
     vivado -mode batch -source %SOURCE%
)
@FOR %%D in ( %LENGTH17% ) DO @ (
     SET MODULE=gig_eth_hsr_fifo_async_36x%%D
     SET WIDTH=17
     SET DEPTH=%%D
     vivado -mode batch -source %SOURCE%
)
ENDLOCAL
