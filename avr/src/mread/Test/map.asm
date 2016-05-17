
	.equ msek =	def_sek_adr	;<--------------------------------------- skal have start adresse

						;1 lige sekment (fra start til sving)
	ldi R1, 0b00000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 72				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 107				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..
	


					;1 lige sekment (side)
	ldi R1, 0b00000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 72				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 107				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..



					;3 lige sekmenter (baglinje)
	ldi R1, 0b00000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 216				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 107				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..



					;1 lige sekment (side)
	ldi R1, 0b00000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 72				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..



						;sving 90 grader
	ldi R1, 0b10000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 107				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..


					
					;2 lige sekmenter (fra sving til start)
	ldi R1, 0b00000000		;status
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 0				;distance_h
	sts msek, R1			;..
	.set msek = msek + 1	;..
	ldi R1, 144				;distance_l
	sts msek, R1			;..
	.set msek = msek + 1	;..
