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
.equ p_dis_h = addr				;distance to next point (h-bite)
.set addr = addr + 1			;..
.equ p_dis_l = addr				;distance to next point (l-bite)
.set addr = addr + 1			;..
.equ status_dis = addr			;status register for sekment
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

drive_straight:
	get_dis_hl [R16, R17]		;gemmer tilbagelagte distance
	sts dis_ref_h, R16			;..
	sts dis_ref_l, R17			;..
	rjmp b_dis					;udregner bremse længde
	setspeed [100]				;set speed 100%
cp_b_dis:						;tjekker om der skal bremses
	get_dis_hl [R16, R17]		;henter nyværendene tilbagelagte distance
	cp	R16, R29				;sammenligner med bremselængde (high-byte)
	brne cp_b_dis				;..
	cp	R17, R30				;sammenligner med bremselængde (low-byte)
	brne cp_b_dis				;..
	rjmp turn_speed				;sætter hastighed til max for sving

	ret							;retunere

drive_turn:
	
	ret							;retunere

b_dis:							; (retunere: b_dis_h og b_dis_l)
	ldi R18, 40					;bremselængde = 40 tiks (19,33cm)
	lds R19, p_dis_h			;distance til næste point (sekment længde)
	lds R20, p_dis_l			;..
	lds R21, 0					;
	sub R20, R18				;trækker bremselængde fra referance distance
	sbc R19, R21				;..
	;ligger dis_ref til
	sts b_dis_h, R19			
	sts b_dis_l, R20
	ret							;retunere

get_next_sek:					;R28 bruges (retunere: status_dis, p_dis_h og p_dis_l)
	lds R28, sek_adr			;status
	sts dis_status, R28			;..
	.set sek_adr = sek_adr + 1	;..
	lds R28, sek_adr			;distance h-bite
	sts p_dis_h, R28			;..
	.set sek_adr = sek_adr + 1	;..
	lds R28, sek_adr			;distance l-bite
	sts p_dis_l, R28
	.set sek_adr = sek_adr +1	;..
	ret							;retunere	

reset_sek_adr:
	lds R16, def_sek_adr		;Resitter sek_adr
	sts sek_adr, R16			;..
	ret

turn_speed:
	setspeed [20]				;setter max hastighed i sving

b_mode:							;maksimale bremsning
	

;=========================
;========== ISR ==========
;=========================