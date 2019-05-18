    #!/usr/bin/tclsh
    
    # create workspace
    setws $::env(WORKSPACE)
    # create empty project
    if { [file exists $::env(WORKSPACE)/hw0] == 0 } {
puts "not exist hw0"
        createhw -name hw0 -hwspec $::env(HDF)
        createapp -name $::env(PRJ) -app {Empty Application} -proc ps7_cortexa9_0 -hwproject hw0 -os standalone
    } else {
puts "exist hw0"
        openhw hw0
    }
    # import source files 
    importsources -name $::env(PRJ) -path ./src/
    configapp -app $::env(PRJ)

    # build project 
    projects -build

    if { [file exist $::env(WORKSPACE)/$::env(PRJ)/Debug/$::env(PRJ).elf ] == 0 } {
         puts "ERROR $::env(WORKSPACE)/$::env(PRJ)/Debug/$::env(PRJ).elf not found"
    } else {
         file copy -force $::env(WORKSPACE)/$::env(PRJ)/Debug/$::env(PRJ).elf $::env(PRJ).elf
    }

    closehw hw0
    exit
