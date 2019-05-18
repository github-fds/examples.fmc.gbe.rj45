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
     set MODULE     hsr_danh_axi
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
} else {
     set BIT          $::env(BIT)
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
                   ${DIR_USR_XDC}/fpga_zed_performance.xdc
                   ${DIR_USR_XDC}/fmc-gbe-rj45-p12-hsr_lpc_zed.xdc
                   ${DIR_USR_XDC}/hsr_danh_axi.xdc"
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
    
    ### Generate IP on block design
    startgroup
    # zynq core 
    create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
    set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]
    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
    # xilinx bram 
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:${axi_bram_ctrl_version} axi_bram_ctrl_0
    # user bram 
    create_bd_cell -type ip -vlnv future-ds.com:user:${MODULE}:1.0 ${MODULE}_0
    # smart connector
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
    set_property -dict [list CONFIG.NUM_SI {1}] [get_bd_cells smartconnect_0]
    set_property -dict [list CONFIG.NUM_MI {2}] [get_bd_cells smartconnect_0]
    set_property -dict [list CONFIG.NUM_CLKS {2}] [get_bd_cells smartconnect_0]
    endgroup
    
    ### Create External Port 
    create_bd_port -dir I               BOARD_RST_SW
    create_bd_port -dir I               BOARD_CLK_IN
    create_bd_port -dir I -from 7 -to 0 BOARD_SLIDE_SW
    create_bd_port -dir O -from 7 -to 0 BOARD_LED
    create_bd_port -dir O               GBE_MDC
    create_bd_port -dir IO              GBE_MDIO
    create_bd_port -dir O               GBEA_PHY_RESET_N
    create_bd_port -dir O               GBEA_GTXC
    create_bd_port -dir O -from 7 -to 0 GBEA_TXD
    create_bd_port -dir O               GBEA_TXEN
    create_bd_port -dir O               GBEA_TXER
    create_bd_port -dir I               GBEA_RXC
    create_bd_port -dir I -from 7 -to 0 GBEA_RXD
    create_bd_port -dir I               GBEA_RXDV
    create_bd_port -dir I               GBEA_RXER
    create_bd_port -dir O               GBEB_PHY_RESET_N
    create_bd_port -dir O               GBEB_GTXC
    create_bd_port -dir O -from 7 -to 0 GBEB_TXD
    create_bd_port -dir O               GBEB_TXEN
    create_bd_port -dir O               GBEB_TXER
    create_bd_port -dir I               GBEB_RXC
    create_bd_port -dir I -from 7 -to 0 GBEB_RXD
    create_bd_port -dir I               GBEB_RXDV
    create_bd_port -dir I               GBEB_RXER
    create_bd_port -dir O               host_probe_txen
    create_bd_port -dir O               host_probe_rxdv
    create_bd_port -dir O               netA_probe_txen
    create_bd_port -dir O               netA_probe_rxdv
    create_bd_port -dir O               netB_probe_txen
    create_bd_port -dir O               netB_probe_rxdv

    ### Auto Connection 
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7\
                        -config {make_external "FIXED_IO, DDR"\
                                 apply_board_preset "1"\
                                 Master "Disable"\
                                 Slave "Disable"\
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

    # external 
    connect_bd_net [get_bd_ports BOARD_RST_SW] [get_bd_pins ${MODULE}_0/BOARD_RST_SW]
    connect_bd_net [get_bd_ports BOARD_CLK_IN] [get_bd_pins ${MODULE}_0/BOARD_CLK_IN]
    connect_bd_net [get_bd_ports BOARD_SLIDE_SW] [get_bd_pins ${MODULE}_0/BOARD_SLIDE_SW]
    connect_bd_net [get_bd_ports BOARD_LED] [get_bd_pins ${MODULE}_0/BOARD_LED]
    connect_bd_net [get_bd_ports GBE_MDC] [get_bd_pins ${MODULE}_0/GBE_MDC]
    connect_bd_net [get_bd_ports GBE_MDIO] [get_bd_pins ${MODULE}_0/GBE_MDIO]
    connect_bd_net [get_bd_ports GBEA_PHY_RESET_N] [get_bd_pins ${MODULE}_0/GBEA_PHY_RESET_N]
    connect_bd_net [get_bd_ports GBEA_GTXC] [get_bd_pins ${MODULE}_0/GBEA_GTXC]
    connect_bd_net [get_bd_ports GBEA_TXD] [get_bd_pins ${MODULE}_0/GBEA_TXD]
    connect_bd_net [get_bd_ports GBEA_TXEN] [get_bd_pins ${MODULE}_0/GBEA_TXEN]
    connect_bd_net [get_bd_ports GBEA_TXER] [get_bd_pins ${MODULE}_0/GBEA_TXER]
    connect_bd_net [get_bd_ports GBEA_RXC] [get_bd_pins ${MODULE}_0/GBEA_RXC]
    connect_bd_net [get_bd_ports GBEA_RXD] [get_bd_pins ${MODULE}_0/GBEA_RXD]
    connect_bd_net [get_bd_ports GBEA_RXDV] [get_bd_pins ${MODULE}_0/GBEA_RXDV]
    connect_bd_net [get_bd_ports GBEA_RXER] [get_bd_pins ${MODULE}_0/GBEA_RXER]
    connect_bd_net [get_bd_ports GBEB_PHY_RESET_N] [get_bd_pins ${MODULE}_0/GBEB_PHY_RESET_N]
    connect_bd_net [get_bd_ports GBEB_GTXC] [get_bd_pins ${MODULE}_0/GBEB_GTXC]
    connect_bd_net [get_bd_ports GBEB_TXD] [get_bd_pins ${MODULE}_0/GBEB_TXD]
    connect_bd_net [get_bd_ports GBEB_TXEN] [get_bd_pins ${MODULE}_0/GBEB_TXEN]
    connect_bd_net [get_bd_ports GBEB_TXER] [get_bd_pins ${MODULE}_0/GBEB_TXER]
    connect_bd_net [get_bd_ports GBEB_RXC] [get_bd_pins ${MODULE}_0/GBEB_RXC]
    connect_bd_net [get_bd_ports GBEB_RXD] [get_bd_pins ${MODULE}_0/GBEB_RXD]
    connect_bd_net [get_bd_ports GBEB_RXDV] [get_bd_pins ${MODULE}_0/GBEB_RXDV]
    connect_bd_net [get_bd_ports GBEB_RXER] [get_bd_pins ${MODULE}_0/GBEB_RXER]

    connect_bd_net [get_bd_ports host_probe_txen] [get_bd_pins ${MODULE}_0/host_probe_txen]
    connect_bd_net [get_bd_ports host_probe_rxdv] [get_bd_pins ${MODULE}_0/host_probe_rxdv]
    connect_bd_net [get_bd_ports netA_probe_txen] [get_bd_pins ${MODULE}_0/netA_probe_txen]
    connect_bd_net [get_bd_ports netA_probe_rxdv] [get_bd_pins ${MODULE}_0/netA_probe_rxdv]
    connect_bd_net [get_bd_ports netB_probe_txen] [get_bd_pins ${MODULE}_0/netB_probe_txen]
    connect_bd_net [get_bd_ports netB_probe_rxdv] [get_bd_pins ${MODULE}_0/netB_probe_rxdv]

    ### Address Setting 
    # hsr_danh_axi 
    assign_bd_address [get_bd_addr_segs {hsr_danh_axi_0/s_axi/reg0 }]
    set_property offset 0x40000000 [get_bd_addr_segs {processing_system7_0/Data/SEG_hsr_danh_axi_0_reg0}]
    set_property range 256M [get_bd_addr_segs {processing_system7_0/Data/SEG_hsr_danh_axi_0_reg0}]
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
