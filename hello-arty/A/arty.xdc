## Project F: Hello Arty A - Vivado Board Constraints
## (C)2020 Will Green, Open source hardware released under the MIT License
## Learn more at https://projectf.io/posts/hello-arty-1/

## FPGA Configuration I/O Options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# I/O Pins
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [get_ports {sw}];
set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [get_ports {led}];
