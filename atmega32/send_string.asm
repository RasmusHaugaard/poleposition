.org	0x60
text:
	.db "Hej Phillip, din dejlige dreng!", 0xA, "Du er sgu dejlig!", 0, 0

sendchar:
	sbis UCSRA, UDRE
	rjmp sendchar

	out UDR, R16
	ret

sendstring:
	ldi ZH, HIGH(text<<1)
	ldi ZL, LOW(text<<1)
loadchar:
	lpm R16, Z
	cpi R16, 0x00
	brne sendcharfromstring
	ret
sendcharfromstring:
	call sendchar
	inc ZL
	lds R0, SREG
	sbrc R0, 0
	inc ZH
	rjmp loadchar