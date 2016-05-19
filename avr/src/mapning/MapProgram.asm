.include "src/bl/bl.asm"

;pladser i SRAM defineres.


.set addr = addr +1
  .equ  map_data_pointer_l = addr
.set  addr = addr + 1
  .equ  map_data_pointer_h = addr
.set addr = addr + 1
  .equ  mapping_data_addr = addr
  .equ  mapping_data_lenght = 200
.set addr = addr + mapping_data_lenght
  .equ last_map_adress = addr - 1


.def  first_point_low = R17
.def  first_point_high = R18
.def  last_point_low = R19
.def  last_point_high = R20
.def  current_turn_value = R21
.def  current_status = R22
.def  first_gyro_value_high = R23
.def  last_gyro_value_high = R24



;Nogle værdier defineres i starten.
.equ  left_turn_value_in = 15
.equ  right_turn_value_in = -15
.equ  left_turn_value_out = 5
.equ  right_turn_value_out = -5

.equ  gyr_addr_w = 0b11010000
.equ  gyr_addr_r = 0b11010001
.equ  gyr_sub_zh = 0x2D

.equ  straigh_status     = 0b00000000
.equ  reset_status       = 0b00000000
.equ  status_left_turn   = 0b10000000
.equ  status_rigth_turn  = 0b10000001


.org 0x00
rjmp init

.org 0x2a
init:
delays [1]

  .include "src/setup/stack_pointer.asm"
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/i2c/i2c_setup_gyr.asm"
  .include "src/motor/motor_pwm.asm"
;  .include "src/lapt/lapt.asm"
;  .include "src/physs/physical_speed.asm"


;  sts   map_data_pointer_l, low(map_data_start)
;  sts   map_data_pointer_h, high(map_data_start)

;.macro store_byte_map_data
;.endm

;.macro store_byte_map_data_8
;  lds   ZL, map_data_pointer_l
;  lds   ZH, map_data_pointer_h
;  st    Z+, @0

;  sts   map_data_pointer_l, ZL
;  sts   map_data_pointer_h, ZH
;.endm

  delays [2]
  setspeed [50]


main:
;  get_dis_hl [first_point_high, first_point_low]

check_for_turn:
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  next_map_sektion:

  cpi   current_status, left_turn_value_out

  cpi   first_gyro_value_high, left_turn_value_in ; Sammenligner den gyro værdi med venstre sving.
  brge  left_turn_detected ;Hoop hvis venstre sving værdi < gyro.

  cpi   first_gyro_value_high, right_turn_value_in
  brlt  right_turn_detected  ;Hvis gyro =< højre sving værdi, så hop.

  rjmp  check_for_turn

  left_turn_detected:
  ldi   current_status, status_left_turn
  rjmp  turn_detected

  right_turn_detected:
  ldi   current_status, status_rigth_turn
  rjmp  turn_detected

turn_detected:
;  get_dis_hl [last_point_high, last_point_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data
;  store_byte_map_data [current_status];Vi loader første dage ind i SRAM for lige stykke
  push  current_status
  ldi   current_status, straigh_status
  send_bt_byte [current_status]
  pop   current_status

;  push  last_point_high
;  push  last_point_low

;  sub   last_point_low, first_point_low
;  sbci  last_point_high, first_point_high

;  pop   first_point_low
;  pop   first_point_high

;  store_byte_map_data [last_point_low]
;  store_byte_map_data [last_point_high]
;  send_bt_byte [last_point_high]

  ;left status og længde af venstre sving findes:
;  ldi   status_register, reset_status       ;Vi reset status til 0.
;  ori   status_register, status_left_turn   ;Vi "or" vores status værdi


check_for_turn_ended:
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high]

  cpi   current_status, status_rigth_turn
  breq  check_right

  cpi   current_status, status_left_turn
  breq  check_left

  rjmp  check_for_turn_ended

  check_left:
  cpi   first_gyro_value_high, left_turn_value_out ; Sammenligner den gyro værdi med venstre sving.
  brlt  turn_ended ;Hoop hvis venstre sving værdi < gyro.


  check_right:
  cpi   first_gyro_value_high, right_turn_value_out
  brge  turn_ended  ;Hvis gyro =< højre sving værdi, så hop.

  rjmp check_for_turn_ended

turn_ended:
;  get_dis_hl [last_point_high, last_point_low]

;  push  last_point_high
;  push  last_point_low

;  sub   last_point_low, first_point_low
;  sbc   last_point_high, first_point_high

;  pop    first_point_low
;  pop    first_point_high

;  store_byte_map_data [current_status]
  send_bt_byte [current_status]
  delayms [10]
;  store_byte_map_data [last_point_low]
;  store_byte_map_data [last_point_high]
;  send_bt_byte [last_point_high]

  jmp  next_map_sektion

ERROR:

  rjmp  ERROR
