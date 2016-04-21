;===================================
;========== Initalisering ==========
;===================================

.equ old_time_h=				;gamle timer værdi (high bite)	<---------------------------- skal have en adresse
.equ old_time_l = addr			;gamle timer værdi (low bite)	<---------------------------- skal have en adresse
.set addr = addr + 1			;..
.equ dif_time_h = addr			;sidste hastighed (high bite)	<---------------------------- skal have en adresse
.set addr = addr + 1			;..
.equ dif_time_l = addr			;sidste hastighed (low bite)	<---------------------------- skal have en adresse
.set addr = addr + 1			;..

ldi 0, R16						;nulstiller sidste timer værdi (high and low)
sts last_time_h, R16			;..
sts last_time_l, R16			;..

;===========================
;========== Macro ==========
;===========================

.macro phys_speed_8_8		;Retunere tid mellem motor tiks
	ldi R16, 0<<INT1		;Disabler interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16			;..
	lds @0, dif_time_h		;..
	lds @1, dif_time_l		;..
	ldi R16, 1<<INT1		;tilader interrupt ved externt trigger 1 (Port D, pin 3)
	out GICR, R16			;..
.endmacro

;=========================
;========== ISR ==========
;=========================

EX1_ISR:					;interrupt(motor tick)
	get_time_hl [R18, R19]	;kopier "nye timer" til R18 og R19
	lds R16, old_time_h		;koper "old timer" fra adresse til R16 og R17
	lds R17, old_time_l		;..
	sts old_time_h, R18		;kopier "nye timer" ind i "old time" (som referance ved næste interrupt)
	sts old_time_l, R19		;..
	sub R19, R17			;(low bite) Trækker "old timer" (R17) fra den nye "nye timer" (R19)
	sbc R18, R16			;(High bite) Trækker "old timer" (R16) fra den nye "nye timer" (R18)
	send_bt_byte [R19]		;sender low bite til pc
	send_bt_byte [R18]		;sender high bite til pc
	sts dif_time_h, R18		;gemmer forskellen mellem "ny" og "old" timer
	sts dif_time_l, R19		;..
	reti					;retunere fra interrupt

;===========================
;========== Noter ==========
;===========================