#!/usr/bin/tclsh

if { [file exists $::env(zBIT)] == 0 } {
      puts "ERROR \"$::env(zBIT)\" not found"
      exit
}
if { [file exists $::env(zHDF)] == 0 } {
      puts "ERROR \"$::env(zHDF)\" not found"
      exit
}
if { [file exists $::env(zINIT)] == 0 } {
      puts "ERROR \"$::env(zINIT)\" not found"
      exit
}
if { [file exists $::env(zELF)] == 0 } {
      puts "ERROR \"$::env(zELF)\" not found"
      exit
}

set env(TERM) {xterm+256color}
#set $env(TERM) {xterm+256color}
#set $::env(TERM) {xterm+256color}
puts "=========$::env(TERM)==="
# connect to target
connect -url tcp:127.0.0.1:3121
# set target core
targets 2

# reset system
rst -system

# fpga configuration
fpga -file $::env(zBIT)

# load hardware file
loadhw $::env(zHDF)
source $::env(zINIT)
ps7_init
ps7_post_config
# download elf file
dow $::env(zELF)
# continue application 
con
