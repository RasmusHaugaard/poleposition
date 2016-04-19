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

.macro phys_speed				;retunere hastighed
	;Body       <---------------------------------------------------------------------------------Skriv makro til hastighed
.endmacro

;=========================
;========== ISR ==========
;=========================

EX1_ISR:					;interrupt(motor tick)
	get_time_hl_[R18]_[R19]	;kopier "nye timer" til R18 og R19
	lds R16, old_time_h		;koper "old timer" fra adresse til R16 og R17
	lds R17, old_time_l		;..
	sts old_time_h, R18		;kopier "nye timer" ind i "old time" (som referance ved næste interrupt)
	sts old_time_l, R19		;..
	sub R18, R16			;(High bite) Trækker "old timer" (R16) fra den nye "nye timer" (R18)
	sub R19, R17			;(low bite) Trækker "old timer" (R17) fra den nye "nye timer" (R19)
	send_bt_byte[R18]		;sender high bite til pc
	send_bt_byte[R19]		;sender low bite til pc
	sts dif_time_h, R18		;gemmer forskellen mellem "ny" og "old" timer
	sts dif_time_l, R19		;..
	reti					;retunere fra interrupt

;===========================
;========== Noter ==========
;===========================