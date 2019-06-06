#===============================================================================
if {[info exists env(PROJECT)]==0} {
     set PROJECT    zedboard_platform
} else {
     set PROJECT    $::env(PROJECT)
}
if {[info exists env(BOARD_PART)]==0} {
     set BOARD_PART em.avnet.com:zed:part0
} else {
     set BOARD_PART $::env(BOARD_PART)
}
if {[info exists env(PART)]==0} {
     set PART     xc7z020clg484-1
} else {
     set PART     $::env(PART)
}
if {[info exists env(MODULE)]==0} {
     set MODULE     mac_ptp_axi
} else {
     set MODULE     $::env(MODULE)
}
if {[info exists env(DIR_USR_IP)]==0} {
     set DIR_USR_IP     ../../gen_ip/zedboard.lpc
} else {
     set DIR_USR_IP     $::env(DIR_USR_IP)
}
if {[info exists env(DIR_USR_XDC)]==0} {
     set DIR_USR_XDC    ../../syn/vivado.zedboard.lpc/xdc
} else {
     set DIR_USR_XDC    $::env(DIR_USR_XDC)
}
if {[info exists env(DESIGN)]==0} {
     set DESIGN zed_bd
} else {
     set DESIGN $::env(DESIGN)
}
if {[info exists env(HDF)]==0} {
     set HDF          ${DESIGN}_wrapper.hdf
} else {
     set HDF          $::env(HDF)
}
if {[info exists env(SYSDEF)]==0} {
     set SYSDEF          ${DESIGN}_wrapper_sysdef.hdf
} else {
     set SYSDEF          $::env(SYSDEF)
}
if {[info exists env(BIT)]==0} {
     set BIT          ${DESIGN}_wrapper.bit
     set EDIF         ${DESIGN}_wrapper.edif
} else {
     set BIT          $::env(BIT)
     set xxyy         [file rootname $::env(BIT) ]
     set EDIF         ${xxyy}.edif
}
#=====================================================================
proc number_of_processor {} {
    global tcl_platform env
    switch ${tcl_platform(platform)} {
        "windows" {
            return $env(NUMBER_OF_PROCESSORS)
        }

        "unix" {
            if {![catch {open "/proc/cpuinfo"} f]} {
                set cores [regexp -all -line {^processor\s} [read $f]]
                close $f
                if {$cores > 0} {
                    return $cores
                }
            }
        }

        "Darwin" {
            if {![catch {exec {*}$sysctl -n "hw.ncpu"} cores]} {
                return $cores
            }
        }

        default {
            puts "Unknown System"
            return 1
        }
    }
}
set_param general.maxThreads [number_of_processor]
set NPROC [number_of_processor]
#===============================================================================

    ### Get current directory, used throughout script
    set launchDir [file dirname [file normalize [info script]]]
    set sourcesDir ${launchDir}/sources
    
    ### Create the project using the board local repo
    if {([info exists env(ILA)]==0)||
        (([info exists env(ILA)]==1)&&($::env(ILA)==0))} {
      set projName ${PROJECT}
    } else {
      set projName ${PROJECT}.ila
    }
    set projPart ${PART}
    
    create_project $projName ./$projName -part $projPart -force

set VIVADO_VERSION [version -short]
if {${VIVADO_VERSION}=="2017.4"} {
    set board_part_version ${BOARD_PART}:1.3
    set axi_bram_ctrl_version 4.0
} elseif {${VIVADO_VERSION}=="2018.2"} {
    set board_part_version ${BOARD_PART}:1.4
    set axi_bram_ctrl_version 4.0
} elseif {${VIVADO_VERSION}=="2018.3"} {
    set board_part_version ${BOARD_PART}:1.4
    set axi_bram_ctrl_version 4.1
} else {
    puts "${VIVADO_VERSION} not considerred"
    set board_part_version ${BOARD_PART}:1.0
}
set_property board_part ${board_part_version} [current_project]
#set_property vendor_display_name {Future Design Systems} [current_project]
#set_property company_url www.future-ds.com [current_project]

    ### User IP dir
    set_property  ip_repo_paths  " ${DIR_USR_IP} " [current_project]
    update_ip_catalog

    ### Add xdc file
    set XDC_LIST " ${DIR_USR_XDC}/fpga_zed.xdc
                   ${DIR_USR_XDC}/fmc-gbe-rj45-p0_lpc_zed.xdc
                   ${DIR_USR_XDC}/mac_ptp_axi.xdc
                   ${DIR_USR_XDC}/fpga_zed_ptp.xdc
                 "
    add_files -fileset constrs_1 -norecurse ${XDC_LIST}
    import_files -fileset constrs_1 -norecurse ${XDC_LIST}

    set fpout [ open "all.xdc" "w" ]
    foreach F ${XDC_LIST} {
            set fpin  [ open "$F" "r" ]
            set fdata [ read $fpin ]
            puts -nonewline $fpout $fdata
            close $fpin
    }
    close $fpout

    ### Create block design
    create_bd_design ${DESIGN}
    
    startgroup
    ### Generate IP on block design
    # zynq core 
    create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7\
                        -config {make_external "FIXED_IO, DDR"\
                                 apply_board_preset "1"\
                                 Master "Disable"\
                                 Slave "Disable"\
                                }  [get_bd_cells processing_system7_0]
    set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}\
                             CONFIG.PCW_USE_S_AXI_HP0 {0}\
                             CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0}\
                             CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0}\
                             CONFIG.PCW_USE_FABRIC_INTERRUPT {1}\
                             CONFIG.PCW_IRQ_F2P_INTR {1}\
                       ] [get_bd_cells processing_system7_0]
    # reset
    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
    # concat
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
    set_property -dict [list CONFIG.NUM_PORTS {10}] [get_bd_cells xlconcat_0]
    # slice
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1
    set_property -dict [list CONFIG.DIN_WIDTH {4} CONFIG.DOUT_WIDTH {4} CONFIG.DIN_TO {0} CONFIG.DIN_FROM {0}] [get_bd_cells xlslice_1]
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2
    set_property -dict [list CONFIG.DIN_WIDTH {4} CONFIG.DOUT_WIDTH {4} CONFIG.DIN_TO {1} CONFIG.DIN_FROM {1}] [get_bd_cells xlslice_2]
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_3
    set_property -dict [list CONFIG.DIN_WIDTH {4} CONFIG.DOUT_WIDTH {4} CONFIG.DIN_TO {2} CONFIG.DIN_FROM {2}] [get_bd_cells xlslice_3]
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_4
    set_property -dict [list CONFIG.DIN_WIDTH {4} CONFIG.DOUT_WIDTH {4} CONFIG.DIN_TO {3} CONFIG.DIN_FROM {3}] [get_bd_cells xlslice_4]
    # xilinx bram 
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:${axi_bram_ctrl_version} axi_bram_ctrl_0
    # user bram 
    create_bd_cell -type ip -vlnv future-ds.com:user:${MODULE}:1.0 ${MODULE}_0
    # smart connector
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
    set_property -dict [list CONFIG.NUM_SI {1}\
                             CONFIG.NUM_MI {2}\
                             CONFIG.NUM_CLKS {2}] [get_bd_cells smartconnect_0]
    endgroup
    
    ### Create External Port 
    create_bd_port -dir I               BOARD_RST_SW
    create_bd_port -dir I               BOARD_CLK_IN
    create_bd_port -dir I -from 7 -to 0 BOARD_SLIDE_SW
    create_bd_port -dir O -from 7 -to 0 BOARD_LED
    create_bd_port -dir I               BOARD_BTND
    create_bd_port -dir I               BOARD_BTNU
    create_bd_port -dir O               GBE_MDC
    create_bd_port -dir IO              GBE_MDIO
    create_bd_port -dir O               GBEU_PHY_RESET_N
    create_bd_port -dir O               GBEU_GTXC
    create_bd_port -dir O -from 7 -to 0 GBEU_TXD
    create_bd_port -dir O               GBEU_TXEN
    create_bd_port -dir O               GBEU_TXER
    create_bd_port -dir I               GBEU_RXC
    create_bd_port -dir I -from 7 -to 0 GBEU_RXD
    create_bd_port -dir I               GBEU_RXDV
    create_bd_port -dir I               GBEU_RXER
    create_bd_port -dir O               PTP_PPS
    create_bd_port -dir O               PTP_PPUS

    ### Auto Connection 
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7\
                        -config {make_external "FIXED_IO, DDR"\
                                }  [get_bd_cells processing_system7_0]
    apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr\
                        -config {BRAM "Auto"}\
                         [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
    apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr\
                        -config {BRAM "Auto"}\
                         [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB]

    ### Connection
    # clock 
    connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0]\
                   [get_bd_pins smartconnect_0/aclk]
    connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]\
                   [get_bd_pins processing_system7_0/FCLK_CLK0]
    connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk]\
                   [get_bd_pins processing_system7_0/FCLK_CLK0]
    connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]\
                   [get_bd_pins processing_system7_0/FCLK_CLK0]
    connect_bd_net [get_bd_pins ${MODULE}_0/s_axi_aclk]\
                   [get_bd_pins smartconnect_0/aclk1]
    # reset 
    connect_bd_net [get_bd_pins proc_sys_reset_0/aux_reset_in]\
                   [get_bd_pins ${MODULE}_0/s_axi_aresetn]
    connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N]\
                   [get_bd_pins proc_sys_reset_0/ext_reset_in]
    connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn]\
                   [get_bd_pins smartconnect_0/aresetn]
    connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]\
                   [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

    # interface 
    connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0]\
                        [get_bd_intf_pins smartconnect_0/S00_AXI]
    connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI]\
                        [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI]\
                        [get_bd_intf_pins ${MODULE}_0/s_axi]

    # interrupt
    connect_bd_net [get_bd_pins xlconcat_0/dout       ] [get_bd_pins processing_system7_0/IRQ_F2P]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_GMAC] [get_bd_pins xlconcat_0/In0]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_PTP ] [get_bd_pins xlconcat_0/In1]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_RTC ] [get_bd_pins xlconcat_0/In2]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_SWU ] [get_bd_pins xlconcat_0/In3]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_SWD ] [get_bd_pins xlconcat_0/In4]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_GPIO] [get_bd_pins xlconcat_0/In5]

    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_TIMER] [get_bd_pins xlslice_1/Din]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_TIMER] [get_bd_pins xlslice_2/Din]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_TIMER] [get_bd_pins xlslice_3/Din]
    connect_bd_net [get_bd_pins mac_ptp_axi_0/IRQ_TIMER] [get_bd_pins xlslice_4/Din]

    connect_bd_net [get_bd_pins xlslice_1/Dout] [get_bd_pins xlconcat_0/In6]
    connect_bd_net [get_bd_pins xlslice_2/Dout] [get_bd_pins xlconcat_0/In7]
    connect_bd_net [get_bd_pins xlslice_3/Dout] [get_bd_pins xlconcat_0/In8]
    connect_bd_net [get_bd_pins xlslice_4/Dout] [get_bd_pins xlconcat_0/In9]

    # external 
    connect_bd_net [get_bd_ports BOARD_RST_SW    ] [get_bd_pins ${MODULE}_0/BOARD_RST_SW]
    connect_bd_net [get_bd_ports BOARD_CLK_IN    ] [get_bd_pins ${MODULE}_0/BOARD_CLK_IN]
    connect_bd_net [get_bd_ports BOARD_SLIDE_SW  ] [get_bd_pins ${MODULE}_0/BOARD_SLIDE_SW]
    connect_bd_net [get_bd_ports BOARD_LED       ] [get_bd_pins ${MODULE}_0/BOARD_LED]
    connect_bd_net [get_bd_ports BOARD_BTND      ] [get_bd_pins ${MODULE}_0/BOARD_BTND]
    connect_bd_net [get_bd_ports BOARD_BTNU      ] [get_bd_pins ${MODULE}_0/BOARD_BTNU]
    connect_bd_net [get_bd_ports GBE_MDC         ] [get_bd_pins ${MODULE}_0/GBE_MDC]
    connect_bd_net [get_bd_ports GBE_MDIO        ] [get_bd_pins ${MODULE}_0/GBE_MDIO]
    connect_bd_net [get_bd_ports GBEU_PHY_RESET_N] [get_bd_pins ${MODULE}_0/GBEU_PHY_RESET_N]
    connect_bd_net [get_bd_ports GBEU_GTXC       ] [get_bd_pins ${MODULE}_0/GBEU_GTXC]
    connect_bd_net [get_bd_ports GBEU_TXD        ] [get_bd_pins ${MODULE}_0/GBEU_TXD]
    connect_bd_net [get_bd_ports GBEU_TXEN       ] [get_bd_pins ${MODULE}_0/GBEU_TXEN]
    connect_bd_net [get_bd_ports GBEU_TXER       ] [get_bd_pins ${MODULE}_0/GBEU_TXER]
    connect_bd_net [get_bd_ports GBEU_RXC        ] [get_bd_pins ${MODULE}_0/GBEU_RXC]
    connect_bd_net [get_bd_ports GBEU_RXD        ] [get_bd_pins ${MODULE}_0/GBEU_RXD]
    connect_bd_net [get_bd_ports GBEU_RXDV       ] [get_bd_pins ${MODULE}_0/GBEU_RXDV]
    connect_bd_net [get_bd_ports GBEU_RXER       ] [get_bd_pins ${MODULE}_0/GBEU_RXER]

    connect_bd_net [get_bd_ports PTP_PPS ] [get_bd_pins ${MODULE}_0/PTP_PPS ]
    connect_bd_net [get_bd_ports PTP_PPUS] [get_bd_pins ${MODULE}_0/PTP_PPUS]

    ### Address Setting 
    # mac_ptp_axi 
    assign_bd_address [get_bd_addr_segs {mac_ptp_axi_0/s_axi/reg0 }]
    set_property offset 0x40000000 [get_bd_addr_segs {processing_system7_0/Data/SEG_mac_ptp_axi_0_reg0}]
    set_property range 256M [get_bd_addr_segs {processing_system7_0/Data/SEG_mac_ptp_axi_0_reg0}]
    # bram 0
    assign_bd_address [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]
    set_property offset 0x60000000 [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_bram_ctrl_0_Mem0}]
    set_property range 16K [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_bram_ctrl_0_Mem0}]

    ### save block design 
    regenerate_bd_layout
    validate_bd_design
    save_bd_design
    
    ### Create top wrapper  
    make_wrapper -top -files [get_files ./$projName/$projName.srcs/sources_1/bd/${DESIGN}/${DESIGN}.bd]
    add_files -norecurse ./$projName/$projName.srcs/sources_1/bd/${DESIGN}/hdl/${DESIGN}_wrapper.v
    
    ### Synthesis   
    launch_runs synth_1 -jobs ${NPROC}
    wait_on_run synth_1
    # open_run synth_1 -name synth_1

if {([info exists env(ILA)]==0)||
    (([info exists env(ILA)]==1)&&($::env(ILA)==0))} {
    ### implementation and Bit file generation 
    launch_runs impl_1 -to_step write_bitstream -jobs ${NPROC}
    wait_on_run impl_1
    # get utilization report
    open_run impl_1
    report_utilization -file ./post_imple_util.rpt

    ### prepare for software
    file mkdir ./$projName.sdk
    set DIR_SDK ./$projName.sdk

    ### copy hardware design files to sw directory  
    file copy -force ./$projName/$projName.srcs/sources_1/bd/${DESIGN}/${DESIGN}.bd\
                     ${DIR_SDK}/${DESIGN}.bd
    file copy -force ./$projName/$projName.srcs/sources_1/bd/${DESIGN}/${DESIGN}_ooc.xdc\
                     ${DIR_SDK}/${DESIGN}_ooc.xdc
    file copy -force ./$projName/$projName.srcs/sources_1/bd/${DESIGN}/hdl/${DESIGN}_wrapper.v\
                     ${DIR_SDK}/${DESIGN}_wrapper.v
    write_hwdef -force -file ${DIR_SDK}/${HDF}

    if { [file exists ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.sysdef] == 0 } {
         puts "ERROR ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.sysdef not found"
    } else {
         # it is HDF with bit-stream
         file copy -force ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.sysdef\
                          ${DIR_SDK}/${SYSDEF}
         file copy -force ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.sysdef\
                          ${SYSDEF}
    }
    if { [file exists ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.bit] == 0 } {
         puts "ERROR ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.bit not found"
    } else {
         file copy -force ./$projName/$projName.runs/impl_1/${DESIGN}_wrapper.bit\
                          ${BIT}
         write_edif -force ${EDIF}
    }
} else {
   #update_compile_order -fileset sources_1
   #open_run synth_1 -name synth_1
   #create_debug_core u_ila_0 ila
   #save_constraints -force
   #launch_runs impl_1 -jobs ${NPROC}
   #launch_runs impl_1 -to_step write_bitstream -jobs ${NPROC}
   #lose_design
   #open_run impl_1
}
