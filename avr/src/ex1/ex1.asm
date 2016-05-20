;=======================
;=====Initalisering=====
;=======================
.set saved_pc = PC

.org 0x04		;adresse for extern interrupt 1 (Port D, pin 3)	"streg måler"
jmp EX1_ISR		;adresse med mere plads

.org saved_pc


;=== extern interrupt 1 ==
cli
ldi R16, 1<<INT1					;tilader interrupt ved externt trigger 1 (Port D, pin 3)
out GICR, R16						;..
ldi R16, (1<<ISC10) | (1<<ISC11)	;opsætter til at trigge ved puls stigning
out	MCUCR, R16						;..
sei	

jmp ex1_end

;=============
;=====EX1=====
;=============
EX1_ISR:						;Interrupt(kommer over lap-stregen)
	rcall lap_finished
	rcall reset_sek_adr			;resetter sekment adresse for mread
	reti




ex1_end: