
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets u_ila_0_ZYNQ_CLKMGRA.BUFG_CLKOUT4_n_4]

#recommended constraints from Vivado tool
create_generated_clock -name GBEA_GTXC_1 -source [get_pins {u_hsr/u_net_A/u_gmii/BLK_ZYNQ.u_txc/C}] -divide_by 1 -add -master_clock [get_clocks -of [get_pins u_hsr/u_net_A/u_gmii/BLK_ZYNQ.u_txc/C] -filter {IS_GENERATED && MASTER_CLOCK == CLK100}] [get_ports {GBEA_GTXC}]
create_generated_clock -name GBEB_GTXC_1 -source [get_pins {u_hsr/u_net_B/u_gmii/BLK_ZYNQ.u_txc/C}] -divide_by 1 -add -master_clock [get_clocks -of [get_pins u_hsr/u_net_B/u_gmii/BLK_ZYNQ.u_txc/C] -filter {IS_GENERATED && MASTER_CLOCK == CLK100}] [get_ports {GBEB_GTXC}]
create_generated_clock -name GBEU_GTXC_1 -source [get_pins {u_hsr/u_host/BLK_REDBOX.u_gmii/BLK_ZYNQ.u_txc/C}] -divide_by 1 -add -master_clock [get_clocks -of [get_pins u_hsr/u_host/BLK_REDBOX.u_gmii/BLK_ZYNQ.u_txc/C] -filter {IS_GENERATED && MASTER_CLOCK == CLK100}] [get_ports {GBEU_GTXC}]

set_false_path -from [get_clocks {GBEA_RXC}] -to [get_clocks {ZYNQ_CLKMGRA.SYS_CLK_CLKOUT2}]; # clk125mhz
set_false_path -from [get_clocks {GBEB_RXC}] -to [get_clocks {ZYNQ_CLKMGRA.SYS_CLK_CLKOUT2}]; # clk125mhz
set_false_path -from [get_clocks {GBEU_RXC}] -to [get_clocks {ZYNQ_CLKMGRA.SYS_CLK_CLKOUT2}]; # clk125mhz

