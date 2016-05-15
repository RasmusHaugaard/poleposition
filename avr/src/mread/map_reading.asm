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

.equ ss_dis_h = addr			;distance til sekment stopper "længde af sekment" (h-bite)
.set addr = addr + 1			;..

.equ ss_dis_l = addr			;distance til sekment stopper "længde af sekment" (l-bite)
.set addr = addr + 1			;..

.equ sek_status = addr			;status register for sekment
.set addr = addr + 1			;..

.equ is_ns_turn = addr			;næste sek (svign = 11111111, lige = 00000000)
.set addr = addr + 1			;..

;==========================
;========== Macro =========
;==========================




;==========================
;========== Main ==========
;==========================

	call find_sp				;finder start punkt
load_next_sek:					
	call get_next_sek			;loader næste sekment
	lds R16, sek_status			;Hvis lige, jmp "goto_lige"
	sbrs R16, 7					;..
	rjmp goto_lige				;..
	call drive_turn				;køre igennem sving
	rjmp load_next_sek			;køre rutine igen
goto_lige:
	call drive_straight			;Køre lige stykke
	rjmp load_next_sek			;køre rutine igen
	
	;KØR! MuKØR!!

;===========================
;========== Jumps ==========
;===========================





;=====Drive straight=====
drive_straight:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	get_dis_hl [R16, R17]		;gemmer ref dis
	sts dis_ref_h, R16			;..
	sts dis_ref_l, R17			;..
	setspeed [100]				;set speed 100%
	lds R16, is_ns_turn			;Tjekker om næste sekment er sving eller lige
	sbrs R16, 7					;skipper hvis sving
	rjmp no_turn
	call b_dis					;udregner bremse længde (retunere: b_dis_h og b_dis_l)

								;get_dis >= b_dis

	call b_mode					;bremser ned til svinget	
	setspeed [20]				;sætter hastighed til max for sving

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;return
no_turn:
	;get_dis >= ss_dis

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;retunere



;=====Drive turn=====
drive_turn:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 116				;sender t
	send_bt_byte [R16]			;..

	get_dis_hl [R16, R17]		;gemmer ref dis
	sts dis_ref_h, R16			;..
	sts dis_ref_l, R17			;..
	setspeed [20]				;sætter hastighed til max for sving

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 116				;sender t
	send_bt_byte [R16]			;..

	ret							;retuner





;=====Break distance=====
b_dis:							; (retunere: b_dis_h og b_dis_l)

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 98					;sender b
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..

	ldi R18, 40					;bremselængde = 40 tiks (19,33cm)
	lds R19, ss_dis_h			;distance til sekment stopper (sekment længde)
	lds R20, ss_dis_l			;..
	lds R21, 0					;bruges til subtraktion
	sub R20, R18				;trækker bremselængde fra referance distance
	sbc R19, R21				;..
	;ligger dis_ref til
	sts b_dis_h, R19			
	sts b_dis_l, R20

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 98					;sender b
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..

	ret							;retunere





;=====Get next sekment=====
get_next_sek:					;R28 bruges (retunere: sek_status, sek_dis_h og sek_dis_l)

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 110				;sender n
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	lds R28, sek_adr			;status
	sts sek_status, R28			;..
	.set sek_adr = sek_adr + 1	;..
	lds R28, sek_adr			;distance h-bite
	sts ss_dis_h, R28			;..
	.set sek_adr = sek_adr + 1	;..
	lds R28, sek_adr			;distance l-bite
	sts ss_dis_l, R28			;..
	.set sek_adr = sek_adr +1	;..
	lds R28, sek_adr			;Tjekker om sekment efter er lige
	sbrs R28, 7					;..
	rjmp n_sek_l				;hvis lige rjmp "n_sek_l"
	lds R16, 0b11111111			;hvis sving
	sts	is_ns_turn, R16			;..
	rjmp ns_skip				;skipper kode for lige stykke
n_sek_l:
	lds R16, 0b00000000			;hvis lige
	sts	is_ns_turn, R16			;..
ns_skip:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 110				;sender n
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;retunere	





;=====Reset sek addres=====
reset_sek_adr:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 114				;sender r
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	lds R16, def_sek_adr		;Resitter sek_adr
	sts sek_adr, R16			;..

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 114				;sender r
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;return





;=====Turn speed=====
turn_speed:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 116				;sender t
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	setspeed [20]				;setter max hastighed i sving

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 116				;sender t
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;return





;=====Break mode=====
b_mode:							;maksimale bremsning
	
	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 98					;sender b
	send_bt_byte [R16]			;..
	ldi R16, 109				;sender m
	send_bt_byte [R16]			;..

	;øhhh.. der mangler sku lidt kode..

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 98					;sender b
	send_bt_byte [R16]			;..
	ldi R16, 109				;sender m
	send_bt_byte [R16]			;..

	ret							;return





;=====Find start punkt=====
find_sp:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..
	ldi R16, 112				;sender p
	send_bt_byte [R16]			;..

	ldi R16, 0<<TOV1			;forbyder interrupt ved timer1 overflow
	out TIMSK, R16				;..
	setspeed [10]				;sætter langsom hastighed
line_scan:
	sbis TIFR, TOV1				;skib hvis externt interrupt flag er sat			<------------------------------------- skal tjekke om denne linje bliver brugt rigtigt
	rjmp line_scan				;scanner igen
	setspeed [0]				;stopper ved målstreg
	;evt brems					;tænder elektromagneten
	rjmp T1_OV_ISR_CLEAR		;clear externt interrupt flag						<------------------------------------- skal finde anden måde at kalde på, kan ikke bruge rjmp skal bruge call.
	ldi R16, 1<<TOV1			;tilader interrupt ved timer1 overflow
	out TIMSK, R16				;.. 

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..
	ldi R16, 112				;sender p
	send_bt_byte [R16]			;..

	ret							;retunere




;=========================
;========== ISR ==========
;=========================


;==================================
;========== Kom-protokol ==========
;==================================

;	ascii	betydning

;	$		begyndelse på ny tilbagemælding

;	jds		jump to "Drive straight"
;	rds		return from "Drive straight"

;	jdt		jump to "Drive turn"
;	rdt		return from "Drive turn"

;	jbd		jump to "Break distance"
;	rbd		return from "Break distance"

;	jns		jump to "Get next sekment"
;	rns		return from "Get next sekment"

;	jrs		jump to "Reset sek addres"
;	rrs		return from "Reset sek addres"

;	jts		jump to "Turn speed"
;	rts		return from "Turn speed"

;	jbm		jump to "Break mode"
;	rbm		return from "Break mode"

;	jsp		jump to "Find start punkt"
;	rsp		return from "Find start punkt"