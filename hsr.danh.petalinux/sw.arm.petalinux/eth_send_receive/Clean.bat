@ECHO OFF

SET TOP=eth_send_receive

IF EXIST %TOP%.ld	DEL /Q %TOP%.ld
IF EXIST %TOP%.elf	DEL /Q %TOP%.elf
IF EXIST %TOP%.hex	DEL /Q %TOP%.hex
IF EXIST %TOP%.hexh	DEL /Q %TOP%.hexh
IF EXIST %TOP%.hexl	DEL /Q %TOP%.hexl
IF EXIST %TOP%.hexa	DEL /Q %TOP%.hexa
IF EXIST %TOP%.bin	DEL /Q %TOP%.bin
IF EXIST %TOP%.asm	DEL /Q %TOP%.asm
IF EXIST %TOP%.map	DEL /Q %TOP%.map
IF EXIST %TOP%.cpr	DEL /Q %TOP%.cpr
IF EXIST *.cfg	DEL /Q *.cfg
IF EXIST *.gdb	DEL /Q *.gdb
IF EXIST *.o	DEL /Q *.o
IF EXIST Makefile.cam	DEL /Q Makefile.cam
IF EXIST gdb.bat	DEL /Q gdb.bat
IF EXIST gdb-server.bat	DEL /Q gdb-server.bat
IF EXIST iss.bat	DEL /Q iss.bat
IF EXIST *.log	DEL /Q *.log
IF EXIST %TOP%0.tx	DEL /Q %TOP%0.tx
IF EXIST %TOP%0.rx	DEL /Q %TOP%0.rx
IF EXIST %TOP%1.tx	DEL /Q %TOP%1.tx
IF EXIST %TOP%1.rx	DEL /Q %TOP%1.rx
IF EXIST eth0.tx	DEL /Q eth0.tx
IF EXIST eth0.rx	DEL /Q eth0.rx
IF EXIST vga	DEL /Q vga
IF EXIST fb	DEL /Q fb
IF EXIST trace.dat	DEL /Q trace.dat
IF EXIST %TOP%.sym       DEL /Q %TOP%.sym
IF EXIST obj         RMDIR /S/Q obj
