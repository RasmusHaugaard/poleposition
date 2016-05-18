 .include "src/bl/bl.asm"

.org 0x00
rjmp init

.org 0x2A
init:

  .include "src/motor/motor_pwm.asm"

main:

  setspeed [160]

  delays [2]

  setspeed [180]

  delays [2]

  setspeed [200]

  delays [2]

  rjmp main
