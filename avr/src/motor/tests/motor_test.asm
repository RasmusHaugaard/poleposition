.include "src/def/m32def.inc"
.org 0
jmp init


.org 0x2a
init:
.include "src/setup/stack_pointer.asm"
.include "src/motor/motor_pwm.asm"
.include "src/i2c/i2c_setup.asm"
.include "src/i2c/i2c_id_macros.asm"
.include "src/util/delay.asm"


nop
setspeed [50]

sbi   DDRA, PORTA0
nop


main:

delays [1]

  ldi   R16, 0b00000000
  out   PORTA, R16

delays [1]

  ldi   R16, 0b00000001
  out   PORTA, R16

  rjmp main
