;===================================
;========== Initalisering ==========
;===================================




;==========================
;========== Macro =========
;==========================




;==========================
;========== Main ==========
;==========================

	ldi R16, 0<<TOV1			;stopper interrupt ved timer1 overflow
	out TIMSK, R16				;..
	setspeed [20]				;finder m�lstreg/startpunkt
line_scan:
	sbis TIFR, TOV1				;skib hvis externt interrupt flag er sat			<------------------------------------- skal tjekke om denne linje bliver brugt rigtigt
	rjmp line_scan				;scanner igen
	setspeed [0]				;stopper ved m�lstreg
	;evt brems					;t�nder elektromagneten
	rjmp T1_OV_ISR_CLEAR		;clear externt interrupt flag
	;load f�rste sekment
	ldi R16, 1<<TOV1			;tilader interrupt ved timer1 overflow
	out TIMSK, R16				;.. 
	;K�R! MuK�R!!

;=========================
;========== ISR ==========
;=========================