@ECHO OFF

@SET ILA=0
@SET BOOTGEN=%XILINX_SDK%/bin/bootgen
@SET PROG_FLASH= %XILINX_SDK%/bin/program_flash
@SET BOOT_FILE=BOOT.bin
@SET BIF_FILE=zed_bd.bif
@SET FSBL_FILE=../sw.arm/fsbl/fsbl_0.elf
@SET WRAPPER_FILE=../hw/impl/zedboard.lpc/zed_bd_wrapper.bit
@SET ELF_FILE=../sw.arm/eth_send_receive/eth_send_receive.elf

ECHO //arch = zynq; split = false; format = BIN >  %BIF_FILE%
ECHO the_ROM_image:                             >> %BIF_FILE%
ECHO {                                          >> %BIF_FILE%
ECHO 	[bootloader]./%FSBL_FILE%               >> %BIF_FILE%
ECHO 	%WRAPPER_FILE%                          >> %BIF_FILE%
ECHO 	%ELF_FILE%                              >> %BIF_FILE%
ECHO }                                          >> %BIF_FILE%

%BOOTGEN% -image %BIF_FILE% -arch zynq -o %BOOT_FILE% -w on
