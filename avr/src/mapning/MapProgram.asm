;pladser i SRAM defineres.
.set  mapping_data_addr = addr
  .equ  mapping_lenght = 200
.set addr = addr + mapping_lenght
  .equ last_map_adress = addr - 1

;Nogle registere tildeles et navn.
;.equ last_point_low
.def  line_register = R16
.def  first_point_low = R17
.def  first_point_high = R18
.def  last_point_low = R19
.def  last_point_high = R20
.def  gyro_value_high = R21
.def  current_turn_value = R22
.def  next_point_low = R23
.def  next_point_high = R24
.def  status_register = R25
.def  first_time_value_low = R26
.def  first_time_value_high = R27
.def  last_time_value_low = R28
.def  last_time_value_high = R29
.def  next_gyro_value_high = R30

;Nogle værdier defineres i starten.
.equ  line_detected =
.equ  left_turn_value_in = 15
.equ  right_turn_value_in = -15
.equ  left_turn_value_out = 10
.equ  right_turn_value_out = -10
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

;Lav kode der tjekker om vi er kørt over startlinjen
white_line:
  ldi line_register, line_value ;Værdien skal hentes fra registe
  cpi

  rjmp white_line

;Når startlijnen er set, log data for første punkt.
start_mapping:
  get_dis_hl[first_point_high, first_point_low]

;Loop der tester om vi kører ligeud eller er i et sving.
check_for_turn:
  I2C_ID_READ [11010000, 0101101, 11010001, gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  ldi   current_turn_value, left_turn_value_in
  cp    current_turn_value, gyro_value_high ; Sammenligner den gyro værdi med venstre sving.
  brlo  left_turn_is_detected ;Hoop hvis venstre sving værdi < gyro.

  ldi   current_turn_value, right_turn_value_in
  cp    current_turn_value, gyro_value_high
  brsh  right_turn_is_detected  ;Hvis gyro =< højre sving værdi, så hop.

  rjmp  check_for_turn

;Hvis vi er i et sving så gør følgende:
left_turn_is_detected:
;1. Log den næste værdi for hvor langt vi er kørt, træk dem fra hinanden,
;og sæt denne værdi ind i vores SRAM.
  get_dis_hl[last_point_high, last_point_low]
  get_time_hl[first_time_value_high, first_time_value_low]
  I2C_ID_READ [11010000, 0101101, 11010001, gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  sts   mapping_data_addr, straigh_status ;Vi loader første dage ind i SRAM for lige stykke

  push  last_point_high
  push  last_point_low

  sub   last_point_low, first_point_low
  sbci  last_point_high, first_point_high

  pop   first_point_low
  pop   first_point_high

  sts   mapping_data_addr, last_point_low ; Husk det med adressen
  sts   mapping_data_addr, last_point_high ;Husk det med adresse

;left status og længde af venstre sving findes:
  ldi   status_register, reset_status       ;Vi reset status til 0.
  ori   status_register, status_left_turn   ;Vi "or" vores status værdi
  rjmp  turn_end_detect

right_turn_is_detected:

  get_dis_hl[last_point_high, last_point_low]
  get_time_hl[first_time_value_high, first_time_value_low]
  I2C_ID_READ [11010000, 0101101, 11010001, gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  sts   mapping_data_addr, straigh_status ;Vi loader første dage ind i SRAM for lige stykke

  push  last_point_high
  push  last_point_low

  sub   last_point_low, first_point_low
  sbci  last_point_high, first_point_high

  pop   first_point_low
  pop   first_point_high

  sts   mapping_data_addr, last_point_low ; Husk det med adressen
  sts   mapping_data_addr, last_point_high ;Husk det med adresse

;højre status og længde af højre sving findes:
  ldi   status_register, reset_status       ;Vi reset status til 0.
  ori   status_register, status_rigth_turn
  rjmp turn_end_detect

;3. Når vi kører ud af sving, sæt lastpoint til omdrejningstæller.
turn_end_detect:
  get_dis_hl[last_point_high, last_point_low]
  get_time_hl[last_time_value_high, last_time_value_low]
  I2C_ID_READ [11010000, 0101101, 11010001, gyro_value_high] ;@0 = SLA+W, @1 = SUB, @2 = SLA+R, 8 = Gyro_data

  sub   last_time_value_low, first_time_value_low   ;Finder tiden mellem de to målinger.
  sbci  last_time_value_high, first_time_value_high ;Finder tiden mellem de to målinger

  sub   next_gyro_value_high, gyro_value_high ;Finder vinkel ændringen.

  mul   next_gyro_value_high,

  ldi   current_turn_value, left_turn_value_out
  cp    current_turn_value, gyro_value_high ; Sammenligner den gyro værdi med venstre sving.
  brlo  turn_ended ;Hoop hvis venstre sving værdi >= gyro.

  ldi   current_turn_value, right_turn_value_in
  cp    current_turn_value, gyro_value_high
  brlo  turn_ended  ;Hvis gyro > højre sving værdi, så hop.

  rjmp  turn_end_detect

turn_ended:
;4. Hvis venstre sving, find ud af hvor langt svinget er. Sammenlign med
;en værdi for den målte længde af et sving. Gyro bruges til at finde ud af hvor
;mange grader vi har drejet, og omdrejninger finder længde af svinget.
  mov   next_point_low, last_point_low
  mov   next_point_high, last_point_high

  sub   last_point_low, first_point_low
  sbci  last_point_high, first_point_high

;4.1 Først finder vi ud af om det er højre eller venstre sving. Hvis venstre,
;log den status ind, ellers hvis højre log en anden status.

;4.2 Dernæst køres en stanard kode, som viser hvor meget vi har drejet, inden
;svinget stopper igen. Denne status smides ind.

;5. Vi tjekker om vi er i inderste eller yderste bane. Her sammenligner vi
;længden af svinget, med målte værdier. Hvis vi ved det er 90 graders sving, så
;skal vi tjekke om det er et langt eller kort 90 graders sving. Herefter log status.

;Når statusregisteret er færdiget, smid dette ud i SRAM. Herefter træk de to længder
;fra hinanden og log herefter denne værdi i SRAM.

;Lav lastpoint om til first point og start forfra.

ERROR:
