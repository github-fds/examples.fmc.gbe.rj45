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
if {[info exists env(LTX)]==0} {
     set LTX          ${DESIGN}_wrapper.ltx
} else {
     set LTX          $::env(LTX)
}
#===============================================================================
if {([info exists env(ILA)]==0)||
    (([info exists env(ILA)]==1)&&($::env(ILA)==0))} {
  set projName ${PROJECT}
} else {
  set projName ${PROJECT}.ila
}
set projPart ${PART}
    
if { 1 } {
    ### prepare a directory for software
    file mkdir ./${projName}.sdk
    set  DIR_SDK ./${projName}.sdk
    if {([info exists env(ILA)]==0)||
        (([info exists env(ILA)]==1)&&($::env(ILA)==0))} {
        set DIR_BIT .
    } else {
        file mkdir  ./ila
        set DIR_BIT ./ila
    }
    
    ### implementation and Bit file generation 
    if { [file exists ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.dcp] == 0 } {
         launch_runs impl_1
         wait_on_run impl_1
    }
    if { [file exists ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.bit] == 0 } {
         launch_runs impl_1 -to_step write_bitstream
         wait_on_run impl_1
         # get utilization report
         open_run impl_1
         report_utilization -file ./post_imple_util.rpt
    }
    if { [file exists ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.bit] == 0 } {
         puts "ERROR ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.bit not found"
    } else {
         file copy -force ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.bit\
                          ${DIR_BIT}/${BIT}
    }
    if {([info exists env(ILA)]==1)&&($::env(ILA)==1)} {
         if { [file exists ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.ltx] == 0 } {
              puts "ERROR ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.ltx not found"
         } else {
              file copy -force ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.ltx\
                               ${DIR_BIT}/${LTX}
         }
    }
   #write_edif -force ${EDIF_FILE}
    
    ### copy hardware design files to sw directory  
    file copy -force ./${projName}/${projName}.srcs/sources_1/bd/${DESIGN}/${DESIGN}.bd\
                     ${DIR_SDK}/${DESIGN}.bd
    file copy -force ./${projName}/${projName}.srcs/sources_1/bd/${DESIGN}/${DESIGN}_ooc.xdc\
                     ${DIR_SDK}/${DESIGN}_ooc.xdc
    file copy -force ./${projName}/${projName}.srcs/sources_1/bd/${DESIGN}/hdl/${DESIGN}_wrapper.v\
                     ${DIR_SDK}/${DESIGN}_wrapper.v
    write_hwdef -force -file ${DIR_SDK}/${HDF}
    if { [file exists ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.sysdef] == 0 } {
         puts "ERROR ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.sysdef not found"
    } else {
         file copy -force ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.sysdef\
                          ${DIR_SDK}/${SYSDEF}
         file copy -force ./${projName}/${projName}.runs/impl_1/${DESIGN}_wrapper.sysdef\
                          ${DIR_BIT}/${SYSDEF}
    }
    write_xdc -force -file ${DIR_BIT}/all_ila.xdc
}
