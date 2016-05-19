;Bootloader commands:
.equ set_code = 85
.equ var_code = 86
.equ ping_code = 87
.equ reprogram_code = 88
.equ get_code = 170

;set codes:
.equ set_speed_code = 0x10
.equ set_stop_code = 0x11
.equ set_reset_lapt_code = 0x12

;get codes:
.equ get_speed_code = 94 ;ni four speed

;program_flash
.equ pf_write_page_code = 89
.equ pf_erase_page_code = 90
.equ pf_file_end_code = 91
.equ pf_reset_code = 92
