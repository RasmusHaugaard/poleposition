.set saved_pc = PC
.org 0x12
	jmp T1_OV_ISR
.org saved_pc

in R16, TOV1
andi R16, 1<<TOV1
out TIMSK, R16

rcall reset_lap_timer
jmp lapt_file_end

.equ TCNT1HH = addr	;Opbevare værdi når timer1 overflower (24-bit register)
.set addr = addr + 1

.macro get_time_full
	.error "skal kaldes med argumenter"
.endm

.macro get_time_full_8_8_8
	push R0
	in R0, SREG
	push R0
	in R0, TIFR
	sbrs R0, TOV1
	rjmp PC + 3
	call T1_OV_ISR_CLEAR
; PC + 3:
TIME_GET_%:
	lds R0, TCNT1HH
	in @2, TCNT1L
	in @1, TCNT1H
	lds @0, TCNT1HH
	cpse R0, @0
	rjmp TIME_GET_%
	pop R0
	out SREG, R0
	pop R0
.endm

.macro get_time_hl
	Error "get_time_hl"
.endm

.macro get_time_hl_8_8
	push R0
	in R0, SREG
	push R0
	cli
	in @1, TCNT1L
	in @0, TCNT1H
	pop R0
	out SREG, R0
	pop R0
.endm

.macro get_time_hh
	Error "Skal kaldes med argumenter"
.endm

.macro get_time_hh_8
	push R0
	in R0, SREG
	push R0
	lds @0, TCNT1HH
	pop R0
	out SREG, R0
	pop R0
.endm

T1_OV_ISR:
	rcall T1_OV_ISR_CLEAR
	reti

T1_OV_ISR_CLEAR:
	push R16
	push R17
	in R16, SREG
	push R16
	lds R16, TCNT1HH
	inc R16
	sts TCNT1HH, R16
	pop R16
	out SREG, R16
	pop R17
	pop R16
	ret

reset_lap_timer:
	push R16
	ldi R16, 0x00
	out TCCR1A, R16
	out TCCR1B, R16
	ldi R16, 0x00
	sts TCNT1HH, R16
	out TCNT1H, R16
	out TCNT1L, R16
	ldi R16, 0b00000100
	out TCCR1B, R16
	pop R16
	ret

lapt_file_end:
