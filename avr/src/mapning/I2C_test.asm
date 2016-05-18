 .include "src/bl/bl.asm"


.def  first_gyro_value_high = R20


.equ  gyr_addr_w = 0b11010000
.equ  gyr_addr_r = 0b11010001
.equ  gyr_sub_zh = 0x2D
.equ  gyr_sub_xh = 0x29
.equ  gyr_sub_yh = 0x2B


.org 0x00
rjmp init

.org 0x2A
init:
  delays [1]
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/i2c/i2c_setup_gyr.asm"
  delays [1]


main:
  I2C_ID_READ [gyr_addr_w, gyr_sub_xh, gyr_addr_r, first_gyro_value_high]

  delayms [10]
  send_bt_byte [first_gyro_value_high]

  rjmp main
