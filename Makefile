# these are for the nandland ice40 fpga board, swap these out if they're different
DEVICE = hx1k
PACKAGE = vq100

lint: $(sv_files)
	iverilog -Wall -s top -o $(BUILD_DIR)/top $^

# Building
# note to self, tinyprog does not work for this
build:
	@echo "Using $(FILENAME)..."
	@if [ -z "$(FILENAME)"]; then echo "Usage: make build FILENAME=name"; exit 1; fi
	yosys -p 'synth_ice40 -top $(FILENAME) -blif $(FILENAME).blif -json $(FILENAME).json' $(FILENAME).v
	nextpnr-ice40 --hx1k --package vq100 --json $(FILENAME).json --asc  $(FILENAME).asc --pcf  $(FILENAME).pcf 
	icetime -d hx1k -mtr $(FILENAME).rpt $(FILENAME).asc
	icepack $(FILENAME).asc $(FILENAME).bin
	sudo iceprog -p $(FILENAME).bin -d 0403:6010 

%.blif %.json : %.v
	yosys -p 'synth_ice40 -top top -blif $@ -json $*.json' $<

%.asc: $(PIN_DEF) %.blif %.json
	nextpnr-ice40 --$(DEVICE) --package cm81   --json $*.json --asc $@ --pcf  $(PIN_DEF)

clean:
	rm -f *.asc
	rm -f *.bin
	rm -f *.blif
	rm -fr build
	rm -f timeing.txt
	rm -f *.json
	rm -f *.rpt
