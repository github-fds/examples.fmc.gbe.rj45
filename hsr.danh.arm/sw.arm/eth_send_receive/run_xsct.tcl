#!/usr/bin/tclsh

# create workspace
setws $::env(zWORKSPACE)

if { [file exists $::env(zWORKSPACE)/hw0] == 0 } {
    # create empty project
    createhw -name hw0 -hwspec $::env(zHDF)
    createapp -name $::env(zPRJ)\
              -app {Empty Application}\
              -proc ps7_cortexa9_0\
              -hwproject hw0\
              -os standalone\
              -lang c\
              -arch 32
} else {
    # open project
    openhw hw0
}

# import source files 
importsources -name $::env(zPRJ) -path $::env(zDIR_SRC)
importsources -name $::env(zPRJ) -path $::env(zDIR_MAC)
importsources -name $::env(zPRJ) -path $::env(zDIR_HSR)

configapp -app $::env(zPRJ)
#-set compiler-misc {-c -DDANH=1}
#-set compiler-misc {-DVERBOSE=1}

# build project 
projects -build

if { [file exist $::env(zWORKSPACE)/$::env(zPRJ)/Debug/$::env(zPRJ).elf ] == 0 } {
     puts "ERROR $::env(zWORKSPACE)/$::env(zPRJ)/Debug/$::env(zPRJ).elf not found"
     exit
} else {
     file copy -force $::env(zWORKSPACE)/$::env(zPRJ)/Debug/$::env(zPRJ).elf\
                      $::env(zPRJ).elf
}

closehw hw0
exit
