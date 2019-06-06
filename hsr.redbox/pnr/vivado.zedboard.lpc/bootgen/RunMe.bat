@ECHO OFF

@WHERE xsdk >nul 2>&1
@IF %ERRORLEVEL% EQU 1 (
    echo "Xilinx SDK" not found
    GOTO :EOF
)

@SETLOCAL EnableDelayedExpansion
@SET BOOTGEN=%XILINX_SDK%/bin/bootgen
@SET PROG_FLASH=%XILINX_SDK%/bin/program_flash
@SET BOOT_FILE=BOOT.bin
@SET BIF_FILE=zed_bd.bif
@SET FSBL_FILE=fsbl_0.elf
@SET WRAPPER_FILE=zed_bd_wrapper.bit
@SET BIT_FILE=../fpga.bit

copy %BIT_FILE% %WRAPPER_FILE%

echo //arch = zynq; split = false; format = BIN >  %BIF_FILE%
echo the_ROM_image:                             >> %BIF_FILE%
echo {                                          >> %BIF_FILE%
echo 	[bootloader].%FSBL_FILE%                >> %BIF_FILE%
echo 	./%WRAPPER_FILE%                        >> %BIF_FILE%
echo }                                          >> %BIF_FILE%

%BOOTGEN% -image %BIF_FILE% -arch zynq -o %BOOT_FILE% -w on

