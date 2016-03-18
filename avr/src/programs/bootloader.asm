.include "src/m32def.inc"
.equ fosc = 16000000 ; 16 MHz "Frequency of Oscilllator" 
.equ bootload_start = 0x3800 ; skal sættes til starten af bootloadersektionen. (s. 263 i datablad) 

.org bootload_start
	jmp init

.org bootload_program_start
	.include "src/macros/end.asm"
	.include "src/bootlaoder/soft_reset.asm"
	.include "src/macros/delay.asm"
	
init:
	ldi ZH, 0
	ldi ZL, 0x1a
	ldi R0, 

	delays[2]
	.include "src/setup/bluetooth.asm"
	jmp 0x00