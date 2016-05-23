;her antages det, længden fra starten af et sving til starten af næste sving er præcist målt

rjmp correct_turn_lengths_file_end

correct_turn_lengths:

	ldi XL, low(map_data_start_addr)
	ldi XH, high(map_data_start_addr)
	ldi segcnt, first_map_segment_count
	adiw XH:XL, 4 ;bruger ikke længden af det første lige stykke
	

	ret


correct_turn_lengths_file_end:
