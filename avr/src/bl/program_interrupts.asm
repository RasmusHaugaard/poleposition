.filedef counter = R16
.filedef spmcrval = R17
.filedef temp1 = R18

.equ jmp_opcode_1b = 0x940c

pi_start:
	cli
	ldi ZL, 0
	ldi ZH, 0
	ldi counter, PAGESIZE

pi_wrloop:
	lpm r0, Z+
	lpm r1, Z+
	subi ZL, 2

	cpi ZL, (0x1a + 0) * 2
	brne not_rxcie_1
	ldi temp1, low(jmp_opcode_1b)
	mov r0, temp1
	ldi temp1, high(jmp_opcode_1b)
	mov r1, temp1
not_rxcie_1:
	cpi ZL, (0x1a + 1) * 2
	brne not_rxcie_2
	ldi temp1, low(bl_rxcie_handler)
	mov r0, temp1
	ldi temp1, high(bl_rxcie_handler)
	mov r1, temp1
not_rxcie_2:
	cpi ZL, (0x1c + 0) * 2
	brne not_udrei_1
	ldi temp1, low(jmp_opcode_1b)
	mov r0, temp1
	ldi temp1, high(jmp_opcode_1b)
	mov r1, temp1
not_udrei_1:
	cpi ZL, (0x1c + 1) * 2
	brne not_udrei_2
	ldi temp1, low(bl_udrei_handler)
	mov r0, temp1
	ldi temp1, high(bl_udrei_handler)
	mov r1, temp1
not_udrei_2:

	ldi spmcrval, (1<<SPMEN)
	rcall pi_do_spm
	inc ZL
	inc ZL
	dec counter
	brne pi_wrloop
	subi ZL, PAGESIZEB
	ldi spmcrval, (1<<PGERS) | (1<<SPMEN)
	rcall pi_do_spm
	ldi spmcrval, (1<<PGWRT) | (1<<SPMEN)
	rcall pi_do_spm
pi_return:
	ldi spmcrval, (1<<RWWSRE) | (1<<SPMEN)
	rcall pi_do_spm
	in temp1, SPMCR
	sbrs temp1, RWWSB
	rjmp pi_end
	rjmp pi_return

pi_do_spm:	;Fra datablad (s. 326)
	; check for previous SPM complete
pi_wait_spm:
	in temp1, SPMCR
	sbrc temp1, SPMEN
	rjmp pi_wait_spm
	; check that no EEPROM write access is present
pi_wait_ee:
	sbic EECR, EEWE
	rjmp pi_wait_ee
	; SPM timed sequence
	out SPMCR, spmcrval
	spm
	ret

pi_end:
	sei
