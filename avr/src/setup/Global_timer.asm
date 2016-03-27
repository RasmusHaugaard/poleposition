;====================================
;=     Initalisering af timer		=
;=									=
;=  Oprettet af Phillip M. Kyndbøl	=
;====================================

;=====Timer1 (16-bit Lab_timer)=====

ldi R16, 0x00	;nulstiller timer1
out TCNT1H, R16	;nulstiller timer1 high bite
out TCNT1L, R16	;nulstiller timer1 high bite