;Set codes:
.equ set_code = 85
.equ var_code = 86
.equ ping_code = 87
.equ reprogram_code = 88

.equ pf_write_page_code = 89
.equ pf_erase_page_code = 90
.equ pf_file_end_code = 91
.equ pf_reset_code = 92

;info codes:
.equ avr_was_reset = 200
.equ empty_bootloader_command_received = 201

.equ pf_tr_grant_permission = 203
.equ pf_tr_page_written = 204
.equ pf_tr_page_erased = 205
.equ pf_tr_resetting = 206

;error codes:
.equ bl_rc_unknown_set_code = 100
.equ bl_fist_page_empty = 101

.equ pf_tr_unknown_set_code = 102
.equ pf_tr_buffer_overflow_error = 103
