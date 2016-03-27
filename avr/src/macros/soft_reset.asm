; starter watchdog timer, der efter ~16 ms resetter chippen
; (s. 44 i datablad atmgega32a)
soft_reset:
	ldi R16, (1 << WDE)
	out WDTCR, R16
	rjmp sr_end

sr_end:
	rjmp sr_end
