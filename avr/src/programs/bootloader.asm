.include "src/m32def.inc"
.include "src/def/data.inc"

.org 0x00
	jmp main

;Disse linjer skal blive, når vi uploader til avr'en.
.org 0x1a
	jmp bl_rxcie_handler ; USART RX Complete Handler
.org 0x1c
	jmp bl_udrei_handler ; UDR Empty handler

.org 0x2a
app_command_handler:
	;Når denne funktion kaldes, er der en ny kommando i bt_rc_bufferen.
	;den bliver kaldt inde i et interrupt - så den skal helst ikke tage for lang tid,
	;men vi sandsynligvis ikke sende noget til avr'en under kørsel.
	ret

main:
	rjmp main

.org LARGEBOOTSTART
	rjmp init
	.include "src/macros/soft_reset.asm"
	.include "src/macros/delay.asm"
	.include "src/macros/send_bt.asm"

	.include "src/bootloader/bt_rc.asm"
	.include "src/bootloader/bt_tr.asm"
init:
	.include "src/setup/stack_pointer.asm"
	delays [1]
	.include "src/setup/bluetooth.asm"

.def temp1 = R17

	ldi temp1, 0
	sts bt_rc_status, temp1
	rcall reset_bt_rc_pointer
	sbi UCSRB, RXCIE  ; enable uart receive complete interrupt
	sei ; set global interrupt flag

	rcall init_bt_tr_pointers

	jmp 0x00
