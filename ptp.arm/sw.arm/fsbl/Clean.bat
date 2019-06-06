@echo off

RMDIR  /Q/S  .Xil
RMDIR  /Q/S  project_1
RMDIR  /Q/S  hd_visual
RMDIR  /Q/S  fsbl_workspace
DEL    /Q    vivado.jou
DEL    /Q    vivado.log
DEL    /Q    vivado_*.backup.jou
DEL    /Q    vivado_*.backup.log
DEL    /Q    vivado_pid*.str
DEL    /Q    vivado_pid*.zip
