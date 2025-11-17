# these are for the nandland ice40 fpga board, swap these out if they're different
DEVICE = hx1k
PACKAGE = vq100
SOURCE = src
BUILD = build

BUILD_FILENAME = $(addprefix $(BUILD)/,$(FILENAME))

.PHONY: build

build/:
	mkdir -p build/

lint: $(sv_files)
	iverilog -Wall -s top -o $(BUILD_DIR)/top $^

# Building
# note to self, tinyprog does not work for this
build: build/
	@echo "Using $(FILENAME)..."
	@if [ -z "$(FILENAME)" ]; then echo "Usage: make build FILENAME=name"; exit 1; fi
	@echo "Running yosys..."
	@yosys -p 'synth_ice40 -top $(FILENAME) -blif $(BUILD_FILENAME).blif -json $(BUILD_FILENAME).json' $(SOURCE)/$(FILENAME).v 
	@yosys -p 'read_json $(BUILD_FILENAME).json; stat' > $(BUILD_FILENAME).stat
	@echo "Running nextpnr..."
	@nextpnr-ice40 --hx1k --package vq100 --json $(BUILD_FILENAME).json --asc  $(BUILD_FILENAME).asc --pcf  $(SOURCE)/$(FILENAME).pcf 
	@echo "Running icetime..."
	@icetime -d hx1k -mtr $(BUILD_FILENAME).rpt $(BUILD_FILENAME).asc
	@echo "Running icepack..."
	@icepack $(BUILD_FILENAME).asc $(BUILD_FILENAME).bin
	
ship:
	sudo iceprog $(BUILD_FILENAME).bin

%.blif %.json : %.v
	yosys -p 'synth_ice40 -top top -blif $@ -json $*.json' $<

%.asc: $(PIN_DEF) %.blif %.json
	nextpnr-ice40 --$(DEVICE) --package cm81   --json $*.json --asc $@ --pcf  $(PIN_DEF)

clean:
	rm -fr build
