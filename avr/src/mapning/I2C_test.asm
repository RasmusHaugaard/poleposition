 .include "src/bl/bl.asm"


.def  first_gyro_value_high = R20
.filedef reg_check = R21
.filedef light_status = R22


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
.equ  gyr_sub_xh = 0x29
.equ  gyr_sub_yh = 0x2B

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
.equ  still_turning      = 0b01000000

.org 0x00
rjmp init

.org 0x2A
init:
  delays [1]
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  delays [1]
  .include "src/i2c/i2c_setup_gyr.asm"
  .include "src/lapt/lapt.asm"

sbi   DDRA, PORTA0
nop

ldi   light_status, 0b00000001
out   PORTA, light_status

delays [1]

ldi   light_status, 0b00000000
out   PORTA, light_status

delays [1]

check_for_turn:

  I2C_ID_READ [gyr_addr_w, gyr_reg_ctrl1, gyr_addr_r, reg_check] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data
  I2C_ID_READ [gyr_addr_w, gyr_sub_xh, gyr_addr_r, first_gyro_value_high]

  delayms [100]

  cpi   reg_check, gyr_ctrl1_val
  brne  ERROR

  send_bt_byte [first_gyro_value_high]

  delayms [100]

  rjmp check_for_turn


ERROR:
  ldi   light_status, 0b00000001
  out   PORTA, light_status
  rjmp ERROR
