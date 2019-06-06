@echo off

RMDIR /Q/S  mac_ptp_axi.cache
RMDIR /Q/S  mac_ptp_axi.hw
RMDIR /Q/S  mac_ptp_axi.ip_user_files
RMDIR /Q/S  src
RMDIR /Q/S  xgui
DEL   /Q    mac_ptp_axi.xpr
DEL   /Q    *.backup.jou
DEL   /Q    *.backup.log
DEL   /Q    vivado.jou
DEL   /Q    vivado.log
DEL   /Q    component.xml
