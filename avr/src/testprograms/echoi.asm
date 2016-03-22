.include "src/m32def.inc"
.org 0x00
	rjmp init
.org 0x1a
  rjmp rxciehandler
.org 0x2a ;efter interrupt table
init:
	.include "src/setup/bluetooth.asm"
	.include "src/setup/stack_pointer.asm"

	sbi UCSRB, RXCIE
	sei
	rjmp main

sendchar:
	;Er der plads i transmitter buffer?
	sbis UCSRA, UDRE
	;hvis ikke, vent
	rjmp sendchar
	;send R16 til transmitter buffer
	out UDR, R16
	;returner til der, hvor vi blev kaldt fra
	ret

main:
	rjmp main

rxciehandler:
  in R16, UDR
	rcall sendchar
	reti
