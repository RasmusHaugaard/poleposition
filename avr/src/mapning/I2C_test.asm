 .include "src/bl/bl.asm"


.def  first_gyro_value_high = R20
.filedef temp = R26
.filedef temp1 = R25


.equ  gyr_addr_w = 0b11010000
.equ  gyr_addr_r = 0b11010001
.equ  gyr_sub_zh = 0x2D
.equ  gyr_sub_xh = 0x29
.equ  gyr_sub_yh = 0x2B


.org 0x00
rjmp init

.org 0x2A
rjmp app_command_int_handler
init:
  delays [1]
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/i2c/i2c_setup_gyr.asm"
  .include "src/motor/motor_pwm.asm"
  .include "src/lapt/lapt_test.asm"
  .include "src/physs/physical_speed_test.asm"

  delays [2]

  sbi DDRA, PORTA1
  nop
  sbi DDRA, PORTA0
  nop
  cbi PORTA, PORTA1
  nop
  cbi PORTA, PORTA0
  nop
  sbi DDRB, PORTB3
  nop
  cbi DDRB, PORTB3

  setspeed [0]

main:
  I2C_ID_READ [gyr_addr_w, gyr_sub_xh, gyr_addr_r, first_gyro_value_high]

  delayms [100]
  send_bt_byte [first_gyro_value_high]

  rjmp main

ERROR:
  rjmp ERROR


  app_command_int_handler:
  	lds temp, bt_rc_buf_start
  	cpi temp, set_code
  	breq bt_set
  	cpi temp, get_code
  	breq bt_get
    reti

    bt_get:
    	lds temp, bt_rc_buf_start + 1
    	cpi temp, get_speed_code
    	breq bt_get_speed
    	reti

    bt_set:
    	lds temp, bt_rc_buf_start + 1
    	cpi temp, set_speed_code
    	breq bt_set_speed
    	cpi temp, set_stop_code
    	breq bt_set_stop
    	cpi temp, set_reset_lapt_code
    	breq bt_set_reset_lapt
    	reti

    bt_set_speed:
    	lds temp, bt_rc_buf_start + 2
    	mov temp1, temp
    	subi temp1, 100
    	brvs full_speed
    	lsl temp
    	setspeed [temp]
    	reti
    full_speed:
    	setspeed [200]
    	reti

    bt_get_speed:
    	lds temp, dif_time_h
    	send_bt_byte [temp]
    	lds temp, dif_time_l
    	send_bt_byte [temp]
    	reti

    bt_set_stop:
    	setspeed [0]
    	reti

    bt_set_reset_lapt:
    	rcall reset_lap_timer
    	reti
