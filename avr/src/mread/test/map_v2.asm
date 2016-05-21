
	.equ mapping_data_start_addr = addr
	.set addr = addr + 200

	.set map_data_pointer = mapping_data_start_addr

						;1 lige sekment (fra start til sving)
	ldi R1, 0b00000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 72				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 107				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	


					;1 lige sekment (side)
	ldi R1, 0b00000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 72				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 107				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..



					;3 lige sekmenter (baglinje)
	ldi R1, 0b00000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 216				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 107				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..



					;1 lige sekment (side)
	ldi R1, 0b00000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 72				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 107				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..


					
					;2 lige sekmenter (fra sving til start)
	ldi R1, 0b00000000		;status
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 0				;distance_h
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
	ldi R1, 144				;distance_l
	sts mapping_data_pointer, R1			;..
	.set mapping_data_pointer = mapping_data_pointer + 1	;..
