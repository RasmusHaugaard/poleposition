.include "src/mapping/send_map.asm"

rjmp cmd_handler_file_end

cmd_handler:
	.include "src/motor/cmd_handler.asm"
	.include "src/elemag/cmd_handler.asm"
	jmp_cmd_ne [get_code, get_map_code, send_map_cmd_end]
	rcall send_map
	send_map_cmd_end:
	reti

cmd_handler_file_end:
