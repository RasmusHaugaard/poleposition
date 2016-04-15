; starter watchdog timer, der efter ~16 ms resetter chippen
; (s. 44 i datablad atmgega32a)
rjmp sr_end

.macro soft_reset
	jmp soft_reset
.endm

soft_reset:
	ldi R16, (1 << WDE)
	out WDTCR, R16
	rjmp sr_loop

sr_loop:
	rjmp sr_loop

sr_end:
