.include "src/bl/bl.asm"

.org 0x00
	rjmp init

.org 0x06			;adresse for extern interrupt 2 (Port B, pin 2) "motor encoder"
jmp EX2_ISR			;adresse med mere plads

.org 0x2A
jmp app_command_int_handler


;=====Extern interrupt 2 (port b, pin 2) "motor tik"=====
;sei					;global interrupt

init:
;=====Include=====
ldi R18, 1<<INT2	;tillader externt interrupt 2 (Port B, pin 2)
out GICR, R18		;..
ldi R16, 1<<ISC2	;Ops�ttes til at trigge ved puls stigning
out MCUCSR, R16		;..

;.filedef temp = R16
;.filedef temp1 = R17
.include "src/motor/motor_pwm.asm"


;=====Untagelser=====


	sbi DDRA, PORTA1	;Elektromagnet
	nop					;..
	cbi PORTA, PORTA1			;..
	sbi DDRB, PORTB3	;Powm elektromagnet
	nop					;..
	cbi PORTB, PORTB3	;..


;==============
;=====Main=====
;==============

main:
;	ldi R19, 0
;	setspeed [R19]
	jmp main


;=============================
;=====Extern interrupt 2======
;=============================


EX2_ISR:					;interrupt(motor tick)
	ldi R19, 255
	send_bt_byte [R19]
	delayms [100]
	reti


;==========================
;======Command handler=====
;==========================


app_command_int_handler:
.include "src/motor/motor_bt_app_command.asm"
reti
