.include "src/m32def.inc"
.org 0x0000
	rjmp init

init:
	.include "src/setup/bluetooth.asm"
	.include "src/setup/stack_pointer.asm"
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
	;Er der en ny byte i receiver buffer?
	sbis UCSRA, RXC
	;hvis ikke, vent
	rjmp main
	;load byte i receiver buffer til R16
	in R16, UDR
	;gå til sendchar
	call sendchar
	rjmp main