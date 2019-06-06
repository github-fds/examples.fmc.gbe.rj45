#!/usr/bin/tclsh

# create workspace
    setws $::env(WORKSPACE)
# create project
    if { [file isdirectory $::env(WORKSPACE)/hw0 ] == 0 } {
puts "found $::env(WORKSPACE)/hw0"
       createhw -name hw0 -hwspec $::env(HDF)
       createapp -name fsbl_0\
                 -app {Zynq FSBL}\
                 -proc ps7_cortexa9_0\
                 -hwproject hw0\
                 -os standalone
    } else {
puts "not found $::env(WORKSPACE)/hw0"
       openhw hw0
    }
    configapp -app fsbl_0 

# build project 
    projects -build

#
    if { [file exists $::env(WORKSPACE)/fsbl_0/Debug/$::env(ELF)] == 0 } {
          puts "ERROR $::env(WORKSPACE)/fsbl_0/Debug/$::env(ELF) not found"
    } else {
          file copy -force $::env(WORKSPACE)/fsbl_0/Debug/$::env(ELF)\
                     $::env(ELF)
    }
    
    exit
