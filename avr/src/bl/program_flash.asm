.filedef counter = R16
.filedef spmcrval = R17
.filedef temp1 = R18
.equ pf_write_page_code = 250
.equ pf_erase_page_code = 251
.equ pf_file_end_code = 252

.equ pf_status_code_error = 100
.equ pf_status_flash_success = 200
.equ pf_status_page_written = 201
.equ pf_status_page_erased = 202

pf_start:
	rjmp pf_end

bl_reprogram:
	cli

	rcall pf_wait_rxc
	in temp1, UDR

	cpi temp1, pf_erase_page_code
	breq pf_erase_page_handler

	cpi temp1, pf_new_page_code
	breq pf_new_page_handler

	cpi temp1, pf_file_end_code
	breq pf_file_end_handler

	force_send_bt_byte [pf_status_code_error]
	delays [1]
	soft_reset

pf_file_end_handler:
	delays [1]
	soft_reset

pf_new_page_handler:
	ldi counter, PAGESIZE	;load amount of words, that is to be written
	rcall pf_load_z_erase_page
pf_write_page_temp:
	rcall pf_wait_rxc
	in r0, UDR
	rcall pf_wait_rxc
	in r1, UDR
	ldi spmcrval, (1<<SPMEN)
	rcall pf_do_spm
	adiw ZH:ZL, 2
	dec counter
	brne pf_write_page_temp
pf_write_page:
	sub ZL, PAGESIZEB
	sbc ZH, 0
	ldi spmcrval, (1<<PGWRT) | (1<<SPMEN)
	rcall pf_do_spm
	force_send_bt_byte [pf_status_page_written]
	rjmp bl_reprogram

pf_erase_page_handler:
	rcall pf_load_z_erase_page
	force_send_bt_byte [pf_status_page_erased]
	rjmp bl_reprogram

pf_load_z_erase_page:
	rcall pf_load_word_to_z
	rcall pf_erase_page_z
	ret

pf_load_word_to_z:
	rcall pf_wait_rxc
	in temp1, UDR
	mov ZL, temp1
	rcall pf_wait_rxc
	in temp1, UDR
	mov ZH, temp1
	ret

pf_erase_page_z:
	ldi spmcrval, (1<<PGERS) | (1<<SPMEN)
	rcall pf_do_spm
	ret

pf_wait_rxc:
	sbis UCSRA, RXC
	rjmp pf_wait_rxc
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
	out SPMCR, spmcrval
	spm
	ret

pf_end:
