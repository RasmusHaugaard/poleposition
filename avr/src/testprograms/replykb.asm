.include "src/m32def.inc"
.def char = R16
.def temp = R17
.def cnt1 = R18
.def cnt2 = R19
.def cnt = R20

.org 0x00
	rjmp init

.org 0x2a ;efter interrupt table
init:
	.include "src/setup/bluetooth.asm"
	.include "src/setup/stack_pointer.asm"
	rjmp main

sendkb:
  ldi cnt1, 10
loop1:
  ldi cnt2, 100
loop2:
  rcall sendchar
  dec cnt2
  brne loop2
  dec cnt1
  brne loop1
  ret

sendchar:
	;Er der plads i transmitter buffer?
	sbis UCSRA, UDRE
	rjmp sendchar
	out UDR, char
	inc char
	ret

main:
	;Er der en ny byte i receiver buffer?
	sbis UCSRA, RXC
	rjmp main
	ldi char, 0
	in cnt, UDR
loop3:
  rcall sendkb
  dec cnt
  brne loop3
	rjmp main
