;===================================
;========== Initalisering ==========
;===================================
;.a def_sek_adr =	mapping_data_addr			;f�rste sekment adresse						<---------------------------------- find adresse til f�rste sekment

;.equ sek_adr = addr				;nuv�rendene sekment adresse
;.set addr = addr + 1			;..

.equ dis_ref_h = addr			;distance referance (h-bite)
.set addr = addr + 1			;..	
			
.equ dis_ref_l = addr			;distance referance (l-bite)
.set addr = addr + 1			;..

.equ b_dis_h = addr				;bremse l�ngde (h-bite) "der skal bremses n�r fet_dis n�r denne v�rdi"
.set addr = addr + 1			;..

.equ b_dis_l = addr				;bremse l�ngde (l-bite) "der skal bremses n�r fet_dis n�r denne v�rdi"
.set addr = addr + 1			;..

.equ ss_dis_h = addr			;distance til sekment stopper "l�ngde af sekment" (h-bite)
.set addr = addr + 1			;..

.equ ss_dis_l = addr			;distance til sekment stopper "l�ngde af sekment" (l-bite)
.set addr = addr + 1			;..

.equ sek_status = addr			;status register for sekment
.set addr = addr + 1			;..

.equ is_ns_turn = addr			;n�ste sek (svign = 11111111, lige = 00000000)
.set addr = addr + 1			;..

.equ brake_tik = addr			;hvor langt fra et sving, bremsningen skal p�begyndes. [tiks]
.set addr = addr + 1			;..

.equ mts = addr					;max hastighed i sving
.set addr = addr + 1			;..

lds R16, HIGH(mapping_data_start_addr)
sts mapping_data_addr_h, R16

lds R16, LOW(mapping_data_start_addr)
sts mapping_data_addr_l, R16

in R16, DDRA					;Port A pin 1 siddes som output og tager h�jde for at nuv�rendene v�rdier ikke overskrives
sbr R16, 0b00000010				;..
out DDRA, R16					;..

in R16, PORTA					;slukker Pin 1 i port A (elektromagnet)
cbr R16, 0b00000010				;..
out PORTA, R16					;..

;=======================================
;========== Die Feinabstimmung =========
;=======================================

ldi R16, 40						;hvor langt fra starten p� et sving, bremsningen skal p�begyndes (40 tiks = 19,33cm)
sts brake_tik, R16				;..

ldi R16, 80						;max turn speed (pwm duty cycle)
sts mts, R16					;..

;==========================
;========== Main ==========
;==========================

	call find_sp				;finder start punkt
load_next_sek:					
	call get_next_sek			;loader n�ste sekment
	lds R16, sek_status			;Hvis lige, jmp "goto_lige"
	sbrs R16, 7					;..
	rjmp goto_lige				;..
	call drive_turn				;k�re igennem sving
	rjmp load_next_sek			;k�re rutine igen
goto_lige:
	call drive_straight			;K�re lige stykke
	rjmp load_next_sek			;k�re rutine igen
	
	;K�R! MuK�R!!

;===========================
;========== Calls ==========
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
	in R16, PORTA				;slukker elektromagnet (Pin 1 i port A)
	cbr R16, 0b00000010			;..
	out PORTA, R16				;..
	setspeed [100]				;set speed 100%
	lds R16, is_ns_turn			;Tjekker om n�ste sekment er sving eller lige
	sbrs R16, 7					;skipper hvis sving
	rjmp no_turn

	;==neste sekment sving==

	call b_dis					;udregner bremse l�ngde (retunere: b_dis_h og b_dis_l)					
								;N�ste par linjer tjekker hvorn�r (get_dis >= b_dis) "hvorn�r der skal bremses".
	lds R18, b_dis_h			;loader b_dis_h
	lds R19, b_dis_l			;loafer b_dis_l
scan_b_time:
	get_dis_hl [R20, R21]		;henter distance k�rt
	sub R19, R21				;b_dis_l - get_dis_l
	sbc R18, R20				;b_dis_h - get_dis-h
	brbs 1, b_dis_pass			;branch hvis z=1 (get_dis == b_dis)
	brbc 2, scan_b_time			;g�r videre hvis N=1 "brancher ikke" (get_dis > b_dis)  <----- pr�v evt med C flag istedet for N flag.
b_dis_passed:
	
	;==Bremser==
	setspeed [0]				;stopper motor

	;sbi DDRA, PORTA1			;t�nder elektromagnet (Pin 1 i port A)  <--------------------------------------------------------tjek om virker
	;nop							;..
	;sbi PORTA, PORTA1			;..

	in R16, PORTA				;t�nder elektromagnet (Pin 1 i port A)
	sbr R16, 0b00000010			;..
	out PORTA, R16				;..

	;- - - - - - - - - - - - - - N�ste par linjer tjekker hvorn�r (get_dis >= ss_dis) "hvorn�r sekment slutter".
	lds R18, ss_dis_h			;loader ss_dis_h
	lds R19, ss_dis_l			;loafer ss_dis_l
scan_lss1:
	get_dis_hl [R20, R21]		;henter distance k�rt
	sub R19, R21				;ss_dis_l - get_dis_l
	sbc R18, R20				;ss_dis_h - get_dis-h
	brbs 1, ns_dis_pass1		;branch hvis z=1 (get_dis == ss_dis)
	brbc 2, scan_lss1			;g�r videre hvis N=1 "brancher ikke" (get_dis > ss_dis)  <----- pr�v evt med C flag istedet for N flag.
ns_dis_pass1

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;return


	;==neste sekment lige==
no_turn:
	
;- - - - - - - - - - - - - - - - N�ste par linjer tjekker hvorn�r (get_dis >= ss_dis) "hvorn�r sekment slutter".
	lds R18, ss_dis_h			;loader ss_dis_h
	lds R19, ss_dis_l			;loafer ss_dis_l
scan_lss2:
	get_dis_hl [R20, R21]		;henter distance k�rt
	sub R19, R21				;ss_dis_l - get_dis_l
	sbc R18, R20				;ss_dis_h - get_dis-h
	brbs 1, ns_dis_pass2		;branch hvis z=1 (get_dis == ss_dis)
	brbc 2, scan_lss2			;g�r videre hvis N=1 "brancher ikke" (get_dis > ss_dis)  <----- pr�v evt med C flag istedet for N flag.
ns_dis_pass2

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;retunere


;====================
;=====Drive turn=====
;====================
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
	lds R16, mts				;s�tter hastighed til max for sving
	setspeed [R16]				
	;- - - - - - - - - - - - - - - - N�ste par linjer tjekker hvorn�r (get_dis >= ss_dis) "hvorn�r sekment slutter".
	lds R18, ss_dis_h			;loader ss_dis_h
	lds R19, ss_dis_l			;loafer ss_dis_l
scan_lss3:
	get_dis_hl [R20, R21]		;henter distance k�rt
	sub R19, R21				;ss_dis_l - get_dis_l
	sbc R18, R20				;ss_dis_h - get_dis-h
	brbs 1, ns_dis_pass3		;branch hvis z=1 (get_dis == ss_dis)
	brbc 2, scan_lss3			;g�r videre hvis N=1 "brancher ikke" (get_dis > ss_dis)  <----- pr�v evt med C flag istedet for N flag.
ns_dis_pass3

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..
	ldi R16, 116				;sender t
	send_bt_byte [R16]			;..

	ret							;retuner




;========================
;=====Break distance=====
;========================
b_dis:							; (retunere: b_dis_h og b_dis_l)

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 98					;sender b
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..

	lds R18, brake_tik			;henter bremsel�ngde [i tiks]
	lds R19, ss_dis_h			;distance til sekment stopper (sekment l�ngde)
	lds R20, ss_dis_l			;..
	lds R21, dis_ref_h			;distance v�rdi, da sekmentede startede:
	lds R22, dis_ref_l			;..
	ldi R23, 0					;bruges til subtraktion

								;Udf�re mattematisk operation "(dis_ref + ss_dis) - brake_tik"
	add R22, R20				;dis_ref_l + ss_dis_l
	adc	R21, R19				;dis_ref_h + ss_dis_h
	sub R20, R18				;tr�kker brake_tik fra (dis_ref_l + ss_dis_l)
	sbc R19, R23				;tr�kker 0 fra (dis_ref_l + ss_dis_l) "for at f� cerry med"
	sts b_dis_h, R19			;gemmer resultat i b_dis_h
	sts b_dis_l, R20			;gemmer resultat i b_dis_l

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 98					;sender b
	send_bt_byte [R16]			;..
	ldi R16, 100				;sender d
	send_bt_byte [R16]			;..

	ret							;retunere




;==========================
;=====Get next sekment=====
;==========================
get_next_sek:					;R28 bruges (retunere: sek_status, sek_dis_h og sek_dis_l)

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 110				;sender n
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..



	ldi XH, mapping_data_addr_h						;load status og inkrimentere
	ldi XL, mapping_data_addr_l						;
	ld R28, x+										;
	sts sek_status, R28								;
	ldi XH, mapping_data_addr_h						;load dis high og inkrimentere
	ldi XL, mapping_data_addr_l						;
	ld R28, x+										;
	sts ss_dis_h, R28								;
	ldi XH, mapping_data_addr_h						;load dis low og inkrimentere
	ldi XL, mapping_data_addr_l						;
	ld R28, x+										;
	sts ss_dis_l, R28								;


	;lds R28, mapping_data_addr						;status
	;sts sek_status, R28								;..
	;.set mapping_data_addr = mapping_data_addr + 1	;..

	;lds R28, mapping_data_addr						;distance h-bite
	;sts ss_dis_h, R28								;..
	;.set mapping_data_addr = mapping_data_addr + 1	;..

	;lds R28, mapping_data_addr						;distance l-bite
	;sts ss_dis_l, R28								;..
	;.set mapping_data_addr = mapping_data_addr +1	;..


	ldi XH, mapping_data_addr_h						;loader status register til sekmentet efter
	ldi XL, mapping_data_addr_l						;
	ld R28, x										;
	sbrs R28, 7										;Tjekker om sekment efter er lige
	rjmp n_sek_l									;hvis lige rjmp "n_sek_l"
	lds R16, 0b11111111								;hvis sving
	sts	is_ns_turn, R16								;..
	rjmp ns_skip									;skipper kode for lige stykke
n_sek_l:
	lds R16, 0b00000000								;hvis lige
	sts	is_ns_turn, R16								;..
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




;==========================
;=====Reset sek addres=====
;==========================
reset_sek_adr:

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 74					;sender J
	send_bt_byte [R16]			;..
	ldi R16, 114				;sender r
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	.set mapping_data_addr = def_sek_adr		;Resitter sek_adr

	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 82					;sender R
	send_bt_byte [R16]			;..
	ldi R16, 114				;sender r
	send_bt_byte [R16]			;..
	ldi R16, 115				;sender s
	send_bt_byte [R16]			;..

	ret							;return





;==========================
;=====Find start punkt=====
;==========================
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
	setspeed [10]				;s�tter langsom hastighed
line_scan:
	sbis TIFR, TOV1				;skib hvis externt interrupt flag er sat			<------------------------------------- skal tjekke om denne linje bliver brugt rigtigt
	rjmp line_scan				;scanner igen
	setspeed [0]				;stopper ved m�lstreg
	;evt brems					;t�nder elektromagneten
	call T1_OV_ISR_CLEAR		;clear externt interrupt flag
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





;=================
;=====Kontrol=====
;=================
k:
	ldi R16, 36					;sender $
	send_bt_byte [R16]			;..
	ldi R16, 75					;sender K
	send_bt_byte [R16]			;..
	ldi R16, 80 				;sender P 
	send_bt_byte [R16]			;..
ret								;retunere





;=========================
;========== ISR ==========
;=========================


;==================================
;========== Kom-protokol ==========
;==================================

;	ascii	betydning

;	$		begyndelse p� ny tilbagem�lding

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

;	jsp		jump to "Find start punkt"
;	rsp		return from "Find start punkt"

;	KP		Kontrol Passed