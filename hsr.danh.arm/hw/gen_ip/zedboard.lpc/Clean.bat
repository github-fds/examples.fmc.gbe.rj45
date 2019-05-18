@echo off

RMDIR /Q/S  hsr_danh_axi.cache
RMDIR /Q/S  hsr_danh_axi.hw
RMDIR /Q/S  hsr_danh_axi.ip_user_files
RMDIR /Q/S  src
RMDIR /Q/S  xgui
DEL   /Q    hsr_danh_axi.xpr
DEL   /Q    *.backup.jou
DEL   /Q    vivado.jou
DEL   /Q    vivado.log
