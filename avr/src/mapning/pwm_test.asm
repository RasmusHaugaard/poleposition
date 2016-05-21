 .include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2A
init:
delays [1]
  .include "src/motor/motor_pwm.asm"

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


main:

  setspeed [170]

  delays [4]

  setspeed [0]

  delays [2]
  rjmp main
