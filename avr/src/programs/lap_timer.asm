;====================================
;=     Initalisering af timer		=
;=									=
;=  Oprettet af Phillip M. Kyndbøl	=
;====================================


;==Interrupt(lap_timer overflow)==
;lap_register++

;==Interrupt(lap)==
;stop timer
;Omregne timer register til sekunder og ligge det sammen med lab_register
;send lap_register til computer
;nulstil lap_register

ldi R16, 0x00	;nulstiller timer1
out TCNT1H, R16	;nulstiller timer1 high bite
out TCNT1L, R16	;nulstiller timer1 high bite

;start timer