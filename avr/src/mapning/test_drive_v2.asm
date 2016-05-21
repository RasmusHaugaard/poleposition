.include "src/bl/bl.asm"

.def  current_turn_value = R21
.def  current_status = R22
.def  first_gyro_value_high = R23
.def  last_gyro_value_high = R24
.filedef temp = R26
.filedef temp1 = R25


;Nogle værdier defineres i starten.
.equ  left_turn_value_in = 10
.equ  right_turn_value_in = -10
.equ  left_turn_value_out = 4
.equ  right_turn_value_out = -4
.equ  left_turn_break_off = 10
.equ  right_turn_break_off = -10

.equ  gyr_addr_w = 0b11010000
.equ  gyr_addr_r = 0b11010001
.equ  gyr_sub_zh = 0x2D

.equ  straigh_status     = 0b00000000
.equ  reset_status       = 0b00000000
.equ  status_left_turn   = 0b10000000
.equ  status_rigth_turn  = 0b10000001


.org 0x00
rjmp init

.org 0x2A

init:
delays [1]
  .include "src/lapt/lapt_test.asm"
  .include "src/physs/physical_speed_test.asm"
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/i2c/i2c_setup_gyr.asm"
  .include "src/motor/motor_pwm.asm"
  .include "src/elemag/elemag_pwm.asm"


sbi DDRA, PORTA0
nop
cbi PORTA, PORTA0


rjmp  check_for_turn

main:
  setspeed [250]
  delayms [10]
check_for_turn:
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data
  setspeed [220]
  next_map_sektion:

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
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data
  setspeed [250]
  sbi   PORTA, PORTA0
  setelemag [250]

stop_bremse_loop:
cpi   current_status, status_rigth_turn
breq  right_jump

cpi   current_status, status_left_turn
breq  check_left

right_jump:
rjmp check_right

check_left:
I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high]
cpi   first_gyro_value_high, left_turn_break_off ; Sammenligner den gyro værdi med venstre sving.
brlt  turn_ended_jump ;Hoop hvis venstre sving værdi < gyro.

rjmp check_left

turn_ended_jump:
rjmp  turn_off_mag

check_right:
I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high]
cpi   first_gyro_value_high, right_turn_break_off
brge  turn_off_mag  ;Hvis gyro =< højre sving værdi, så hop.
rjmp check_right

turn_off_mag:
  cbi   PORTA, PORTA0
  setelemag [150]
  setspeed [160]

check_for_turn_ended:
  cpi   current_status, status_rigth_turn
  breq  right_jump

  cpi   current_status, status_left_turn
  breq  check_left

  rjmp  check_for_turn_ended

right_jump:
  rjmp check_right

  check_left:
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high]
  cpi   first_gyro_value_high, left_turn_value_out ; Sammenligner den gyro værdi med venstre sving.
  brlt  turn_ended_jump ;Hoop hvis venstre sving værdi < gyro.

  rjmp check_left

turn_ended_jump:
  rjmp  turn_ended

  check_right:
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high]
  cpi   first_gyro_value_high, right_turn_value_out
  brge  turn_ended  ;Hvis gyro =< højre sving værdi, så hop.

  rjmp check_right

turn_ended:
  setelemag [0]
  jmp  main

ERROR:

  rjmp  ERROR
