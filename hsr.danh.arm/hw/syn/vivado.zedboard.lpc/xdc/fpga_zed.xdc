#--------------------------------------------------------
# CLOCK
#set_property PACKAGE_PIN Y9 [get_ports USER_CLK_IN] ;# 100Mhz
#set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK_IN]
set_property PACKAGE_PIN Y9 [get_ports BOARD_CLK_IN]
set_property IOSTANDARD LVCMOS33 [get_ports BOARD_CLK_IN]
create_clock -period 10.000 -name BOARD_CLK_IN [get_ports BOARD_CLK_IN]

#--------------------------------------------------------
#create_generated_clock -name gtx_clk -source [get_pins {u_clkmgr/CLKOUT2}] [get_ports {u_hsr/gtx_clk}]

#--------------------------------------------------------
# USER RESET
set_property PACKAGE_PIN P16 [get_ports BOARD_RST_SW]
set_property IOSTANDARD LVCMOS25 [get_ports BOARD_RST_SW]
set_input_delay -clock [get_clocks BOARD_CLK_IN] 10.000 [get_ports BOARD_RST_SW]
set_false_path -from [get_ports BOARD_RST_SW]

#--------------------------------------------------------
set_property PACKAGE_PIN F22 [get_ports {BOARD_SLIDE_SW[0]}]
set_property PACKAGE_PIN G22 [get_ports {BOARD_SLIDE_SW[1]}]
set_property PACKAGE_PIN H22 [get_ports {BOARD_SLIDE_SW[2]}]
set_property PACKAGE_PIN F21 [get_ports {BOARD_SLIDE_SW[3]}]
set_property PACKAGE_PIN H19 [get_ports {BOARD_SLIDE_SW[4]}]
set_property PACKAGE_PIN H18 [get_ports {BOARD_SLIDE_SW[5]}]
set_property PACKAGE_PIN H17 [get_ports {BOARD_SLIDE_SW[6]}]
set_property PACKAGE_PIN M15 [get_ports {BOARD_SLIDE_SW[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports BOARD_SLIDE_SW*]
set_input_delay -clock [get_clocks BOARD_CLK_IN] 10.000 [get_ports BOARD_SLIDE_SW*]
set_false_path -from [get_ports BOARD_SLIDE_SW*]

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {BOARD_LED[0]}]
set_property PACKAGE_PIN T21 [get_ports {BOARD_LED[1]}]
set_property PACKAGE_PIN U22 [get_ports {BOARD_LED[2]}]
set_property PACKAGE_PIN U21 [get_ports {BOARD_LED[3]}]
set_property PACKAGE_PIN V22 [get_ports {BOARD_LED[4]}]
set_property PACKAGE_PIN W22 [get_ports {BOARD_LED[5]}]
set_property PACKAGE_PIN U19 [get_ports {BOARD_LED[6]}]
set_property PACKAGE_PIN U14 [get_ports {BOARD_LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports BOARD_LED*]
set_output_delay -clock [get_clocks BOARD_CLK_IN] 10.000 [get_ports BOARD_LED*]
set_false_path -to [get_ports BOARD_LED*]
#--------------------------------------------------------





