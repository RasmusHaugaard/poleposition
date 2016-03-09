; starter watchdog timer, der efter ~16 ms resetter chippen 
; (s. 44 i datablad atmgega32a)
.macro softreset
	jmp softreset
.endm

softreset:
	ldi R16, (1<<WDE)
	out WDTCR, R16
	end