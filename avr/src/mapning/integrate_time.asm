 .include "src/bl/bl.asm"

;.equ last_point_low

.def  total_time = R18
.def  current_time_value = R19
.def  first_point_low = R12
.def  first_point_high = R13
.def  last_point_low = R14
.def  last_point_high = R8
.filedef  first_time_value_low = R3
.filedef  first_time_value_high = R4
.def  current_turn_value = R11
.def  current_status = R24
.def  first_gyro_value_high = R20
.def  last_gyro_value_high = R21
.def  last_time_value_low = R16
.def  last_time_value_high = R10
.def  last_angel_hh = R22
.def  last_angel_hhh = R25
.def  light_status = R23


;Nogle værdier defineres i starten.
.equ  turn_value_in = 15
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
  delays [1]
  .include "src/i2c/i2c_id_macros.asm"
  .include "src/i2c/i2c_setup.asm"
  .include "src/i2c/i2c_setup_gyr.asm"
  .include "src/lapt/lapt.asm"
;  .include "src/motor/motor_pwm.asm"

  sbi   DDRA, PORTA0
  nop
  ldi   light_status, 0b00000001
  out   PORTA, light_status

  delays [1]

  ldi   light_status, 0b00000000


check_for_turn:
  get_time_hl [first_time_value_high, first_time_value_low]
  I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, first_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data


  ldi   light_status, 0b00000000
  out   PORTA, light_status


            next_map_sektion:

            cpi   first_gyro_value_high, left_turn_value_in ; Sammenligner den gyro værdi med venstre sving.
            brge  left_turn_detected ;Hoop hvis venstre sving værdi <= gyro.

            cpi   first_gyro_value_high, right_turn_value_in
            brlt  right_turn_detected  ;Hvis gyro < højre sving værdi, så hop.

            rjmp  check_for_turn

                      left_turn_detected:
                      ldi   current_status, status_left_turn
                      rjmp  check_turn_angel

                      right_turn_detected:
                      ldi   current_status, status_rigth_turn

check_turn_angel:
  ldi   light_status, 0b00000001
  out   PORTA, light_status

      check_turn_angel_agian:

        get_time_hl [last_time_value_high, last_time_value_low]
        I2C_ID_READ [gyr_addr_w, gyr_sub_zh, gyr_addr_r, last_gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

        push  last_time_value_low
        sub   last_time_value_low, first_time_value_low
        pop   first_time_value_low

        add   current_time_value, last_time_value_low
        brcc  skip_inc
        inc   last_angel_hh
        cpi   last_angel_hh, 255
        brne  skip_inc
        inc   last_angel_hhh
        ldi   last_angel_hh, 0

            skip_inc:

              cpi   current_status, status_rigth_turn
              breq  right_check

              cpi   last_gyro_value_high, left_turn_value_out ; Sammenligner den gyro værdi med venstre sving.
              brlt  send_byte ;Hoop hvis venstre sving værdi >= gyro.

              rjmp check_turn_angel_agian

            right_check:
              cpi   last_gyro_value_high, right_turn_value_out
              brge  send_byte  ;Hvis gyro > højre sving værdi, så hop.

              rjmp  check_turn_angel_agian

                        send_byte:
                              send_bt_byte [last_angel_hhh]
                              ldi   last_angel_hhh, 0
                              delayms [100]
                              jmp   check_for_turn

ERROR:
  ldi   light_status, 0b00000001
  out   PORTA, light_status
rjmp Error
