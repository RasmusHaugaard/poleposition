.include "src/def/m32def.inc"
.include "src/def/data.inc"

.equ bootload_start = LARGEBOOTSTART

.org bootload_start
	rjmp boot_init
.org bootload_start + 0x1A
	rjmp pf_bl_rxcie_handler
.org bootload_start + 0x2A
end:
rjmp end
boot_init:
	.include "src/setup/stack_pointer.asm"
	.include "src/util/delay.asm"
	.include "src/util/soft_reset.asm"
	.include "src/bt/bt_tr_force.asm"
	.include "src/bt/bt_bl.asm"
	.include "src/bl/program_interrupts.asm"
	.include "src/bl/program_flash.asm"
	force_send_bt_byte [128]
	jmp 0x00

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

app_receive_command_handler:
	force_send_bt_byte [51] ; clean - not reprogrammed - bl code
	ret

main:
	rjmp main
