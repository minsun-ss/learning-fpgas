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

sim: $(svfiles)
	@echo "BUILD: Building $(PROJ) with iverilog..."
	echo $(svfiles)
	@iverilog -Wall -g2012 -s $(PROJ)_TB -o $(BUILD)/$(PROJ) $^
	@echo "SIMULATE: running vvp"
	@vvp $(BUILD)/$(PROJ)
	@echo "WAVEFORM VIEW: check to see if there's a vcd to display..."
	@if [ -f $(BUILD)/$(PROJ).vcd ]; then gtkwave $(BUILD)/$(PROJ).vcd 2>/dev/null; fi;

build: build/ $(buildfiles) $(topfile)
	@echo "Using $(PROJ):"
	@if [ -z "$(PROJ)" ]; then echo "Usage: make build PROJ=name"; exit 1; fi

	@printf "%-15s" "SYNTHESIS:"; printf "Running yosys ...\n";
	@yosys -q -p 'synth_ice40 -top $(PROJ)_Top -json $(BUILD)/$(PROJ).json' $(buildfiles) 2>/dev/null || yosys -q -p 'synth_ice40 -top $(PROJ) -json $(BUILD)/$(PROJ).json' $(buildfiles)
	@yosys -p 'read_json $(BUILD)/$(PROJ).json; stat' > $(BUILD)/$(PROJ).stat

	@printf "%-15s" "PLACE & ROUTE:"; printf "Running nextpnr...\n"
	@nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(BUILD)/$(PROJ).json --asc  $(BUILD)/$(PROJ).asc --pcf  $(pcffile) --log $(BUILD)/$(PROJ).log $(SDC_FLAG) --quiet

	@printf "%-15s" "TIMING:"; printf "Running icetime timing analysis...\n"
	@icetime -d $(DEVICE) -mtr $(BUILD)/$(PROJ).rpt $(BUILD)/$(PROJ).asc 1>/dev/null

	@printf "%-15s" "PACKING:"; printf "Running icepack...\n"
	@icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

ship:
	@echo "PROGRAMMING: programming fpga..."
	@iceprog $(BUILD)/$(PROJ).bin

%.blif %.json : %.v
	yosys -p 'synth_ice40 -top top -blif $@ -json $*.json' $<

%.asc: $(PIN_DEF) %.blif %.json
	nextpnr-ice40 --$(DEVICE) --package cm81   --json $*.json --asc $@ --pcf  $(PIN_DEF)

clean:
	rm -fr build
