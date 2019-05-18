#---------------------------------------------------------
if {[info exists env(VIVADO_VER)] == 0} {
     set VIVADO_VER vivado.[version -short]
} else {
     set VIVADO_VER $::env(VIVADO_VER)
}
if {[info exists env(PART)] == 0} { 
     set PART xc7z020-clg484-1
} else {
     set PART $::env(PART)
}
if {[info exists env(FPGA_TYPE)] == 0} {
     set FPGA_TYPE   z7
     set FPGA_FAMILY ZYNQ7000
     set PART        xc7z020-clg484-1
     set BOARD_TYPE  ZED
} else {
     set FPGA_TYPE $::env(FPGA_TYPE)
     if {${FPGA_TYPE}=="z7"} {
         set FPGA_FAMILY ZYNQ7000
          set PART       xc7z020-clg484-1
          set BOARD_TYPE ZED
     } else {
          puts "${FPGA_TYPE} not supported"
          exit 1
     }
}
if {[info exists env(MODULE)] == 0} { 
     set MODULE hsr_danh_axi
} else { 
     set MODULE $::env(MODULE)
}
if {[info exists env(DIR_WORK)] == 0} { 
     set DIR_WORK work
} else { 
     set DIR_WORK $::env(DIR_WORK)
}
if {[info exists env(DIR_FIP)]==0} {
     set DIR_FIP    ../../../../FIP
} else {
     set DIR_FIP    $::env(DIR_FIP)
}
if {[info exists env(DIR_XDC)]==0} {
     set DIR_XDC    xdc
} else {
     set DIR_XDC    $::env(DIR_XDC)
}
if {[info exists env(RIGOR)] == 0} { 
     set RIGOR 1
} else { 
     set RIGOR $::env(RIGOR)
}

#---------------------------------------------------------
set_part ${PART}
set_property part ${PART} [current_project]
#set_property board_part xilinx.com:vcu108:part0:1.2 [current_project]
#
file mkdir   ${DIR_WORK}
set  out_dir ${DIR_WORK}
set  part    ${PART}
set  module  ${MODULE}
set  rigor   ${RIGOR}

#---------------------------------------------------------
# Assemble the design source files
     set DIR_RTL             "../../design/verilog"
     set DIR_MEM_AXI         "${DIR_FIP}/mem_axi"
     set DIR_MEM_AXI_DUAL    "${DIR_FIP}/mem_axi_dual"
     set DIR_GBE_AXI         "${DIR_FIP}/gig_eth_mac"
     set DIR_HSR             "${DIR_FIP}/gig_eth_hsr"
     set DIR_MDIO_AXI        "${DIR_FIP}/mdio_amba"
     set DIR_AMBA_AXI        "${DIR_FIP}/amba_axi"
     set DIR_AMBA_APB        "${DIR_FIP}/axi_to_apb"
     set DIR_GPIO            "${DIR_FIP}/gpio_amba"

     set DIR_MEM_AXI_BRAM       "${DIR_MEM_AXI}/bram_simple_dual_port/z7/${VIVADO_VER}"
     set DIR_MEM_AXI_DUAL_BRAM  "${DIR_MEM_AXI_DUAL}/bram_true_dual_port/z7/${VIVADO_VER}"
     set DIR_GBE_AXI_AFIFO      "${DIR_GBE_AXI}/fifo_async/z7/${VIVADO_VER}"
     set DIR_HSR_SFIFO          "${DIR_HSR}/fifo_sync/z7/${VIVADO_VER}"
     set DIR_HSR_AFIFO          "${DIR_HSR}/fifo_async/z7/${VIVADO_VER}"

     read_edif "
         ${DIR_GBE_AXI}/syn/vivado.${FPGA_TYPE}/gig_eth_mac_danh_axi.edif
         ${DIR_HSR}/syn/vivado.${FPGA_TYPE}/gig_eth_hsr_danh.edif
         ${DIR_MDIO_AXI}/syn/vivado.${FPGA_TYPE}/mdio_apb.edif
     "

     read_ip "
         ${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x16KB/bram_simple_dual_port_32x16KB.xci
         ${DIR_MEM_AXI_DUAL_BRAM}/bram_true_dual_port_32x16KB/bram_true_dual_port_32x16KB.xci
     "
        #${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x8KB/bram_simple_dual_port_32x8KB.xci
        #${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x32KB/bram_simple_dual_port_32x32KB.xci
        #${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x64KB/bram_simple_dual_port_32x64KB.xci
        #${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x128KB/bram_simple_dual_port_32x128KB.xci
        #${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x256KB/bram_simple_dual_port_32x256KB.xci
        #${DIR_MEM_AXI_BRAM}/bram_simple_dual_port_32x512KB/bram_simple_dual_port_32x512KB.xci
        #${DIR_MEM_AXI_DUAL_BRAM}/bram_true_dual_port_32x32KB/bram_true_dual_port_32x32KB.xci
        #${DIR_MEM_AXI_DUAL_BRAM}/bram_true_dual_port_32x64KB/bram_true_dual_port_32x64KB.xci

     set_property verilog_dir "
                ${DIR_RTL}
                ${DIR_MEM_AXI}/rtl/verilog
                ${DIR_MEM_AXI_BRAM}
                ${DIR_MEM_AXI_DUAL}/rtl/verilog
                ${DIR_MEM_AXI_DUAL_BRAM}
                ${DIR_GBE_AXI}/rtl/verilog
                ${DIR_GBE_AXI}/rtl/verilog/gig_eth_mac_core
                ${DIR_GBE_AXI_AFIFO}
                ${DIR_HSR}/rtl/verilog
                ${DIR_HSR_SFIFO}
                ${DIR_HSR_AFIFO}
                ${DIR_MDIO_AXI}/rtl/verilog
                ${DIR_AMBA_AXI}/rtl/verilog
                ${DIR_AMBA_APB}/rtl/verilog
                ${DIR_GPIO}/rtl/verilog
     " [current_fileset]

     set_property verilog_define "SYN=1\
                                  SYN\
                                  BOARD_ZED=1\
                                  BOARD_ZED\
                                  VIVADO=1\
                                  VIVADO\
                                  FPGA_TYPE=${FPGA_TYPE}\
                                  FPGA_FAMILY=\"${FPGA_FAMILY}\"\
                                  XILINX_Z7=1\
                                  AMBA_AXI4=1\
                                  AMBA_AXI4\
     " [current_fileset]

     read_verilog  "
                ./syn_define.v
                ${DIR_RTL}/hsr_danh_axi.v
                ${DIR_MEM_AXI}/rtl/verilog/bram_axi.v
                ${DIR_MEM_AXI_DUAL}/rtl/verilog/bram_axi_dual.v
                ${DIR_GBE_AXI}/rtl/verilog/gig_eth_mac_danh_axi_stub.v
                ${DIR_HSR}/rtl/verilog/gig_eth_hsr_danh_stub.v
                ${DIR_MDIO_AXI}/rtl/verilog/mdio_apb_stub.v
                ${DIR_AMBA_AXI}/rtl/verilog/axi_switch_m2s5.v
                ${DIR_AMBA_APB}/rtl/verilog/axi_to_apb_s3.v
                ${DIR_GPIO}/rtl/verilog/gpio_apb.v
     "

     update_compile_order -fileset sources_1
     set_property is_global_include true [get_files  ./syn_define.v]
     reorder_files -front ./syn_define.v

     set XDC_LIST "
         ${DIR_XDC}/fpga_zed.xdc
         ${DIR_XDC}/fpga_zed_performance.xdc
         ${DIR_XDC}/fmc-gbe-rj45-p12-hsr_lpc_zed.xdc
         ${DIR_XDC}/hsr_danh_axi.xdc
     "
     if {[file exists "additional.xdc"] == 1} {
         append XDC_LIST "additional.xdc"
     }

     read_xdc ${XDC_LIST}

     set   fpout  [ open "all.xdc" "w" ]
     foreach F ${XDC_LIST} {
         set   fpin   [ open "$F" r ]
         set   fdata  [ read $fpin ]
         puts  -nonewline $fpout $fdata
         close $fpin
     }
     close $fpout

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

#---------------------------------------------------------
# Run synthesis and implementation
#     set_property IOB true [ all_inputs  ]
#     set_property IOB true [ all_outputs ]
     synth_design -top ${module} -part ${part} -mode out_of_context
     write_edif -force ${module}.edn
     write_checkpoint -force ${out_dir}/post_synth
     if { ${rigor} == 1} {
        report_timing_summary -file ${out_dir}/post_synth_timing_summary.rpt
        report_timing -sort_by group -max_paths 5 -path_type summary\
                      -file ${out_dir}/post_synth_timing.rpt
        report_utilization -file ${out_dir}/post_synth_util.rpt
     }

##---------------------------------------------------------
##exit
