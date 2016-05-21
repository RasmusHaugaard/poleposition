	.filedef temp = R16

	.equ mapping_data_start_addr = addr
	.set addr = addr + 200

	.set map_data_pointer = mapping_data_start_addr

						;1 lige sekment (fra start til sving)
	ldi temp, 0b00000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 72				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



						;sving 90 grader
	ldi temp, 0b10000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 107				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



					;1 lige sekment (side)
	ldi temp, 0b00000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 72				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



						;sving 90 grader
	ldi temp, 0b10000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 107				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



					;3 lige sekmenter (baglinje)
	ldi temp, 0b00000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 216				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



						;sving 90 grader
	ldi temp, 0b10000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 107				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



					;1 lige sekment (side)
	ldi temp, 0b00000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 72				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



						;sving 90 grader
	ldi temp, 0b10000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 107				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..



					;2 lige sekmenter (fra sving til start)
	ldi temp, 0b00000000		;status
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 0				;distance_h
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
	ldi temp, 144				;distance_l
	sts map_data_pointer, temp			;..
	.set map_data_pointer = map_data_pointer + 1	;..
