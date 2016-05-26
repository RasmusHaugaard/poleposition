.include "src/mapping/send_map.asm"
.filedef temp = R16

.set saved_pc = PC
.org 0x2A
jmp cmd_handler
.org saved_pc

rjmp cmd_handler_file_end

cmd_handler:
	.include "src/motor/cmd_handler.asm"
	.include "src/elemag/cmd_handler.asm"
	jmp_cmd_ne [set_code, set_speed_code, set_speed_code_cmd_end]
		disable_control_speed
	set_speed_code_cmd_end:
	jmp_cmd_ne [get_code, get_map_code, send_map_cmd_end]
		rcall send_map
	send_map_cmd_end:
	jmp_cmd_ne [set_code, set_control_speed_code, set_control_speed_cmd_end]
		push temp
		lds temp, bt_rc_buf_start + 2
		set_control_speed [temp]
		pop temp
	set_control_speed_cmd_end:
	jmp_cmd_ne [set_code, set_disable_control_speed_code, set_disable_control_speed_cmd_end]
		disable_control_speed
	set_disable_control_speed_cmd_end:
	reti

cmd_handler_file_end:
