#--------------------------------------------------------
# AXI CLOCK
#create_clock   -name aclk -period  5.0 [get_ports s_axi_aclk]
create_clock   -name s_axi_aclk -period  5.0 [get_ports s_axi_aclk]

#--------------------------------------------------------
# AXI RESET
set_false_path -to [get_ports s_axi_aresetn]

#--------------------------------------------------------
