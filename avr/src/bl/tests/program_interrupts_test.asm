.include "src/def/m32def.inc"
.include "src/def/data.inc"

.org LARGEBOOTSTART
	.include "src/setup/stack_pointer.asm"
	.include "src/util/delay.asm"
	.include "src/util/soft_reset.asm"
	.include "src/bt/bt_bl.asm"

	force_send_bt_byte [0]
	rcall send_interrupt_vectors
	force_send_bt_byte [0]
	.include "src/bl/program_interrupts.asm"
	rcall send_interrupt_vectors
	force_send_bt_byte [0]

	jmp 0x00

send_interrupt_vectors:
	ldi ZH, 0
	ldi ZL, 0x1a * 2
	lpm R16, Z+
	force_send_bt_byte [R16]
	lpm R16, Z+
	force_send_bt_byte [R16]
	lpm R16, Z+
	force_send_bt_byte [R16]
	lpm R16, Z+
	force_send_bt_byte [R16]
	ret

.org 0x00
	rjmp main
.org 0x1a
  ;jmp bl_rxcie_handler; USART RX Complete Handler
.org 0x1c
  ;jmp bl_udrei_handler ; UDR Empty handler
.org 0x2a
app_receive_command_interrupt_vector:
	;Nu har vi modtaget en hel kommando. Find ud af, hvad der skal ske.
	;Bemærk dette kører inde i en interrupt fra et rcall i bt_rc.asm
	jmp app_receive_command_handler

main:
	rjmp main

app_receive_command_handler:
	force_send_bt_byte [49]
	ret

bl_reprogram:
	force_send_bt_byte [50]
	ret
