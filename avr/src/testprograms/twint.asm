.filedef temp1 = R16
.filedef temp2 = R17

.include "src/def/m32def.inc"
.include "src/def/data.inc"

.org LARGEBOOTSTART
	.include "src/setup/stack_pointer.asm"
	.include "src/bt/bt_bl.asm"
	.include "src/bl/program_interrupts.asm"
	.include "src/macros/delay.asm"
	jmp 0

.org 0
	rjmp init
.org 0x1a
	;jmp bl_rxcie_handler; USART RX Complete Handler
.org 0x1c
	;jmp bl_udrei_handler ; UDR Empty handler
.org 0x26
	jmp twint_handler
.org 0x2a
	rjmp app_command_handler
.org 0x2c
init:
	;in		R16, TWCR
	ldi 	R16, (1<<TWINT) | (1<<TWSTA) | (1<<TWEN) | (1<<TWIE) ;Forskellige indstillinger sættes.
	out 	TWCR, R16
	send_bt_byte [0]
	jmp main

.org 500
main:
	rjmp main

twint_handler:
	send_bt_byte [5]
	ldi R16, 0 ;disable twint and discontinue i2c operation
	out TWCR, R16
	reti

app_command_handler:
	send_bt_byte [49]
	ret
