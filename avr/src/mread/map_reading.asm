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
	setspeed [32]				;finder m�lstreg/startpunkt
find_finish_line:
	nop							;venter
	sbis						;skib hvis externt interrupt flag er sat
	rjmp find_finish_line		;scanner igen
	setspeed [0]				;stopper ved m�lstreg
	;clear externt interrupt flag
	;enable lap interrupt
	;K�R! MuK�R!!

;=========================
;========== ISR ==========
;=========================