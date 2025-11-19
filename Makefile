# these are for the nandland ice40 fpga board, swap these out if they're different
DEVICE = hx1k
PACKAGE = vq100
SOURCE = src
BUILD = build

SOURCE_DIR = $(addprefix $(src)/,$(PROJ)/)
BUILD_FILENAME = $(addprefix $(BUILD)/,$(FILENAME))
SDC_FILE := $(wildcard $(SOURCE)/$(FILENAME).sdc)
SDC_FLAG := $(if $(SDC_FILE),--sdc $(SDC_FILE),)

sv_files := $(wildcard $(SOURCE)/$(FILENAME)*.sv $(SOURCE)/$(FILENAME)*.v)
svfiles := $(wildcard $(SOURCE)/$(PROJ)/*.sv $(SOURCE)/$(PROJ)/*.v)
buildfiles :=  $(wildcard $(SOURCE)/$(PROJ)/*.v)
pcffile := $(firstword $(wildcard $(SOURCE)/$(PROJ)/*.pcf))

.PHONY: build

build/:
	mkdir -p build/


bsim: $(sv_files)
	@make build
	@echo "BUILD: Building $(FILENAME) with iverilog..."
	@iverilog -Wall -s $(FILENAME)_TB -o $(BUILD)/$(FILENAME) $^	
	@echo "SIMULATE: running vvp"
	@vvp $(BUILD)/$(FILENAME)
	@echo "WAVEFORM VIEW: check to see if there's a vcd to display..."
	@if [ -f $(BUILD)/$(FILENAME).vcd ]; then gtkwave $(BUILD)/$(FILENAME).vcd 2>/dev/null; fi;

sim: $(svfiles) 
	@echo "BUILD: Building $(PROJ) with iverilog..."
	echo $(svfiles)
	@iverilog -Wall -s $(PROJ)_TB -o $(BUILD)/$(PROJ) $^	
	@echo "SIMULATE: running vvp"
	@vvp $(BUILD)/$(PROJ)
	@echo "WAVEFORM VIEW: check to see if there's a vcd to display..."
	@if [ -f $(BUILD)/$(PROJ).vcd ]; then gtkwave $(BUILD)/$(PROJ).vcd 2>/dev/null; fi;

# Building
build: build/
	@echo "Using $(FILENAME):"
	@if [ -z "$(FILENAME)" ]; then echo "Usage: make build FILENAME=name"; exit 1; fi
	
	@echo "SYNTHESIS: Running yosys ..."
	@yosys -q -p 'synth_ice40 -top $(FILENAME) -json $(BUILD_FILENAME).json' $(SOURCE)/$(FILENAME).v 
	@yosys -p 'read_json $(BUILD_FILENAME).json; stat' > $(BUILD_FILENAME).stat
	
	@echo "PLACE & ROUTE: Running nextpnr..."
	@nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(BUILD_FILENAME).json --asc  $(BUILD_FILENAME).asc --pcf  $(SOURCE)/$(FILENAME).pcf --log $(BUILD_FILENAME).log $(SDC_FLAG) --quiet

	@echo "TIMING: Running icetime timing analysis..."
	@icetime -d $(DEVICE) -mtr $(BUILD_FILENAME).rpt $(BUILD_FILENAME).asc 1>/dev/null
	
	@echo "PACKING: Running icepack..."
	@icepack $(BUILD_FILENAME).asc $(BUILD_FILENAME).bin
	
# Building
buildy: build/ $(buildfiles) $(topfile)
	@echo "Using $(PROJ):"
	@if [ -z "$(PROJ)" ]; then echo "Usage: make build PROJ=name"; exit 1; fi
	
	@echo $(buildfiles) $(pcffile)

	@echo "SYNTHESIS: Running yosys ..."
	@yosys -q -p 'synth_ice40 -top $(PROJ)_Top -json $(BUILD)/$(PROJ).json' $(buildfiles)
	@yosys -p 'read_json $(BUILD)/$(PROJ).json; stat' > $(BUILD)/$(PROJ).stat	
	@echo "PLACE & ROUTE: Running nextpnr..."
	@nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(BUILD)/$(PROJ).json --asc  $(BUILD)/$(PROJ).asc --pcf  $(pcffile) --log $(BUILD)/$(PROJ).log $(SDC_FLAG) --quiet
	@echo "TIMING: Running icetime timing analysis..."
	@icetime -d $(DEVICE) -mtr $(BUILD)/$(PROJ).rpt $(BUILD)/$(PROJ).asc 1>/dev/null
	@echo "PACKING: Running icepack..."
	@icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin
	
ship:
	@echo "PROGRAMMING: programming fpga..."
	iceprog $(BUILD_FILENAME).bin

%.blif %.json : %.v
	yosys -p 'synth_ice40 -top top -blif $@ -json $*.json' $<

%.asc: $(PIN_DEF) %.blif %.json
	nextpnr-ice40 --$(DEVICE) --package cm81   --json $*.json --asc $@ --pcf  $(PIN_DEF)

clean:
	rm -fr build
