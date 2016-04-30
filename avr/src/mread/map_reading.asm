;===================================
;========== Initalisering ==========
;===================================
.equ def_sek_adr =				;første sekment adresse						<--------------------------------------------- find adresse til første sekment
.equ sek_adr = addr				;nuværendene sekment adresse
.set addr = addr + 1			;..
.equ dis_ref_h = addr			;distance referance (h-bite)
.set addr = addr + 1			;..				
.equ dis_ref_l = addr			;distance referance (l-bite)
.set addr = addr + 1			;..
.equ b_dis_h = addr				;bremse længde (h-bite)
.set addr = addr + 1			;..
.equ b_dis_l = addr				;bremse længde (l-bite)
.set addr = addr + 1			;..

;==========================
;========== Macro =========
;==========================




;==========================
;========== Main ==========
;==========================


	Rjmp
	ldi R16, 0<<TOV1			;forbyder interrupt ved timer1 overflow
	out TIMSK, R16				;..
	setspeed [20]				;sætter langsom hastighed
line_scan:
	sbis TIFR, TOV1				;skib hvis externt interrupt flag er sat			<------------------------------------- skal tjekke om denne linje bliver brugt rigtigt
	rjmp line_scan				;scanner igen
	setspeed [0]				;stopper ved målstreg
	;evt brems					;tænder elektromagneten
	rjmp T1_OV_ISR_CLEAR		;clear externt interrupt flag
	ldi R16, 1<<TOV1			;tilader interrupt ved timer1 overflow
	out TIMSK, R16				;.. 

	rjmp get_next_sek			;loader næste sekment
	;Hvis sving skip next line
	rjmp drive_straight			;Køre lige stykke
	rjmp drive_turn				;køre igennem sving

	
	;KØR! MuKØR!!

;===========================
;========== Jumps ==========
;===========================

drive_straight:
	get_dis_hl [R16, R17]		;gemmer tilbagelagte distance
	sts dis_ref_h, R16			;..
	sts dis_ref_l, R17			;..
	setspeed [100]				;set speed 100%
	rjmp b_dis					;udregner bremse længde
	cp_b_dis:						;tjekker om der skal bremses
	get_dis_hl [R16, R17]		;henter nyværendene tilbagelagte distance
	cp	R16, R29				;sammenligner med bremselængde (high-byte)
	brne cp_b_dis				;..
	cp	R17, R30				;sammenligner med bremselængde (low-byte)
	brne cp_b_dis				;..
	ret

drive_turn:
	
	ret

b_dis:							;R19 b_dis_h, R20 b_dis_l
	ldi R18, 40					;bremselængde = 40 tiks (19,33 cm)
	lds R19, dis_ref_h			;høje referance distance
	lds R20, dis_ref_l			;lave referance distance
	lds R21, 0
	sub R20, R18				;trækker bremselængde fra referance distance
	sbc R19, R21				;..
	sts b_dis_h, R19
	sts b_dis_l, R20
	ret

get_next_sek:					;R28 status, R29 distance h-bite, R30 distance l-bite
	lds R28, sek_adr			;status
	.set sek_adr = sek_adr + 1	;distance h-bite
	lds R29, sek_adr			;..
	.set sek_adr = sek_adr + 1	;distance l-bite
	lds R30, sek_adr			;..
	ret

reset_sek_adr:
	lds R16, def_sek_adr		;Resitter sek_adr
	sts sek_adr, R16			;..
	ret


;=========================
;========== ISR ==========
;=========================