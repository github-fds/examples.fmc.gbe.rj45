SHELL=/bin/bash

ifndef PETALINUX
  $(warning "export PETALINUX=${HONE}/projects/PetaLinux")
  $(warning "source ${PETALINUX}/setting.sh")
endif

DIR_PROJECT=zed-plnx
DIR_BSP=$(PETALINUX)/bsp
FILE_BSP=$(DIR_BSP)/avnet-digilent-zedboard-v2018.3-final.bsp
DIR_HDF=../../hsr.danh.arm/hw/impl/zedboard.lpc
FILE_HDF=$(DIR_HDF)/zed_bd_wrapper_sysdef.hdf
DIR_FSBL=zed-fsbl
FILE_FSBL=$(DIR_FSBL)/fsbl_0.elf
FILE_BIT=../../hsr.danh.arm/hw/impl/zedboard.lpc/zed_bd_wrapper.bit

all: check create config build fsbl package

create:
	# create PetaLinux project
	petalinux-create --force --type project --name $(DIR_PROJECT) --source $(FILE_BSP)

config:
	@echo "Yocto Settings-->Enable Network sstage feeds: disable this"
	@echo "Image Packagin Configuraion-->Copy final images to tftpboot: disable this"
	petalinux-config --project $(DIR_PROJECT) --get-hw-description=$(DIR_HDF)
	@echo "Filesystem Packages-->misc-->gcc-runtime (libstdc++, libstdc++dev): enable"
	@echo "Filesystem Packages-->console-->network-->dropbear (dropbear): enable"
	@echo "Filesystem Packages-->console-->network-->opessh (openssh-sftp-server): enable"
	petalinux-config --project $(DIR_PROJECT) -c rootfs
	# Set HW MAC address (HWaddr) using 

build:
	echo "build linux image at \"$(DIR_PROJECT)/images/linux\""
	petalinux-build --project $(DIR_PROJECT)

emul:
	# not worked yet
	# emulation using QEMU
	# to exit QEMU, type control-A x.
	petalinux-boot --project $(DIR_PROJECT) --qemu \
		--image $(DIR_PROJECT)/images/linux/zImage

fsbl:
	# build a First Stage Boot Loader through Xilin Software Development Kit (SDK)
	# 'system.hdf' window shows the address map of the FPGA that we built.
	#
	# This will build the FSBL.
	# Click File->New->Application Project.
	# Name the project Zynq_FSBL and then click Next.
	# Then select the template Zynq FSBL and click Finish.
	make -C $(DIR_FSBL) HDF=`readlink -f $(FILE_HDF)`

package:
	# make a bootable image
	# - BOOT.bin: package the Linux image, the boot loader, and FPGA image
	# - image.ub: Linux kernel and filesystem
	# refer: (u-boot-s.bin: u-boot)
	petalinux-package --boot --force\
			--format BIN\
			--project $(DIR_PROJECT)\
			--fsbl $(FILE_FSBL)\
			--fpga $(FILE_BIT)\
			--u-boot --kernel
	@echo "Copy \"$(DIR_PROJECT)/images/linux/{BOOT.BIN,image.ub}\" to SD-Card"
	@echo "Use Jump 11/10/9/8/7 (MIO6/5/4/3/2): 01100 for SD Card boot"
	@echo "Use 115,200 baud, 8-bit 1-stop no-parity"

#boot.jtag:
#	(cd $(DIR_PROJECT);\
#	petalinux-boot --project $(DIR_PROJECT) --jtag --prebuilt 1)
##	petalinux-boot --project $(DIR_PROJECT) --jtag --prebuilt 2
##	petalinux-boot --project $(DIR_PROJECT) --jtag --prebuilt 3
#
#download.bit.jtag:
#	petalinux-boot --project $(DIR_PROJECT) --jtag --fpga --bitstream ${FILE_BIT}
#
#download.kernel.jtag:
#	petalinux-boot --project $(DIR_PROJECT) --jtag --kernel

err_flag=

check:
	$(eval ptln:="$(shell which arm-linux-gnueabihf-gcc)")
	@if [ -z ${ptln} ]; then\
		echo "PETALINUX is not defined; run \"source /home/adki/work/projects/PetaLinux/settings.sh\"";\
	fi
	$(eval sdk:="$(shell which xsdk)")
	@if [ -z ${sdk} ]; then\
	        echo "XILINX_SDK is not defined; run \"source /opt/Xilinx/SDK/2018.3/settings64.sh\"";\
	fi
	@if [ -z $(ptln) ] || [ -z $(sdk) ]; then\
		exit 1;\
	fi

	@if [ ! -f $(FILE_BSP) ]; then\
		echo "$(FILE_BSP) not found.";\
		err_flag="1";\
	fi
	@if [ ! -f $(FILE_HDF) ]; then\
		echo "$(FILE_HDF) not found.";\
		err_flag="1";\
	fi
	@if [ ! -f $(FILE_BIT) ]; then\
		echo "$(FILE_BIT) not found.";\
		err_flag="1";\
	fi
	@if [ ! -d $(DIR_FSBL) ]; then\
		echo "$(DIR_FSBL) not found.";\
		err_flag="1";\
	fi
	@if [ ! -z $(err_flag) ]; then\
		exit 1;\
	fi

#$(eval viva:="$(shell which vivado)")
#@if [ -z $(viva) ]; then\
#        echo "XILINX_VIVADO is not defined; run \"source /opt/Xilinx/Vivado/2018.3/settings64.sh\"";\
#fi

clean:
	petalinux-build --project $(DIR_PROJECT) -x clean
	/bin/rm -rf .Xil

cleanup clobber:
	/bin/rm -rf .Xil
	/bin/rm -rf ${DIR_PROJECT}

cleanupall: cleanup

