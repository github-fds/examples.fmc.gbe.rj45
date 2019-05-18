SHELL=/bin/sh
ARCH=$(shell uname)

ifndef PETALINUX
       #DIR_PentaLinux=/home/adki/work/projects/PetaLinux
       $(info run "source /home/adki/work/projects/PetaLinux/settings.sh")
       $(error PETALINUX is not defined)
endif
ifndef DIR_FIP
       DIR_FIP=../../../../FIP
endif
ifndef IP_ADDR
       IP_ADDR=192.168.1.214
endif

TARGET=eth_send_receive

DEFINES=
CFLAGS=-std=gnu99 -g
LDFLAGS=

CC       =$(PETALINUX)/tools/linux-i386/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-gcc
DEFINES +=
CFLAGS  +=
LDFLAGS +=

ifndef OBJECTDIR
  OBJECTDIR = obj
endif
ifeq (${wildcard $(OBJECTDIR)},)
  DUMMY:= $(shell mkdir $(OBJECTDIR))
else
  DUMMY:= $(shell rm -rf $(OBJECTDIR))
  DUMMY:= $(shell mkdir $(OBJECTDIR))
endif

#DEFINES+=-DRIGOR -DVERBOSE -DPKT_PARSER
DEFINES+=-DRIGOR
CFLAGS+=-Isrc

SRC     =main.c\
         eth_ip_udp_pkt.c\
         gpio_api.c\
         linenoise.c\
         mac_api.c\
         main.c\
         map_mem.c\
         mem_api.c\
         monitor_cmd_etc.c\
         monitor_cmd_mac.c\
         monitor_cmd_memory.c\
         monitor_command.c\
         non_block_getchar.c\
         strtoi.c\
         gig_eth_hsr_api.c\
         gig_eth_mac_api.c

OBJS    = $(SRC:.c=.o)

H_DIR           = src
C_DIR           = src

vpath %.h       $(H_DIR)
vpath %.c       $(C_DIR)

$(OBJECTDIR)/%.o: %.c
	$(CC) -c $(DEFINES) $(CFLAGS) -o $@ $<

all: pre $(TARGET)

$(TARGET): $(addprefix $(OBJECTDIR)/,$(OBJS))
	$(CC) -o $(TARGET) $^ $(LDFLAGS)

pre:
	if [ -f compile.log ]; then /bin/rm -f compile.log; fi

download:
	scp $(TARGET) root@$(IP_ADDR):/home/root
	#ssh-keygen -f "/home/adki/.ssh/known_hosts" -R 192.168.1.214

TTY ?= /dev/ttyACM0

open.tty tty:
	#dmesg | grep -i tty' or '$ sudo setserial -g /dev/ttyACM[0123456789]'
	#use ~. to terminate cu
	cu --line $(TTY) --speed 115200

clean:
	/bin/rm -fr obj

cleanup: clean
	/bin/rm -f  $(TARGET)
	/bin/rm -f  $(TARGET).exe

cleanupall: cleanup

# $ make DEFINES=-DDEBUG=1
