.include"src/i2c/i2c_id_macros.asm"
.include"src/def/m32def.inc"

;.equ last_point_low
.def  gyro_value_high = R21
.def  current_turn_value = R22

;Nogle værdier defineres i starten.
.equ  left_turn_value_in = 15
.equ  right_turn_value_in = -15
.equ  left_turn_value_out = 10
.equ  right_turn_value_out = -10

check_for_turn:
  I2C_ID_READ [11010000, 0101101, 11010001, gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   R19, 0b00000000
  out   PORTA, R19

  cpi   gyro_value_high, left_turn_value_in ; Sammenligner den gyro værdi med venstre sving.
  brge  turn_detected ;Hoop hvis venstre sving værdi < gyro.

  cpi   gyro_value_high, right_turn_value_in
  brlt  turn_detected  ;Hvis gyro =< højre sving værdi, så hop.

  rjmp  check_for_turn

turn_detect:
  I2C_ID_READ [11010000, 0101101, 11010001, gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   R19, 0b11111111
  out   PORTA, R19

  cpi   gyro_value_high, left_turn_value_out ; Sammenligner den gyro værdi med venstre sving.
  brlt  check_for_turn ;Hoop hvis venstre sving værdi >= gyro.

  cpi   gyro_value_high, right_turn_value_out
  brge  check_for_turn  ;Hvis gyro > højre sving værdi, så hop.

  rjmp  turn_end_detect

ERROR:
  ldi   R19, 0b10101010
  out   PORTA, R19
  delay500ms
  ldi   R19, 0b01010101
  out   PORTA, R19
  delay500ms
  rjmp ERROR


  .macro delay500ms
  	ldi 	R16, 16
  delay1:
  	ldi 	R17, 25
  delay2:
  	ldi 	R18, 50
  delay3:
  	nop
  	dec	 	R18
  	brne	delay3
  	nop
  	dec	 	R17
  	brne	delay2
  	nop
  	dec		R16
  	brne	delay1
  .endm
