# Makefile for programming ATmega32 using assembler
PROJECT=program
PROGRAMMER=-c usbasp -P usb

default: compile upload

compile: clean
	avra src/$(PROJECT).asm
	mv src/*.{cof,obj,hex} build

upload:
	sudo avrdude -p m32 $(PROGRAMMER) -U flash:w:build/$(PROJECT).hex

fuse:	#(s. 294)
	sudo avrdude -p m32 $(PROGRAMMER) -U hfuse:w:0xd9:m -U lfuse:w:0xe0:m

clean:
	rm -rf build
	mkdir build

erase:
	sudo avrdude -p m32 $(PROGRAMMER) -e

watch: #kræver nodejs og watch-cli
	watch "**/*.{asm,inc}" "clear; make"

watchcompile:
	watch "**/*.{asm,inc}" "clear; make compile"