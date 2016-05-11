 .include "src/bl/bl.asm"

;.equ last_point_low
.def  first_angel_low = R9
.def  first_angel_high = R17
.def  last_angel_low = R18
.def  last_angel_high = R19
.def  first_point_low = R12
.def  first_point_high = R13
.def  last_point_low = R14
.def  last_point_high = R8
.filedef  first_time_value_low = R21
.filedef  first_time_value_high = R22
.def  current_turn_value = R11
.def  current_status = R24
.def  first_gyro_value_high = R25
.def  last_gyro_value_high = R20
.def  last_time_value_low = R16
.def  last_time_value_high = R10
.def  light_status = R23


;Nogle værdier defineres i starten.
.equ  turn_value_in = 20
.equ  turn_value_out = 5
.equ  left_turn_value_in = turn_value_in
.equ  right_turn_value_in = -turn_value_in
.equ  left_turn_value_out = turn_value_out
.equ  right_turn_value_out = -turn_value_out

.equ  gyr_addr_w = 0b11010000
.equ  gyr_addr_r = 0b11010001
.equ  gyr_sub_zh = 0x2D

.equ  straigh_status     = 0b00000000
.equ  reset_status       = 0b00000000
.equ  status_left_turn   = 0b10000000
.equ  status_rigth_turn  = 0b10001000
.equ  status_one_turn    = 0b00000000
.equ  status_two_turns   = 0b00010000
.equ  status_three_turns = 0b00100000
.equ  status_four_turns  = 0b00110000
.equ  status_inner_turn  = 0b01000000
.equ  status_outter_turn = 0b00000000
.equ  still_turning = 0b01000000

.org 0x00
rjmp init

.org 0x2A
init:
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/i2c/i2c_setup_gyr.asm"
  .include "src/lapt/lapt.asm"
  .include "src/physs/physical_speed.asm"

  sbi   DDRA, PORTA0

check_for_turn:
  get_time_hl [first_time_value_high, first_time_value_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   light_status, 0b00000000
  out   PORTA, light_status

  next_map_sektion:

  cpi   first_gyro_value_high, left_turn_value_in ; Sammenligner den gyro værdi med venstre sving.
  brge  check_turn_angel ;Hoop hvis venstre sving værdi <= gyro.

  cpi   first_gyro_value_high, right_turn_value_in
  brlt  check_turn_angel  ;Hvis gyro < højre sving værdi, så hop.

  rjmp  check_for_turn



check_turn_angel:
  ldi   light_status, 0b00000001
  out   PORTA, light_status

  get_time_hl [last_time_value_high, last_time_value_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, last_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  mov   first_gyro_value_high, last_gyro_value_high

  push  last_time_value_low
  sub   last_time_value_low, first_time_value_low
  pop   first_time_value_low

  mulsu last_gyro_value_high, last_time_value_low
  mov   first_angel_low, R0
  mov   first_angel_high, R1

  add   last_angel_low, first_angel_low
  adc   last_angel_high, first_angel_high


  cpi   first_gyro_value_high, left_turn_value_out ; Sammenligner den gyro værdi med venstre sving.
  brlt  check_right ;Hoop hvis venstre sving værdi >= gyro.

  cpi   first_gyro_value_high, right_turn_value_out
  brge  send_byte  ;Hvis gyro > højre sving værdi, så hop.

  rjmp  check_turn_angel

check_right:
  cpi   first_gyro_value_high, right_turn_value_out
  brge  send_byte  ;Hvis gyro > højre sving værdi, så hop.
  jmp   check_turn_angel

send_byte:
  send_bt_byte [first_gyro_value_high]
  jmp   next_map_sektion

ERROR:
rjmp Error
