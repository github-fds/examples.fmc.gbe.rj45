### LPC signal
### Port 0
set_property PACKAGE_PIN J16 [get_ports GBE_MDC]
set_property PACKAGE_PIN J17 [get_ports GBE_MDIO]
set_property IOSTANDARD LVCMOS25 [get_ports GBE_*]

#set_property PACKAGE_PIN B22        [get_ports GBEU_PHY_RESET_N]   ;# "FMC_LA33_N"     , G37
#set_property PACKAGE_PIN M19  [get_ports GBEU_RXC     ]   ;# "FMC_LA00_CC_P"  , G6
#set_property PACKAGE_PIN M20  [get_ports GBEU_RXD[0]  ]   ;# "FMC_LA00_CC_N"  , G7
#set_property PACKAGE_PIN P17  [get_ports GBEU_RXD[1]  ]   ;# "FMC_LA02_P"     , H7
#set_property PACKAGE_PIN N19  [get_ports GBEU_RXD[2]  ]   ;# "FMC_LA01_CC_P"  , D8
#set_property PACKAGE_PIN P18  [get_ports GBEU_RXD[3]  ]   ;# "FMC_LA02_N"     , H8
#set_property PACKAGE_PIN N20  [get_ports GBEU_RXD[4]  ]   ;# "FMC_LA01_CC_N"  , D9
#set_property PACKAGE_PIN L21  [get_ports GBEU_RXD[6]  ]   ;# "FMC_LA06_P"     , C10
#set_property PACKAGE_PIN N22  [get_ports GBEU_RXD[5]  ]   ;# "FMC_LA03_P"     , G9
#set_property PACKAGE_PIN P22  [get_ports GBEU_RXD[7]  ]   ;# "FMC_LA03_N"     , G10
#set_property PACKAGE_PIN L19  [get_ports GBEU_RXDV    ]   ;# "FMC_CLK0_N"     , H5
#set_property PACKAGE_PIN M21  [get_ports GBEU_RXER    ]   ;# "FMC_LA04_P"     , H10

#set_property PACKAGE_PIN T19  [get_ports GBEU_GTXC    ]   ;# "FMC_LA10_N"     , C15
#set_property PACKAGE_PIN P20  [get_ports GBEU_TXD[0]  ]   ;# "FMC_LA12_P"     , G15
#set_property PACKAGE_PIN P21  [get_ports GBEU_TXD[1]  ]   ;# "FMC_LA12_N"     , G16
#set_property PACKAGE_PIN N17  [get_ports GBEU_TXD[2]  ]   ;# "FMC_LA11_P"     , H16
#set_property PACKAGE_PIN L17  [get_ports GBEU_TXD[3]  ]   ;# "FMC_LA13_P"     , D17
#set_property PACKAGE_PIN N18  [get_ports GBEU_TXD[4]  ]   ;# "FMC_LA11_N"     , H17
#set_property PACKAGE_PIN K19  [get_ports GBEU_TXD[5]  ]   ;# "FMC_LA14_P"     , C18
#set_property PACKAGE_PIN M17  [get_ports GBEU_TXD[6]  ]   ;# "FMC_LA13_N"     , D18
#set_property PACKAGE_PIN J20  [get_ports GBEU_TXD[7]  ]   ;# "FMC_LA16_P"     , G18
#set_property PACKAGE_PIN R21  [get_ports GBEU_TXEN    ]   ;# "FMC_LA09_N"     , D15
#set_property PACKAGE_PIN K20  [get_ports GBEU_TXER    ]   ;# "FMC_LA14_N"     , C19

#set_property IOSTANDARD LVCMOS25           [get_ports {GBEU_*}  ]
#set_property DRIVE 12                      [get_ports {GBEU_TX*}]
#set_property SLEW  FAST                    [get_ports {GBEU_TX*}]
#create_clock -name GBEU_RXC  -period  8.0  [get_ports {GBEU_RXC}]
#create_clock -name GBEU_GTXC -period  8.0  [get_ports {GBEU_GTXC}]
#set_output_delay 1 -clock [get_clocks {ZYNQ_CLKMGRA.SYS_CLK_CLKOUT2}] [get_ports GBEU_GTXC]

#set_output_delay 10 -clock [get_clocks GBEU_GTXC] [get_ports GBEU_PHY_RESET_N]
#set_false_path -to   [get_ports GBEU_PHY_RESET_N]

#set_input_delay  -clock [get_clocks GBEU_RXC]  -min 2 [get_ports {GBEU_RXD*}]; #hold
#set_input_delay  -clock [get_clocks GBEU_RXC]  -max 4 [get_ports {GBEU_RXD*}]; #setup
#set_input_delay  -clock [get_clocks GBEU_RXC]  -max 4 [get_ports {GBEU_RXDV}]; #setup
#set_input_delay  -clock [get_clocks GBEU_RXC]  -min 2 [get_ports {GBEU_RXER}]; #hold
#set_input_delay  -clock [get_clocks GBEU_RXC]  -max 4 [get_ports {GBEU_RXER}]; #setup

#set_output_delay -clock [get_clocks GBEU_GTXC] -min 2 [get_ports {GBEU_TXD*}]; #hold
#set_output_delay -clock [get_clocks GBEU_GTXC] -max 4 [get_ports {GBEU_TXD*}]; #setup
#set_output_delay -clock [get_clocks GBEU_GTXC] -min 2 [get_ports {GBEU_TXEN}]; #hold
#set_output_delay -clock [get_clocks GBEU_GTXC] -max 4 [get_ports {GBEU_TXEN}]; #setup
#set_output_delay -clock [get_clocks GBEU_GTXC] -min 2 [get_ports {GBEU_TXER}]; #hold
#set_output_delay -clock [get_clocks GBEU_GTXC] -max 4 [get_ports {GBEU_TXER}]; #setup

#set_property IOB TRUE  [get_cells {zed_bd_i/hsr_danh_axi_0/inst/u_fpga/u_dut/u_hsr/u_host/BLK_REDBOX.u_gmii/gmii_rxd_int_reg*}]
#set_property IOB TRUE  [get_cells {zed_bd_i/hsr_danh_axi_0/inst/u_fpga/u_dut/u_hsr/u_host/BLK_REDBOX.u_gmii/gmii_rxdv_int_reg}]
#set_property IOB TRUE  [get_cells {zed_bd_i/hsr_danh_axi_0/inst/u_fpga/u_dut/u_hsr/u_host/BLK_REDBOX.u_gmii/gmii_rxer_int_reg}]
#set_property IOB TRUE  [get_cells {zed_bd_i/hsr_danh_axi_0/inst/u_fpga/u_dut/u_hsr/u_host/BLK_REDBOX.u_gmii/gmii_txd_reg*}]
#set_property IOB TRUE  [get_cells {zed_bd_i/hsr_danh_axi_0/inst/u_fpga/u_dut/u_hsr/u_host/BLK_REDBOX.u_gmii/gmii_txen_reg}]
#set_property IOB TRUE  [get_cells {zed_bd_i/hsr_danh_axi_0/inst/u_fpga/u_dut/u_hsr/u_host/BLK_REDBOX.u_gmii/gmii_txer_reg}]


### Port1
set_property PACKAGE_PIN A21 [get_ports GBEA_PHY_RESET_N]

set_property PACKAGE_PIN L18 [get_ports GBEA_RXC]
set_property PACKAGE_PIN J18 [get_ports {GBEA_RXD[0]}]
set_property PACKAGE_PIN M22 [get_ports {GBEA_RXD[1]}]
set_property PACKAGE_PIN K18 [get_ports {GBEA_RXD[2]}]
set_property PACKAGE_PIN J21 [get_ports {GBEA_RXD[3]}]
set_property PACKAGE_PIN J22 [get_ports {GBEA_RXD[4]}]
set_property PACKAGE_PIN T16 [get_ports {GBEA_RXD[5]}]
set_property PACKAGE_PIN R19 [get_ports {GBEA_RXD[6]}]
set_property PACKAGE_PIN R20 [get_ports {GBEA_RXD[7]}]
set_property PACKAGE_PIN L22 [get_ports GBEA_RXDV]
set_property PACKAGE_PIN T17 [get_ports GBEA_RXER]

set_property PACKAGE_PIN B19 [get_ports GBEA_GTXC]
set_property PACKAGE_PIN G20 [get_ports {GBEA_TXD[0]}]
set_property PACKAGE_PIN D20 [get_ports {GBEA_TXD[1]}]
set_property PACKAGE_PIN G21 [get_ports {GBEA_TXD[2]}]
set_property PACKAGE_PIN G15 [get_ports {GBEA_TXD[3]}]
set_property PACKAGE_PIN C20 [get_ports {GBEA_TXD[4]}]
set_property PACKAGE_PIN E15 [get_ports {GBEA_TXD[5]}]
set_property PACKAGE_PIN G16 [get_ports {GBEA_TXD[6]}]
set_property PACKAGE_PIN D15 [get_ports {GBEA_TXD[7]}]
set_property PACKAGE_PIN B20 [get_ports GBEA_TXEN]
set_property PACKAGE_PIN G19 [get_ports GBEA_TXER]

set_property IOSTANDARD LVCMOS25 [get_ports GBEA_*]
set_property DRIVE 12 [get_ports GBEA_TX*]
set_property SLEW FAST [get_ports GBEA_TX*]
create_clock -period 8.000 -name GBEA_RXC [get_ports GBEA_RXC]
create_clock -period 8.000 -name GBEA_GTXC [get_ports GBEA_GTXC]
#set_output_delay 1 -clock [get_clocks {ZYNQ_CLKMGRA.SYS_CLK_CLKOUT2}] [get_ports GBEA_GTXC]

set_output_delay -clock [get_clocks GBEA_GTXC] 10.000 [get_ports GBEA_PHY_RESET_N]
set_false_path -to [get_ports GBEA_PHY_RESET_N]

set_input_delay -clock [get_clocks GBEA_RXC] -min 2.000 [get_ports GBEA_RXD*]
set_input_delay -clock [get_clocks GBEA_RXC] -max 4.000 [get_ports GBEA_RXD*]
set_input_delay -clock [get_clocks GBEA_RXC] -max 4.000 [get_ports GBEA_RXDV]
set_input_delay -clock [get_clocks GBEA_RXC] -min 2.000 [get_ports GBEA_RXER]
set_input_delay -clock [get_clocks GBEA_RXC] -max 4.000 [get_ports GBEA_RXER]

set_output_delay -clock [get_clocks GBEA_GTXC] -min 2.000 [get_ports GBEA_TXD*]
set_output_delay -clock [get_clocks GBEA_GTXC] -max 4.000 [get_ports GBEA_TXD*]
set_output_delay -clock [get_clocks GBEA_GTXC] -min 2.000 [get_ports GBEA_TXEN]
set_output_delay -clock [get_clocks GBEA_GTXC] -max 4.000 [get_ports GBEA_TXEN]
set_output_delay -clock [get_clocks GBEA_GTXC] -min 2.000 [get_ports GBEA_TXER]
set_output_delay -clock [get_clocks GBEA_GTXC] -max 4.000 [get_ports GBEA_TXER]

set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_A/u_gmii/gmii_rxd_int_reg*}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_A/u_gmii/gmii_rxdv_int_reg}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_A/u_gmii/gmii_rxer_int_reg}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_A/u_gmii/gmii_txd_reg*}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_A/u_gmii/gmii_txen_reg}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_A/u_gmii/gmii_txer_reg}]

### Port 2
set_property PACKAGE_PIN A22 [get_ports GBEB_PHY_RESET_N]

set_property PACKAGE_PIN D18 [get_ports GBEB_RXC]
set_property PACKAGE_PIN F19 [get_ports {GBEB_RXD[0]}]
set_property PACKAGE_PIN E19 [get_ports {GBEB_RXD[1]}]
set_property PACKAGE_PIN E21 [get_ports {GBEB_RXD[2]}]
set_property PACKAGE_PIN F18 [get_ports {GBEB_RXD[3]}]
set_property PACKAGE_PIN E20 [get_ports {GBEB_RXD[4]}]
set_property PACKAGE_PIN D21 [get_ports {GBEB_RXD[5]}]
set_property PACKAGE_PIN E18 [get_ports {GBEB_RXD[6]}]
set_property PACKAGE_PIN D22 [get_ports {GBEB_RXD[7]}]
set_property PACKAGE_PIN C19 [get_ports GBEB_RXDV]
set_property PACKAGE_PIN C22 [get_ports GBEB_RXER]

set_property PACKAGE_PIN A18 [get_ports GBEB_GTXC]
set_property PACKAGE_PIN C17 [get_ports {GBEB_TXD[0]}]
set_property PACKAGE_PIN C18 [get_ports {GBEB_TXD[1]}]
set_property PACKAGE_PIN A16 [get_ports {GBEB_TXD[2]}]
set_property PACKAGE_PIN A17 [get_ports {GBEB_TXD[3]}]
set_property PACKAGE_PIN B16 [get_ports {GBEB_TXD[4]}]
set_property PACKAGE_PIN B17 [get_ports {GBEB_TXD[5]}]
set_property PACKAGE_PIN C15 [get_ports {GBEB_TXD[6]}]
set_property PACKAGE_PIN B15 [get_ports {GBEB_TXD[7]}]
set_property PACKAGE_PIN A19 [get_ports GBEB_TXEN]
set_property PACKAGE_PIN B21 [get_ports GBEB_TXER]

set_property IOSTANDARD LVCMOS25 [get_ports GBEB_*]
set_property DRIVE 12 [get_ports GBEB_TX*]
set_property SLEW FAST [get_ports GBEB_TX*]
create_clock -period 8.000 -name GBEB_RXC [get_ports GBEB_RXC]
create_clock -period 8.000 -name GBEB_GTXC [get_ports GBEB_GTXC]
#set_output_delay 1 -clock [get_clocks {ZYNQ_CLKMGRA.SYS_CLK_CLKOUT2}] [get_ports GBEB_GTXC]

set_output_delay -clock [get_clocks GBEB_GTXC] 10.000 [get_ports GBEB_PHY_RESET_N]
set_false_path -reset_path -to [get_ports GBEB_PHY_RESET_N]

set_input_delay -clock [get_clocks GBEB_RXC] -min 2.000 [get_ports GBEB_RXD*]
set_input_delay -clock [get_clocks GBEB_RXC] -max 4.000 [get_ports GBEB_RXD*]
set_input_delay -clock [get_clocks GBEB_RXC] -max 4.000 [get_ports GBEB_RXDV]
set_input_delay -clock [get_clocks GBEB_RXC] -min 2.000 [get_ports GBEB_RXER]
set_input_delay -clock [get_clocks GBEB_RXC] -max 4.000 [get_ports GBEB_RXER]

set_output_delay -clock [get_clocks GBEB_GTXC] -min 2.000 [get_ports GBEB_TXD*]
set_output_delay -clock [get_clocks GBEB_GTXC] -max 4.000 [get_ports GBEB_TXD*]
set_output_delay -clock [get_clocks GBEB_GTXC] -min 2.000 [get_ports GBEB_TXEN]
set_output_delay -clock [get_clocks GBEB_GTXC] -max 4.000 [get_ports GBEB_TXEN]
set_output_delay -clock [get_clocks GBEB_GTXC] -min 2.000 [get_ports GBEB_TXER]
set_output_delay -clock [get_clocks GBEB_GTXC] -max 4.000 [get_ports GBEB_TXER]

set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_B/u_gmii/gmii_rxd_int_reg*}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_B/u_gmii/gmii_rxdv_int_reg}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_B/u_gmii/gmii_rxer_int_reg}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_B/u_gmii/gmii_txd_reg*}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_B/u_gmii/gmii_txen_reg}]
set_property IOB TRUE  [get_cells {*u_dut/u_hsr/u_net_B/u_gmii/gmii_txer_reg}]

### HPC signal
#CLK125M_P0        )   ## "HA00_CC_P"  , F4
#CLK125M_N0        )   ## "HA00_CC_N"  , F5

#GBEA_MDC     )   ## "HA04_P"     , F7
#GBEA_MDIO    )   ## "HA04_N"     , F8
#GBEB_MDC     )   ## "HA09_P"     , E9
#GBEB_MDIO    )   ## "HA09_N"     , E10

#GBEU_CRS     )   ## "HA01_CC_P"  , E2
#GBEU_COL     )   ## "HA01_CC_N"  , E3
#GBEA_CRS     )   ## "HA05_P"     , E6
#GBEA_COL     )   ## "HA03_P"     , J6
#GBEB_CRS     )   ## "HA05_N"     , E7
#GBEB_COL     )   ## "HA03_N"     , J7

#GBEU_TXC     )   ## "HA02_P"     , K7
#GBEA_TXC     )   ## "HA02_N"     , K8
#GBEB_TXC     )   ## "HA07_P"     , J9

#PPS0              )   ## "HA08_P"     , F10
#PPS1              )   ## "HA08_N"     , F11
#PPS2              )   ## "HA12_P"     , F13
#PPS3              )   ## "HA12_N"     , F14

#BD_ID_SW0         )   ## "HA06_P"     , K10
#BD_ID_SW1         )   ## "HA06_N"     , K11
#BD_ID_SW2         )   ## "HA11_P"     , J12
#BD_ID_SW3         )   ## "HA11_N"     , J13
#BD_ID_SW4         )   ## "HA10_P"     , K13
#BD_ID_SW5         )   ## "HA10_N"     , K14
#BD_ID_SW6         )   ## "HA14_P"     , J15
#BD_ID_SW7         )   ## "HA14_N"     , J16





