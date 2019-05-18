    #!/usr/bin/tclsh
#
    # connect to target
    connect -url tcp:127.0.0.1:3121
    # set target core
    targets 2
    # reset system
    rst -system
    # fpga configuration
    fpga -file ../hdf/zed_bd_wrapper.bit
    # load hardware file
    loadhw ./hsr_test/hw0/system.hdf
    source ./hsr_test/hw0/ps7_init.tcl
    ps7_init
    ps7_post_config
    # download elf file
    dow ./hsr_test/hsr_test/Debug/hsr_test.elf
    # continue application 
	con
