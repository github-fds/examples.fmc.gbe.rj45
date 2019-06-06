if {[info exists env(VIVADO)]==0} {
    set VIVADO   /opt/Xinlinx
} else {
    set VIVADO   $::env(XILINX_VIVADO)/bin/vivado
}
if {[info exist env(BOARD_PART)]==0} {
    set BOARD_PART em.avnet.com:zed:part0
} else {
    set BOARD_PART $::env(BOARD_PART)
}
if {[info exist env(PART)]==0} {
    set PART     xc7z020clg484-1
} else {
    set PART     $::env(PART)
}
if {[info exists env(MODULE)]==0} {
    set MODULE     mac_ptp_axi
} else {
    set MODULE     $::env(MODULE)
}
if {[info exists env(DIR_WORK)]==0} {
    set DIR_WORK work
} else {
    set DIR_WORK $::env(DIR_WORK)
}
if {[info exists env(DIR_DESIGN)]==0} {
    set DIR_DESIGN     ../../design/verilog
} else {
    set DIR_DESIGN     $::env(DIR_DESIGN)
}
if {[info exists env(DIR_EDIF)]==0} {
    set DIR_EDIF       ../../syn/vivado.zedboard.lpc
} else {
    set DIR_EDIF       $::env(DIR_EDIF)
}
if {[info exists env(DIR_XDC)]==0} {
    set DIR_XDC        ../../syn/vivado.zedboard.lpc/xdc
} else {
    set DIR_XDC        $::env(DIR_XDC)
}

create_project ${MODULE} [pwd] -part ${PART} -force
set VIVADO_VERSION [version -short]
if {${VIVADO_VERSION}=="2017.4"} {
    set board_part_version ${BOARD_PART}:1.3
} elseif {${VIVADO_VERSION}=="2018.2"} {
    set board_part_version ${BOARD_PART}:1.4
} elseif {${VIVADO_VERSION}=="2018.3"} {
    set board_part_version ${BOARD_PART}:1.4
} else {
    puts "${VIVADO_VERSION} not considerred"
    set board_part_version ${BOARD_PART}:1.0
}
set_property board_part ${board_part_version} [current_project]
#set_property vendor_display_name {Future Design Systems} [current_project]
#set_property company_url www.future-ds.com [current_project]

read_edif     " ${DIR_EDIF}/${MODULE}.edn "
#read_verilog  " ${DIR_DESIGN}/${MODULE}_blackbox.v "
#add_files -fileset constrs_1 -norecurse ${DIR_XDC}/${MODULE}_OOC.xdc
#import_files -fileset constrs_1 ${DIR_XDC}/${MODULE}_OOC.xdc
#set_property PROCESSING_ORDER LATE [get_files ${MODULE}.srcs/constrs_1/imports/xdc/${MODULE}_OOC.xdc]
#set_property USED_IN {synthesis implementation out_of_context} [get_files ${MODULE}.srcs/constrs_1/imports/xdc/${MODULE}_OOC.xdc]

#### packing IP
set VERSION 1.0
set VERSION_ [string map {. _} ${VERSION}]
ipx::package_project -root_dir [pwd]\
                     -vendor {future-ds.com}\
                     -library user -taxonomy /UserIP\
                     -import_files "${DIR_EDIF}/${MODULE}.edn"
#                     -import_files "${DIR_DESIGN}/${MODULE}_blackbox.v
#                                    ${DIR_EDIF}/${MODULE}.edn"
set_property display_name        ${MODULE}              [ipx::current_core]
set_property vendor_display_name {Future Design Systems}     [ipx::current_core]
set_property company_url         {http://www.future-ds.com}  [ipx::current_core]
set_property description         ${MODULE}_v${VERSION_} [ipx::current_core]
set_property version             ${VERSION}                  [ipx::current_core]
set_property core_revision       2                           [ipx::current_core]
#ipx::associate_bus_interfaces -busif s_axi -clock s_axi_aclk [ipx::current_core]
#set_property description s_axi_aresetn [ipx::get_bus_parameters ASSOCIATED_RESET -of_objects [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]]
#ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]
#set_property description 100Mhz [ipx::get_bus_parameters FREQ_HZ -of_objects [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

set_property  ip_repo_paths  [pwd]  [current_project]
update_ip_catalog -rebuild 

ipx::check_integrity -quiet [ipx::current_core]


