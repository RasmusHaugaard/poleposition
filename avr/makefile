# Makefile for programming ATmega32 using assembler
PROJECT = program
PROGRAMMER = -c usbasp -P usb

in = src
temp = temp
out = build

inDir = ./$(in)/
tempDir = ./$(temp)/$(in)/
outDir = ./$(out)/

default: assemble flash

flash:
	sudo avrdude -p m32 $(PROGRAMMER) -U flash:w:build/$(PROJECT).hex

assemble: preprocess cleanOut
	mkdir $(out)
	(cd $(temp) && avra -l "$(inDir)listfile.lst" "$(inDir)$(PROJECT).asm")
	mv $(temp)/$(in)/*.{cof,obj,hex,lst} $(out)

preprocess: cleanTemp
	node scripts/preprocessor $(inDir) $(tempDir)

cleanOut:
	node scripts/clean $(outDir)

cleanTemp:
	node scripts/clean $(tempDir)

watch: #kræver nodejs og watch-cli
	watch "$(inDir)**/*.{asm,inc}" "clear; make"

watchassemble:
	watch "$(inDir)**/*.{asm,inc}" "clear; make assemble"

fuse:	#(s. 294)
	sudo avrdude -p m32 $(PROGRAMMER) -U hfuse:w:0xd8:m -U lfuse:w:0xff:m

erase:
	sudo avrdude -p m32 $(PROGRAMMER) -e
