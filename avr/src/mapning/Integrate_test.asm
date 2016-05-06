.include "src/def/m32def.inc"

;pladser i SRAM defineres.

;.equ navn = addr
;.set addr = addr +1
.set  addr = 0x60
  .equ  map_data_pointer_l = addr
.set  addr = addr + 1
  .equ  map_data_pointer_h = addr
.set addr = addr + 1
  .equ  mapping_data_addr = addr
  .equ  mapping_data_lenght = 200
.set addr = addr + mapping_data_lenght
  .equ last_map_adress = addr - 1

;.equ last_point_low
.def  first_angel_low = R13
.def  first_angel_high = R14
.def  last_angel_low = R15
.def  last_angel_high = R16
.def  first_point_low = R17
.def  first_point_high = R18
.def  last_point_low = R19
.def  last_point_high = R20
.def  first_time_value_low = R21
.def  first_time_value_high = R22
.def  current_turn_value = R23
.def  current_status = R24
.def  first_gyro_value_high = R25
.def  last_gyro_value_high = R26
.def  last_time_value_low = R27
.def  last_time_value_high = R28
.def  light_status = R29


;Nogle værdier defineres i starten.
.equ  left_turn_value_in = 15
.equ  right_turn_value_in = -15
.equ  left_turn_value_out = 10
.equ  right_turn_value_out = -10

.equ  degree180 = 170
.equ  degree135 = 125
.equ  degree90 = 80
.equ  degree45 = 35

.equ  length_value_180 = 140
.equ  length_value_135 = 105
.equ  length_value_90 = 85
.equ  length_value_45 = 40

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

.org 0x00
rjmp init

.org 0x2a
init:
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/setup/stack_pointer.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/util/delay.asm"
  .include "src/i2c/i2c_setup_gyr.asm"

  sts   map_data_pointer_l, low(map_data_start)
  sts   map_data_pointer_h, high(map_data_start)

.macro store_byte_map_data
.endm

.macro store_byte_map_data_8
  lds   ZL, map_data_pointer_l
  lds   ZH, map_data_pointer_h
  st    Z+, @0

  sts   map_data_pointer_l, ZL
  sts   map_data_pointer_h, ZH
.endm

  sbi   DDRA, PORTA0


line_detect:
;kigger efter hvide streg.


check_for_turn:
;  get_dis_hl[first_point_high, first_point_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   light_status, 0b00000000
  out   PORTA, light_status

  next_map_sektion:

  cpi   first_gyro_value_high, left_turn_value_in ; Sammenligner den gyro værdi med venstre sving.
  brge  left_turn_detected ;Hoop hvis venstre sving værdi < gyro.

  cpi   first_gyro_value_high, right_turn_value_in
  brlt  right_turn_jump  ;Hvis gyro =< højre sving værdi, så hop.

  rjmp  check_for_turn

right_turn_jump:
  jmp   right_turn_detected

left_turn_detected:
  ;get_dis_hl[last_point_high, last_point_low]
  ;get_time_hl[first_time_value_high, first_time_value_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   current_status, straigh_status
  store_byte_map_data [current_status];Vi loader første dage ind i SRAM for lige stykke

  push  last_point_high
  push  last_point_low

  sub   last_point_low, first_point_low
  sbci  last_point_high, first_point_high

  pop   first_point_low
  pop   first_point_high

  store_byte_map_data [last_point_low]
  store_byte_map_data [last_point_high]

  ;left status og længde af venstre sving findes:
  ldi   status_register, reset_status       ;Vi reset status til 0.
  ori   status_register, status_left_turn   ;Vi "or" vores status værdi
  jmp   check_turn_angel

right_turn_detected:
  ;get_dis_hl[last_point_high, last_point_low]
  ;get_time_hl[first_time_value_high, first_time_value_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   current_status, straigh_status
  store_byte_map_data [current_status]

  push  last_point_high
  push  last_point_low

  sub   last_point_low, first_point_low
  sbci  last_point_high, first_point_high

  pop   first_point_low
  pop   first_point_high

  store_byte_map_data [last_point_low]
  store_byte_map_data [last_point_high]

  ;left status og længde af venstre sving findes:
  ldi   status_register, reset_status       ;Vi reset status til 0.
  ori   status_register, status_left_turn   ;Vi "or" vores status værdi

check_turn_angel:
;  get_time_hl[last_time_value_high, last_time_value_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, last_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   light_status, 0b00000001
  out   PORTA, light_status

  push  last_gyro_value_high
  sub   last_gyro_value_high, first_gyro_value_high
  pop   first_gyro_value_high

  push  last_time_value_low
  sub   last_time_value_low, first_time_value_low
  pop   first_time_value_low

  mul   last_time_value_low, last_gyro_value_high
  mov   first_angel_low, R0
  mov   first_angel_high, R1

  add   last_angel_low, first_angel_low
  adc   last_angel_high, first_angel_high


  cpi   first_gyro_value_high, left_turn_value_out ; Sammenligner den gyro værdi med venstre sving.
  brlt  check_angel_amount ;Hoop hvis venstre sving værdi >= gyro.

  cpi   first_gyro_value_high, right_turn_value_out
  brge  check_angel_amount  ;Hvis gyro > højre sving værdi, så hop.

  rjmp  check_turn_angel

check_angel_amount:
  get_dis_hl [last_point_high, last_point_low]

  push  last_point_high
  push  last_point_low

  sub   last_point_low, first_point_low
  sbc   last_point_high, first_point_high

  pop    first_point_low
  pop    first_point_high

  cpi   last_angel_high, degree180
  brge  check_turn_length_180   ;Hvis last_angel > 180 grader, så hop

  cpi   last_angel_high, degree135
  brge  check_turn_length_135   ;Hvis last_angel > 135 grader, så hop

  cpi   last_angel_high, degree90
  brge  check_turn_length_90   ;Hvis last_angel > 90 grader, så hop

  cpi   last_angel_high, degree90
  brge  check_turn_length_45   ;Hvis last_angel > 90 grader, så hop

  rjmp  ERROR

check_turn_length_180:
  ori   current_status, status_four_turns

  cpi   last_point_high, length_value_180
  brge  outter_lane_180
  ori   current_status, status_inner_turn
  rjmp  store_data_to_sram

  outter_lane_180:
    ori   current_status, status_outter_turn
    rjmp  store_data_to_sram


check_turn_length_135:
  ori   current_status, status_three_turns

  cpi   last_point_high, length_value_135
  brge  outter_lane_135
  ori   current_status, status_inner_turn
  rjmp  store_data_to_sram

  outter_lane_135:
    ori   current_status, status_outter_turn
    rjmp  store_data_to_sram

check_turn_length_90:
  ori   current_status, status_two_turns

  cpi   last_point_high, length_value_90
  brge  outter_lane_90
  ori   current_status, status_inner_turn
  rjmp  store_data_to_sram

  outter_lane_90:
    ori   current_status, status_outter_turn
    rjmp  store_data_to_sram

check_trurn_length_45:
  ori   current_status, status_one_turn

  cpi   last_point_high, length_value_45
  brge  outter_lane_45
  ori   current_status, status_inner_turn
  rjmp  store_data_to_sram

  outter_lane_45:
    ori   current_status, status_outter_turn
    rjmp  store_data_to_sram

store_data_to_sram:
  store_byte_map_data [current_status]
  store_byte_map_data [last_point_low]
  store_byte_map_data [last_point_high]

  ldi   last_angel_low, reset_status
  ldi   last_angel_high, reset_status
  ldi   current_status, reset_status

  jmp  next_map_sektion
  
ERROR:
  rjmp  ERROR
