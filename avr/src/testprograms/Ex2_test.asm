

.org 0x06			;adresse for extern interrupt 2 (Port B, pin 2) "motor encoder"
jmp EX2_ISR			;adresse med mere plads

.org 0x2A
rjmp app_command_int_handler


;=====Extern interrupt 2 (port b, pin 2) "motor tik"=====


ldi R16, 1<<INT2	;tillader externt interrupt 2 (Port B, pin 2)
out GICR, R18		;..
ldi R16, 1<<ISC2	;Opsåttes til at trigge ved puls stigning
out MCUCSR, R18		;..

sei					;global interrupt


;=====Include=====

.include ".include "src/bl/bl.asm"
.filedef temp = R16
.filedef temp1 = R17"
.include "src/motor/motor_pwm.asm"


;=====Untagelser=====


	sbi DDRA, PORTA1	;Elektromagnet
	nop					;..
	cbi PORTA, PORTA1	;..
	nop					;..
	sbi DDRA, PORTA0	;H-bro
	nop					;..
	cbi PORTA, PORTA0	;..
	nop					;..
	sbi DDRB, PORTB3	;Powm elektromagnet
	nop					;..
	cbi DDRB, PORTB3	;..


;==============
;=====Main=====
;==============

main:
	ldi R19, 0
	setspeed [R19]
	jmp main


;=============================
;=====Extern interrupt 2======
;=============================


EX2_ISR:					;interrupt(motor tick)
	ldi R9, 255
	Send_bt_byte [R9]
reti


;==========================
;======Command handler=====
;==========================


app_command_int_handler:
.include ".include "src/motor/motor_bt_app_command.asm"
reti