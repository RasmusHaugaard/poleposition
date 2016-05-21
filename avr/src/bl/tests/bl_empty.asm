.include "src/bl/bl.asm"

.org 0x00
	rjmp init
	
.org 0x2a
	;Der er modtaget en hel kommando til applikationen.
	;cmd handlers bør skrives i de relevante mapper og samles i main-filen ved 0x2A.
	rjmp cmd_handler

init:

main:
	rjmp main

cmd_handler:
	send_bt_byte [empty_bootloader_command_received]
	ret
