.include "src/def/m32def.inc"

.org 0x00 
rjmp init

.org 0x24
init:
.include "src/setup/stack_pointer.asm"
.include "src/bt/bt_tr.asm"
.include "src/motor/motor_pwm.asm"
.include "src/lapt.asm"
.include "src/physs/physical_speed.asm"
.include "src/mread/test/map.asm"
.include "src/mread/map_reading.asm"