.filedef temp = R16

push temp
ldi temp, 12 ;sæt i2c clk til 400 kHz
out TWBR, temp
pop temp
.include "src/i2c/macros/sync.asm"
.include "src/i2c/macros/async.asm"
