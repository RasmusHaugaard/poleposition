.set addr = 0x60  ; her starter sram - hvor vi kan gemme data under kørslen
;bootloader data adresses:
;bluetooth receiver:
.equ bt_rc_buf_start = addr
.equ bt_rc_buf_length = 10  ; byte buffer til indkommende kommandoer
  .set addr = addr + bt_rc_buf_length - 1
.equ bt_rc_buf_end = addr
  .set addr = addr + 1
.equ bt_rc_pointer_L = addr
  .set addr = addr + 1
.equ bt_rc_pointer_H = addr
  .set addr = addr + 1
.equ bt_rc_status = addr ; receive data status
  .set addr = addr + 1
;bluetooth transmitter
.equ bt_tr_buf_start = addr
.equ bt_tr_buf_length = 100
  .set addr = addr + bt_tr_buf_length - 1
.equ bt_tr_buf_end = addr
.equ bt_tr_store_pointer_L = addr
  .set addr = addr + 1
.equ bt_tr_store_pointer_H = addr
  .set addr = addr + 1
.equ bt_tr_send_pointer_L = addr
  .set addr = addr + 1
.equ bt_tr_send_pointer_H = addr
  .set addr = addr + 1

;Denne fil er kun tænkt til at skulle sætte hukommelsesadresser af til bootloaderen.
;Den skal inkluderes i alle programmer for at man ikke kommer til at bruge de samme adresser.
;brug istedet addr i de filer, hvor der skal bruges hukommelse.
