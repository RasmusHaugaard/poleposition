;===================================
;========== Initalisering ==========
;===================================




;==========================
;========== Macro =========
;==========================




;==========================
;========== Main ==========
;==========================

	;disable lap interrupt
	setspeed [32]				;finder målstreg/startpunkt
find_finish_line:
	nop							;venter
	sbis						;skib hvis externt interrupt flag er sat
	rjmp find_finish_line		;scanner igen
	setspeed [0]				;stopper ved målstreg
	;clear externt interrupt flag
	;enable lap interrupt
	;KØR! MuKØR!!

;=========================
;========== ISR ==========
;=========================