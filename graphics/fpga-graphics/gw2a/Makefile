## Project F: FPGA Graphics - Tang Nano 20K Makefile
## Copyright Will Green, open source hardware released under the MIT License
## Learn more at https://projectf.io/posts/fpga-graphics/

## configuration
SHELL = /bin/sh
FPGA_DEVICE = GW2AR-LV18QN88C8/I7
FPGA_FAMILY = GW2A-18C
CST = tangnano20k.cst      # pins and constraints
TARGET_FREQ = 74.25  # target frequency (MHz) for 1280x720

# included modules
PATH_LIB = ../../../lib
ADD_SRC += ${PATH_LIB}/clock/gw2a/clock_720p.sv
ADD_SRC += ${PATH_LIB}/display/gw2a/dvi_generator.sv
ADD_SRC += ${PATH_LIB}/display/tmds_encoder_dvi.sv
ADD_SRC += ../simple_720p.sv

square: square.fs
flag_ethiopia: flag_ethiopia.fs
flag_sweden: flag_sweden.fs
colour: colour.fs

# synthesis
%.json: top_%.sv $(ADD_SRC)
	yosys -ql $(basename $@)-yosys.log -p 'synth_gowin -top top_$(basename $@) -json $@' $< $(ADD_SRC)

# place and route
%.config: %.json
	nextpnr-himbaechel --device ${FPGA_DEVICE} --vopt family=${FPGA_FAMILY} --freq ${TARGET_FREQ} --json $< --write $@ --vopt cst=${CST} --pre-pack pre_pack.py --randomize-seed

# pack bitstream
%.fs: %.config
	gowin_pack --device ${FPGA_FAMILY} --output $@ $<

all: square flag_ethiopia flag_sweden colour

clean:
	rm -f *.json *.config *.fs .*.d *.svf *yosys.log

.PHONY: all clean
