.filedef counter = R16
.filedef spmcrval = R17
.filedef temp1 = R18

pf_start:
	rjmp pf_end

bl_reprogram:
	cli
	.include "src/bl/bl_pf_bt_rc_buffer.asm"
	.include "src/bl/bl_pf_disable_interrupts.asm"
	sbi UCSRB, RXCIE
	.include "src/bl/bl_pf_IVSEL.asm"
	sei
	force_send_bt_byte [pf_tr_grant_permission]
pf_loop:
	pf_load_from_buffer [temp1]

	cpi temp1, pf_erase_page_code
	breq pf_erase_page_handler

	cpi temp1, pf_write_page_code
	breq pf_write_page_handler

	cpi temp1, pf_reset_code
	breq pf_reset

	force_send_bt_byte [pf_tr_unknown_set_code]
pf_reset:
	force_send_bt_byte [pf_tr_resetting]
	cli
pf_reset_loop:
	sbis UCSRA, TXC
	rjmp pf_reset_loop
	soft_reset

pf_erase_page_handler:
	rcall pf_load_word_to_z
	rcall pf_erase_page_z
	force_send_bt_byte [pf_tr_page_erased]
	rjmp pf_loop

pf_write_page_handler:
	ldi counter, PAGESIZE	;load amount of words, that is to be written
	rcall pf_load_word_to_z
	rcall pf_erase_page_z
pf_write_page_temp:
	pf_load_from_buffer [R0]
	pf_load_from_buffer [R1]
	ldi spmcrval, (1<<SPMEN)
	rcall pf_do_spm
	adiw ZH:ZL, 2
	dec counter
	brne pf_write_page_temp
pf_write_page:
	subi ZL, PAGESIZEB
	ldi temp1, 0
	sbc ZH, temp1
	ldi spmcrval, (1<<PGWRT) | (1<<SPMEN)
	rcall pf_do_spm
	force_send_bt_byte [pf_tr_page_written]
	rjmp pf_loop

pf_load_word_to_z:
	pf_load_from_buffer [ZL]
	pf_load_from_buffer [ZH]
	ret

pf_erase_page_z:
	ldi spmcrval, (1<<PGERS) | (1<<SPMEN)
	rcall pf_do_spm
	ret

pf_wait_rwwsb:
	ldi spmcrval, (1<<RWWSRE) | (1<<SPMEN)
	rcall pf_do_spm
	in temp1, SPMCR
	sbrc temp1, RWWSB
	rjmp pf_wait_rwwsb
	ret

pf_do_spm:	;Fra datablad (s. 326)
	; check for previous SPM complete
pf_wait_spm:
	in temp1, SPMCR
	sbrc temp1, SPMEN
	rjmp pf_wait_spm
	; check that no EEPROM write access is present
pf_wait_ee:
	sbic EECR, EEWE
	rjmp pf_wait_ee
	; SPM timed sequence
	cli
	out SPMCR, spmcrval
	spm
	sei

	ret

pf_end:
