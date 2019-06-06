#--------------------------------------------------------
# Use this when 'HSR_PERFORMANCE' is defined
# host_probe_txen // PMOD1 JA1   (Y11 )
# host_probe_rxdv // PMOD1 JA2   (AA11)
# netA_probe_txen // PMOD1 JA7   (AB11)
# netA_probe_rxdv // PMOD1 JA8   (AB10)
# netB_probe_txen // PMOD1 JA9   (AB9 )
# netB_probe_rxdv // PMOD1 JA10  (AA8 )
#
#   3.3V GND
#    |   |
#   +--+--+--+--+--+--+
#   | 6| 5| 4| 3| 2| 1|
#   +--+--+--+--+--+--+
#   |12|11|10| 9| 8| 7|
#---+--+--+--+--+--+--+---
#    |   |
#   3.3V GND

set_property PACKAGE_PIN Y11  [get_ports host_probe_txen]
set_property PACKAGE_PIN AA11 [get_ports host_probe_rxdv]
set_property PACKAGE_PIN AB11 [get_ports netA_probe_txen]
set_property PACKAGE_PIN AB10 [get_ports netA_probe_rxdv]
set_property PACKAGE_PIN AB9  [get_ports netB_probe_txen]
set_property PACKAGE_PIN AA8  [get_ports netB_probe_rxdv]
set_property IOSTANDARD LVCMOS33 [get_ports host_probe_*]
set_property IOSTANDARD LVCMOS33 [get_ports netA_probe_*]
set_property IOSTANDARD LVCMOS33 [get_ports netB_probe_*]
set_input_delay 10 -clock [get_clocks CLK100] [get_ports *_probe_*]
set_false_path -from [get_ports *_probe_*]
#--------------------------------------------------------





