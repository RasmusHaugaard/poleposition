;===================================
;========== Initalisering ==========
;===================================
.equ def_sek_adr =				;første sekment adresse						<---------------------------------- find adresse til første sekment

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

.equ ss_dis_h = addr			;distance til sekment stopper (h-bite)
.set addr = addr + 1			;..

.equ ss_dis_l = addr			;distance til sekment stopper (l-bite)
.set addr = addr + 1			;..

.equ sek_status = addr			;status register for sekment
.set addr = addr + 1			;..

;==========================
;========== Macro =========
;==========================




;==========================
;========== Main ==========
;==========================

	rjmp find_sp				;finder start punkt
load_next_sek:					
	rjmp get_next_sek			;loader næste sekment
	;Hvis sving, jmp "goto_turn"
	rjmp drive_straight			;Køre lige stykke
	rjmp skip_turn				;skipper sving
goto_turn:
	rjmp drive_turn				;køre igennem sving
skip_turn:
	rjmp load_next_sek			;køre rutine igen
	
	;KØR! MuKØR!!

;===========================
;========== Jumps ==========
;===========================





;=====Drive straight=====
drive_straight:
	get_dis_hl [R16, R17]		;gemmer ref dis
	sts dis_ref_h, R16			;..
	sts dis_ref_l, R17			;..
	;branch if next sekment is straight no_turn
	setspeed [100]				;set speed 100%
	rjmp b_dis					;udregner bremse længde (retunere: b_dis_h og b_dis_l)
	;get_dis >= b_dis
	rjmp b_mode					;bremser ned til svinget	
	rjmp turn_speed				;sætter hastighed til max for sving
	ret							;return
no_turn:
	;get_dis >= ss_dis
	ret							;retunere





;=====Drive turn=====
drive_turn:
	get_dis_hl [R16, R17]		;gemmer ref dis
	sts dis_ref_h, R16			;..
	sts dis_ref_l, R17			;..
	rjmp turn_speed				;sætter hastighed til max for sving

	ret							;retuner





;=====Break distance=====
b_dis:							; (retunere: b_dis_h og b_dis_l)
	ldi R18, 40					;bremselængde = 40 tiks (19,33cm)
	lds R19, ss_dis_h			;distance til sekment stopper (sekment længde)
	lds R20, ss_dis_l			;..
	lds R21, 0					;
	sub R20, R18				;trækker bremselængde fra referance distance
	sbc R19, R21				;..
	;ligger dis_ref til
	sts b_dis_h, R19			
	sts b_dis_l, R20
	ret							;retunere





;=====Get next sekment=====
get_next_sek:					;R28 bruges (retunere: sek_status, sek_dis_h og sek_dis_l)
	lds R28, sek_adr			;status
	sts sek_status, R28			;..
	.set sek_adr = sek_adr + 1	;..
	lds R28, sek_adr			;distance h-bite
	sts ss_dis_h, R28			;..
	.set sek_adr = sek_adr + 1	;..
	lds R28, sek_adr			;distance l-bite
	sts ss_dis_l, R28
	.set sek_adr = sek_adr +1	;..
	ret							;retunere	





;=====Reset sek addres=====
reset_sek_adr:
	lds R16, def_sek_adr		;Resitter sek_adr
	sts sek_adr, R16			;..
	ret							;return





;=====Turn speed=====
turn_speed:
	setspeed [20]				;setter max hastighed i sving
	ret							;return





;=====Break mode=====
b_mode:							;maksimale bremsning
	;øhhh.. der mangler sku lidt kode..
	ret							;return





;=====Find start punkt=====
find_sp:
	ldi R16, 0<<TOV1			;forbyder interrupt ved timer1 overflow
	out TIMSK, R16				;..
	setspeed [10]				;sætter langsom hastighed
line_scan:
	sbis TIFR, TOV1				;skib hvis externt interrupt flag er sat			<------------------------------------- skal tjekke om denne linje bliver brugt rigtigt
	rjmp line_scan				;scanner igen
	setspeed [0]				;stopper ved målstreg
	;evt brems					;tænder elektromagneten
	rjmp T1_OV_ISR_CLEAR		;clear externt interrupt flag
	ldi R16, 1<<TOV1			;tilader interrupt ved timer1 overflow
	out TIMSK, R16				;.. 





;=========================
;========== ISR ==========
;=========================