# Makefile for programming ATmega32 using assembler
PROJECT=program
PROGRAMMER=-c usbasp -P usb

default: assembly flash

assembly: clean
	avra src/$(PROJECT).asm
	mv src/*.{cof,obj,hex} build

flash:
	sudo avrdude -p m32 $(PROGRAMMER) -U flash:w:build/$(PROJECT).hex

fuse:	#(s. 294)
	sudo avrdude -p m32 $(PROGRAMMER) -U hfuse:w:0xd8:m -U lfuse:w:0xff:m

clean:
	rm -rf build
	mkdir build

erase:
	sudo avrdude -p m32 $(PROGRAMMER) -e

watch: #kræver nodejs og watch-cli
	watch "**/*.{asm,inc}" "clear; make"

watchassembly:
	watch "**/*.{asm,inc}" "clear; make assembly"