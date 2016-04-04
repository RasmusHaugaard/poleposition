.ifndef __data_memory__
.define __data_memory__

.set addr = 0x60  ; her starter sram - hvor vi kan gemme data under kørslen

;bootloader data adresses:
;bluetooth receiver:
.equ bt_rc_buf_start = addr
.equ bt_rc_buf_length = 10  ; byte buffer til indkommende kommandoer
  .set addr = addr + bt_rc_buf_length
.equ bt_rc_buf_end = addr - 1
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
  .set addr = addr + bt_tr_buf_length
.equ bt_tr_buf_end = addr - 1
.equ bt_tr_store_pointer_L = addr
  .set addr = addr + 1
.equ bt_tr_store_pointer_H = addr
  .set addr = addr + 1
.equ bt_tr_send_pointer_L = addr
  .set addr = addr + 1
.equ bt_tr_send_pointer_H = addr
  .set addr = addr + 1

;da bootloaderen programmeres sepperat, bør der ikke tilføjes noget i filen før denne linje!
;hvis der tilføjes noget før, vil de bruge de samme addresser i data-memory.
;gloabl data adresses

.endif ;__data_memory__
