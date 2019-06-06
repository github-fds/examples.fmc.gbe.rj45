#!/usr/bin/tclsh

if { [file exists $::env(zDIR_SRC)/platform.h] == 0 } {
    setws $::env(zWORKSPACE)_tmp
    createhw -name hw0 -hwspec $::env(zHDF)
    createapp -name $::env(zPRJ)\
              -app {Hello World}\
              -proc ps7_cortexa9_0\
              -hwproject hw0\
              -os standalone\
              -lang c\
              -arch 32
    file copy -force $::env(zWORKSPACE)_tmp/$::env(zPRJ)/src/platform_config.h $::env(zDIR_SRC)/platform_config.h
    file copy -force $::env(zWORKSPACE)_tmp/$::env(zPRJ)/src/platform.h $::env(zDIR_SRC)/platform.h
    file copy -force $::env(zWORKSPACE)_tmp/$::env(zPRJ)/src/platform.c $::env(zDIR_SRC)/platform.c

   #file delete -force -- $::env(zWORKSPACE)_tmp
}

setws -switch $::env(zWORKSPACE)
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
importsources -name $::env(zPRJ) -path $::env(zDIR_PTP)
importsources -name $::env(zPRJ) -path $::env(zDIR_GPIO)

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
