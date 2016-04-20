.include "src/bl/bl.asm"

.org 0x00
	rjmp init
.org 0x1a
  ;jmp bl_rxcie_handler; USART RX Complete Handler
.org 0x1c
  ;jmp bl_udrei_handler ; UDR Empty handler
.org 0x2a ;app_receive_command_interrupt_vector:
	;Nu har vi modtaget en hel kommando. Find ud af, hvad der skal ske.
	;Bemærk, at det kører inde i en interrupt fra et rcall i bt_rc.asm
	rjmp app_receive_command_handler

app_receive_command_handler:
	send_bt_byte [empty_bootloader_command_received]
	ret

init:

main:
	rjmp main
